#!/usr/bin/env python3
"""Gauntlet — avaliador automático com score contínuo e catraca (ratchet).

Princípio (rules/gauntlet-protocol.md §11): o agente melhora contra uma
métrica que ele não controla. Gates binários bloqueiam; um score 0-100
ranqueia; a baseline só sobe (catraca). Feedback textual diz o que corrigir.

Uso:
  gauntlet.py init   [--project DIR]                  # gera gauntlet.json p/ o stack detectado
  gauntlet.py run    [--project DIR] [--json] [--no-ratchet]
  gauntlet.py status [--project DIR]
  gauntlet.py accept [--project DIR] --reason "..."   # SÓ com aceite do operador: rebaixa baseline
  gauntlet.py hook                                    # Stop hook (Claude Code / Cursor), lê stdin

Só stdlib. Estado local em <projeto>/.gauntlet/ (auto-ignorado pelo git).
"""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import time
import uuid
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path

CONFIG_NAME = "gauntlet.json"
COVERAGE_RC = "gauntlet.coveragerc"
# Coverage mede código de produção: arquivo de teste executado não pode inflar o número.
COVERAGE_RC_BODY = """[run]
omit =
    tests/*
    */tests/*
    test_*.py
    */test_*.py
    .venv/*
    venv/*
"""
STATE_DIR = ".gauntlet"
LOCK_STALE_S = 1000  # > timeout do hook (900 s): lock de hook morto expira logo
HOOK_BUDGET_S = 700  # folga p/ git/kill/escrita abaixo do timeout de 900 s do hook
EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
MIN_PROJECT_BUDGET_S = 60
GREENS_TO_RESET = 3
OUTPUT_TAIL = 40
MAX_FEEDBACK_ITEMS = 10
MAX_GATE_ITEMS = 100
LOG_MAX_BYTES = 1_000_000
CACHE_TTL_S = 14 * 24 * 3600
HOOK_LOG = Path.home() / ".claude" / "gauntlet-hook.log"
EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}
SHELL_TOOLS = {"Bash", "PowerShell"}
FALLBACK_SKIP_DIRS = {".git", STATE_DIR, ".venv", "venv", "node_modules", "__pycache__", ".pytest_cache", "dist"}
SOURCE_EXTS = {
    ".py", ".pyi", ".js", ".jsx", ".mjs", ".cjs", ".ts", ".tsx", ".mts", ".cts", ".vue", ".svelte",
    ".go", ".java", ".kt", ".cs", ".rb", ".php", ".rs", ".swift", ".cls", ".trigger",
}  # fmt: skip
# Gerados/empacotados: supressão ali não é decisão do agente.
DEFAULT_SUPPRESS_IGNORE = ["**/dist/**", "**/build/**", "**/*.min.*", "**/generated/**", "**/*.d.ts", "**/vendor/**"]
# Comando de shell que provavelmente muda arquivo (ls/git log/cat não contam).
MUTATING_CMD_RE = re.compile(
    r"(^|[\s;&|])(sed\s+-i|mv|cp|rm|touch|tee|patch|truncate)\s|>{1,2}\s*[\w./\\~$]"
    r"|\bgit\s+(apply|checkout|restore|reset|merge|pull|rebase|cherry-pick|am|stash\s+pop|commit)\b"
    r"|\b(npm|pnpm|yarn|pip|uv|poetry)\s+(install|add|remove|uninstall|run\s+format|update)\b"
    r"|\b(Set-Content|Add-Content|Out-File|New-Item|Remove-Item|Move-Item|Copy-Item|Rename-Item)\b"
    r"|\b(ruff\s+(format|check\s+.*--fix)|prettier\s+.*--write|black|isort|gofmt\s+-w)\b",
    re.IGNORECASE,
)

# Ancorado no início da instrução: pega decorator/chamada real, não texto dentro de string.
SKIP_RE = re.compile(
    r"^\s*(@pytest\.mark\.(skip|skipif|xfail)\b|@unittest\.skip|@Disabled\b|#\[ignore\]"
    r"|pytestmark\s*=.*\b(skip|skipif|xfail)\b|(\w+\s*=\s*)?pytest\.importorskip\(|raise\s+(unittest\.)?SkipTest\b"
    r"|(it|describe|test)\.(skip|only)\(|x(it|describe)\(|pytest\.skip\(|t\.Skip\()"
)
# Comentários que desligam a métrica ou o lint em código de produção.
SUPPRESS_RE = re.compile(
    r"#\s*pragma:\s*no\s*(cover|branch)|#\s*noqa(?!:)|#\s*noqa:[^#]*\bC901\b"
    r"|istanbul\s+ignore|eslint-disable|c8\s+ignore"
)
ASSERT_RE = re.compile(r"^\s*(assert\b|self\.assert\w*\(|expect\(|require\.\w+\(|assert\.\w+\()")
TRIVIAL_ASSERT_RE = re.compile(
    r"^\s*(assert\s+(True|1|not\s+False|None\s+is\s+None)\s*(,.*)?$"
    r"|self\.assertTrue\(\s*True\s*\)|expect\(\s*true\s*\)\.toBe\(\s*true\s*\))"
)
# Diagnóstico `arquivo.ext:linha` (timestamp `12:30:45` não casa: exige extensão).
DIAG_RE = re.compile(r"^\S+?\.[A-Za-z0-9]{1,6}:\d+(:\d+)?[:\s]")


# ---------------------------------------------------------------- utilidades


def _log(msg: str) -> None:
    try:
        HOOK_LOG.parent.mkdir(parents=True, exist_ok=True)
        if HOOK_LOG.exists() and HOOK_LOG.stat().st_size > LOG_MAX_BYTES:
            os.replace(HOOK_LOG, HOOK_LOG.with_name(HOOK_LOG.name + ".1"))
        with HOOK_LOG.open("a", encoding="utf-8") as fh:
            fh.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}\n")
    except OSError:
        pass


def _git_raw(project: Path, *args: str) -> tuple[int, str]:
    try:
        out = subprocess.run(
            ["git", "-c", "core.quotepath=off", "-C", str(project), *args],
            capture_output=True,
            timeout=60,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        _log(f"git {args[:2]} falhou em {project}: {exc!r}")
        return -1, ""
    return out.returncode, out.stdout.decode("utf-8", "replace")


def _git(project: Path, *args: str) -> str:
    code, out = _git_raw(project, *args)
    return out if code == 0 else ""


def is_git(project: Path) -> bool:
    return _git(project, "rev-parse", "--is-inside-work-tree").strip() == "true"


def _read_json(path: Path, default):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return default


def _write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.{os.getpid()}.{uuid.uuid4().hex[:6]}.tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    for attempt in range(5):  # antivírus/indexador no Windows segura o arquivo por instantes
        try:
            os.replace(tmp, path)
            return
        except PermissionError:
            time.sleep(0.1 * (attempt + 1))
    os.replace(tmp, path)


def find_project(start: Path) -> Path | None:
    """Sobe a partir de `start` até achar um diretório com gauntlet.json."""
    p = start if start.is_dir() else start.parent
    for cand in [p, *p.parents]:
        if (cand / CONFIG_NAME).is_file():
            return cand
    return None


def state_dir(project: Path) -> Path:
    d = project / STATE_DIR
    d.mkdir(exist_ok=True)
    ign = d / ".gitignore"
    if not ign.exists():
        ign.write_text("*\n", encoding="utf-8")
    return d


def project_python(project: Path) -> str:
    for rel in (".venv/Scripts/python.exe", ".venv/bin/python", "venv/Scripts/python.exe", "venv/bin/python"):
        cand = project / rel
        if cand.is_file():
            return str(cand)
    return sys.executable


def _expand(value: str, ctx: dict[str, str]) -> str:
    for k, v in ctx.items():
        value = value.replace("{" + k + "}", v)
    return value


def _expand_path(value: str, ctx: dict[str, str]) -> Path:
    """Expande placeholders; caminho relativo é relativo ao projeto, não ao processo."""
    p = Path(_expand(value, ctx))
    return p if p.is_absolute() else Path(ctx["project"]) / p


def _match_any(path: str, globs: list[str]) -> bool:
    """fnmatch onde `*` cruza `/`; `**/x` também casa `x` na raiz."""
    path = path.replace("\\", "/")
    for g in globs:
        if fnmatch.fnmatch(path, g):
            return True
        if "**/" in g and fnmatch.fnmatch(path, g.replace("**/", "")):
            return True
    return False


def _short(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8", "replace")).hexdigest()[:12]


# ------------------------------------------------------------- fingerprint


def _walk_files(project: Path):
    for root, dirs, files in os.walk(project):
        dirs[:] = [d for d in dirs if d not in FALLBACK_SKIP_DIRS]
        for f in files:
            yield Path(root) / f


def fingerprint(project: Path) -> str:
    """Hash do estado do código: HEAD + diff + não rastreados. Sem git: mtime/tamanho de tudo."""
    h = hashlib.sha256()
    if not is_git(project):
        for f in sorted(_walk_files(project)):
            try:
                st = f.stat()
                h.update(f"{f.relative_to(project)}:{st.st_size}:{st.st_mtime_ns}".encode())
            except OSError:
                continue
        return "nogit-" + h.hexdigest()
    h.update(_git(project, "rev-parse", "HEAD").encode())
    h.update(_git(project, "diff", "HEAD", "--no-ext-diff", "--binary", "--relative", "--", ".").encode())
    for rel in sorted(_git(project, "ls-files", "--others", "--exclude-standard").splitlines()):
        try:
            st = (project / rel).stat()
            h.update(f"{rel}:{st.st_size}:{st.st_mtime_ns}".encode())
        except OSError:
            continue
    return h.hexdigest()


# ------------------------------------------------------------------ execução


@dataclass
class CmdResult:
    name: str
    ok: bool
    code: int
    output: str
    seconds: float
    stdout: str = ""


def _kill_tree(proc: subprocess.Popen) -> None:
    """Mata o processo e os netos (no Windows, subprocess.run(timeout) não mata netos)."""
    try:
        if os.name == "nt":
            subprocess.run(["taskkill", "/T", "/F", "/PID", str(proc.pid)], capture_output=True, timeout=30)
        else:
            os.killpg(proc.pid, signal.SIGKILL)
    except (OSError, subprocess.TimeoutExpired):
        pass
    try:
        proc.kill()
    except OSError:
        pass


def run_cmd(name: str, cmd, project: Path, ctx: dict[str, str], env_extra: dict, timeout: float) -> CmdResult:
    if timeout <= 1:
        return CmdResult(name, False, -3, "orçamento de tempo esgotado antes de rodar", 0.0)
    env = os.environ.copy()
    env.update({k: _expand(str(v), ctx) for k, v in (env_extra or {}).items()})
    env.setdefault("PYTHONIOENCODING", "utf-8")
    shell = isinstance(cmd, str)
    args = _expand(cmd, ctx) if shell else [_expand(str(a), ctx) for a in cmd]
    kw: dict = {}
    if os.name == "nt":
        kw["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kw["start_new_session"] = True
    t0 = time.time()
    try:
        proc = subprocess.Popen(
            args, cwd=project, env=env, shell=shell, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kw
        )
    except OSError as exc:
        return CmdResult(name, False, -2, f"falha ao executar: {exc}", time.time() - t0)
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        _kill_tree(proc)
        try:
            proc.communicate(timeout=10)
        except (subprocess.TimeoutExpired, ValueError):
            pass
        return CmdResult(name, False, -1, f"TIMEOUT após {int(timeout)}s (árvore de processos encerrada)", timeout)
    stdout = out.decode("utf-8", "replace")
    text = stdout + "\n" + err.decode("utf-8", "replace")
    return CmdResult(name, proc.returncode == 0, proc.returncode, text, time.time() - t0, stdout)


def parse_junit(path: Path) -> dict:
    """Retorna contagens + falhas de um junit.xml (pytest, jest-junit, go-junit)."""
    res = {"tests": 0, "failures": 0, "errors": 0, "skipped": 0, "failed": []}
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError):
        return res
    suites = [root] if root.tag == "testsuite" else list(root.iter("testsuite"))
    for s in suites:
        for case in s.iter("testcase"):
            res["tests"] += 1
            name = f"{case.get('classname', '')}::{case.get('name', '')}".strip(":")
            for tag, key in (("failure", "failures"), ("error", "errors")):
                el = case.find(tag)
                if el is not None:
                    res[key] += 1
                    msg = (el.get("message") or el.text or "").strip().splitlines()
                    res["failed"].append(f"{name} — {msg[0][:240] if msg else tag}")
            if case.find("skipped") is not None:
                res["skipped"] += 1
    return res


def read_coverage(path: Path) -> dict:
    """coverage.py JSON → {total, files:{path:pct}, missing:{path:[linhas]}}. Malformado → {}."""
    data = _read_json(path, None)
    try:
        files, missing = {}, {}
        for fname, info in data.get("files", {}).items():
            key = fname.replace("\\", "/")
            files[key] = round(info["summary"]["percent_covered"], 2)
            missing[key] = info.get("missing_lines", [])
        return {"total": float(data["totals"]["percent_covered"]), "files": files, "missing": missing}
    except (AttributeError, KeyError, TypeError, ValueError):
        return {}


def ruff_items(stdout: str) -> list[str] | None:
    """Lista de diagnósticos do `ruff --output-format json`. Saída ilegível → None (indisponível)."""
    start = stdout.find("[")
    if start < 0:
        return None
    try:
        items, _ = json.JSONDecoder().raw_decode(stdout[start:])
    except ValueError:
        return None
    if not isinstance(items, list):
        return None
    out = []
    for it in items:
        fname = str(it.get("filename", "")).replace("\\", "/")
        out.append(f"{Path(fname).name}:{it.get('location', {}).get('row', '?')} {it.get('message', '')}")
    return out


def normalize(value: float, norm) -> float:
    if isinstance(norm, str):
        norm = {"type": norm}
    kind = norm.get("type", "percent")
    if kind == "percent":
        v = value / 100.0
    elif kind == "inverse":  # menor é melhor; 0 → 1.0
        k = float(norm.get("k", 10))
        v = k / (k + max(value, 0.0))
    elif kind == "linear":
        lo, hi = float(norm["min"]), float(norm["max"])
        v = (value - lo) / (hi - lo) if hi != lo else 0.0
        if norm.get("lower_is_better"):
            v = 1.0 - v
    else:
        raise ValueError(f"norm desconhecida: {kind}")
    return max(0.0, min(1.0, v))


# ---------------------------------------------------------------- integridade


def _has_head(project: Path) -> bool:
    return _git_raw(project, "rev-parse", "--verify", "-q", "HEAD")[0] == 0


def base_ref(project: Path, baseline: dict | None) -> str:
    """Referência da integridade: o último estado APROVADO (verde ou accept), não o HEAD.

    Commitar não apaga a checagem; e o diff fica limitado ao que mudou desde o último verde.
    Repo sem commit: árvore vazia (tudo o que foi `git add` conta como novo).
    """
    b = baseline or {}
    for commit in (b.get("ref"), b.get("commit")):
        if commit and _git_raw(project, "cat-file", "-e", f"{commit}^{{commit}}")[0] == 0:
            return commit
    return "HEAD" if _has_head(project) else EMPTY_TREE


def _is_source(rel: str) -> bool:
    return Path(rel).suffix.lower() in SOURCE_EXTS


def _file_sha(path: Path) -> str | None:
    """sha1 em streaming (sem limite de tamanho: arquivo grande não pode escapar da checagem)."""
    h = hashlib.sha1()
    try:
        with path.open("rb") as fh:
            for chunk in iter(lambda: fh.read(1 << 20), b""):
                h.update(chunk)
    except OSError:
        return None
    return h.hexdigest()


def _untracked(project: Path) -> list[str]:
    return _git(project, "ls-files", "--others", "--exclude-standard").splitlines()


def pin_ref(project: Path, ref: str) -> None:
    """Prende o commit aprovado em refs/gauntlet/<projeto> para o `git gc` não apagá-lo."""
    pin = f"refs/gauntlet/{_short(str(project.resolve()).lower())}"
    if _git_raw(project, "update-ref", pin, ref)[0] != 0:
        _log(f"update-ref {pin} falhou em {project}")


def snapshot(project: Path, protected: list[str], pin: bool = True) -> dict:
    """Congela o estado aprovado: commit (com mudanças não commitadas) + hash dos não rastreados relevantes.

    Falha do git → {} (mantém a referência anterior; nunca troca por HEAD com árvore suja).
    O commit fica preso em refs/gauntlet/<projeto> para o `git gc` não apagá-lo.
    """
    if not is_git(project) or not _has_head(project):
        return {}
    code, out = _git_raw(project, "stash", "create")
    if code != 0:
        _log(f"stash create falhou em {project} (merge em andamento?): referência mantida")
        return {}
    ref = out.strip() or _git(project, "rev-parse", "HEAD").strip()
    if not ref:
        return {}
    if pin:
        pin_ref(project, ref)
    approved = {}
    for rel in _untracked(project):
        if _is_source(rel) or _match_any(rel, protected):
            sha = _file_sha(project / rel)
            if sha:
                approved[rel] = sha
    return {"ref": ref, "untracked_ok": approved}


def _new_untracked(project: Path, approved: dict) -> list[str]:
    """Não rastreados que mudaram desde o último estado aprovado."""
    return [
        rel for rel in _untracked(project) if approved.get(rel) is None or approved[rel] != _file_sha(project / rel)
    ]


def _project_files(project: Path) -> set[str]:
    if not is_git(project):
        return {str(f.relative_to(project)).replace("\\", "/") for f in _walk_files(project)}
    files = set(_git(project, "ls-files").splitlines())
    return files | set(_git(project, "ls-files", "--others", "--exclude-standard").splitlines())


def count_test_integrity(project: Path, globs: list[str]) -> dict:
    """Conta asserts não triviais nos arquivos de teste (heurística anti-enfraquecimento)."""
    asserts = 0
    for rel in _project_files(project):
        if not _match_any(rel, globs):
            continue
        try:
            text = (project / rel).read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        asserts += sum(1 for ln in text.splitlines() if ASSERT_RE.match(ln) and not TRIVIAL_ASSERT_RE.match(ln))
    return {"asserts": asserts}


def _diff_path(header: str) -> str | None:
    """Caminho de uma linha `+++ b/arquivo` (git põe TAB no fim quando há espaço; aspas p/ chars especiais)."""
    path = header[4:].rstrip("\t\r")
    if path.startswith('"') and path.endswith('"'):
        path = path[1:-1].replace('\\"', '"').replace("\\t", "\t").replace("\\\\", "\\")
    return path[2:] if path.startswith("b/") else None


def _added_lines(project: Path, ref: str, approved: dict) -> list[tuple[str, str]]:
    """(arquivo, linha) de código-fonte adicionadas desde o último estado aprovado."""
    out: list[tuple[str, str]] = []
    if not is_git(project):
        return out
    current = None
    diff = _git(project, "diff", ref, "--unified=0", "--no-ext-diff", "--relative", "--", ".")
    for line in diff.splitlines():
        if line.startswith("+++ "):
            current = _diff_path(line)
        elif line.startswith("+") and current and _is_source(current):
            out.append((current, line[1:]))
    for rel in _new_untracked(project, approved):
        if not _is_source(rel):
            continue
        try:
            with (project / rel).open(encoding="utf-8", errors="replace") as fh:
                out += [(rel, ln.rstrip("\n")) for ln in fh]
        except OSError:
            pass
    return out


def changed_protected(project: Path, protected: list[str], ref: str, approved: dict) -> list[str]:
    """Arquivos protegidos alterados desde o último estado aprovado (commitados ou não)."""
    if not protected or not is_git(project):
        return []
    changed = set(_git(project, "diff", ref, "--name-only", "--relative", "--", ".").splitlines())
    changed |= set(_new_untracked(project, approved))
    return sorted(p for p in changed if _match_any(p, protected))


def config_sha(project: Path) -> str | None:
    """Hash do gauntlet.json canônico (CRLF/formatação não contam); JSON quebrado → hash dos bytes."""
    try:
        raw = (project / CONFIG_NAME).read_bytes()
    except OSError:
        return None
    try:
        raw = json.dumps(json.loads(raw.decode("utf-8-sig")), sort_keys=True, ensure_ascii=False).encode("utf-8")
    except (UnicodeDecodeError, ValueError):
        pass
    return hashlib.sha1(raw).hexdigest()


# ------------------------------------------------------------------ avaliação


@dataclass
class Evaluation:
    project: str
    verdict: str  # keep | same | incomplete | regress | fail | baseline
    score: float
    baseline_score: float | None
    gates: dict = field(default_factory=dict)
    metrics: dict = field(default_factory=dict)
    issues: list = field(default_factory=list)
    feedback: list = field(default_factory=list)
    seconds: float = 0.0
    raw_score: float = 0.0
    integrity: dict = field(default_factory=dict)

    @property
    def ok(self) -> bool:
        return self.verdict in ("keep", "same", "incomplete", "baseline")

    def to_dict(self) -> dict:
        d = self.__dict__.copy()
        d["ok"] = self.ok
        return d


def load_config(project: Path) -> dict:
    cfg = _read_json(project / CONFIG_NAME, None)
    if not isinstance(cfg, dict):
        raise ValueError(f"{CONFIG_NAME} inválido em {project}")
    return cfg


class Budget:
    """Orçamento de tempo total da avaliação (o hook tem teto rígido)."""

    def __init__(self, seconds: float | None):
        self.deadline = None if seconds is None else time.time() + seconds

    def cap(self, timeout: float) -> float:
        return timeout if self.deadline is None else min(timeout, self.deadline - time.time())


def _gate_issues(name: str, r: CmdResult) -> tuple[list[str], str]:
    """Pendências de um gate sem junit: uma por diagnóstico `arquivo:linha`, senão uma pelo resumo."""
    lines = r.output.strip().splitlines()
    diags = [ln.strip() for ln in lines if DIAG_RE.match(ln.strip())][:MAX_GATE_ITEMS]
    tail = "\n".join(lines[-OUTPUT_TAIL:])
    if diags:
        return [f"gate {name}: {d}" for d in diags], tail
    return [f"gate {name} falhou (exit {r.code}) #{_short(tail)}"], tail


def _run_gates(cfg: dict, project: Path, ctx: dict, timeout: int, budget: Budget) -> tuple:
    gates: dict = {}
    issues: list[str] = []
    feedback: list[str] = []
    junit = None
    for g in cfg.get("gates", []):
        junit_path = _expand_path(g["junit"], ctx) if g.get("junit") else None
        if junit_path and junit_path.exists():
            junit_path.unlink()  # junit velho de execução anterior não pode ser relido
        r = run_cmd(g["name"], g["cmd"], project, ctx, g.get("env", {}), budget.cap(int(g.get("timeout_s", timeout))))
        gates[g["name"]] = {"ok": r.ok, "code": r.code, "seconds": round(r.seconds, 1)}
        if r.code == -3:  # orçamento esgotado: não é culpa do código → avaliação incompleta
            gates[g["name"]].update(ok=True, skipped=True)
            feedback.append(f"Gate `{g['name']}` não rodou: orçamento de tempo do turno esgotado.")
            continue
        gate_junit = None
        if junit_path and junit_path.exists():
            gate_junit = junit = parse_junit(junit_path)
            gates[g["name"]]["tests"] = gate_junit["tests"]
        if r.ok:
            continue
        if gate_junit and gate_junit["failed"]:
            failed = gate_junit["failed"]
            issues += [f"teste falhou: {f}" for f in failed]
            feedback.append(f"Gate `{g['name']}` falhou — {len(failed)} teste(s):")
            feedback += [f"  - {f}" for f in failed[:MAX_FEEDBACK_ITEMS]]
        else:
            g_issues, tail = _gate_issues(g["name"], r)
            issues += g_issues
            feedback.append(f"Gate `{g['name']}` falhou (exit {r.code}). Saída final:\n{tail}")
    return gates, junit, issues, feedback


def _check_counts(integrity: dict, b: dict) -> tuple[list[str], list[str]]:
    issues: list[str] = []
    feedback: list[str] = []
    if "tests" in integrity and integrity["tests"] < b.get("tests", 0):
        issues.append("testes removidos")
        feedback.append(
            f"Integridade: testes executados caíram de {b['tests']} para {integrity['tests']}. "
            "Não remova testes (test-integrity §1)."
        )
    if integrity.get("skipped", 0) > b.get("skipped", integrity.get("skipped", 0)):
        issues.append("testes pulados")
        feedback.append(f"Integridade: testes pulados subiram de {b['skipped']} para {integrity['skipped']}.")
    if integrity["asserts"] < b.get("asserts", 0):
        issues.append("asserts removidos")
        feedback.append(
            f"Integridade: asserts não triviais caíram de {b['asserts']} para {integrity['asserts']}. "
            "Não enfraqueça asserts; se a spec mudou, peça aceite ao operador."
        )
    return issues, feedback


def _check_integrity(project: Path, integ_cfg: dict, junit: dict | None, baseline: dict | None) -> tuple:
    """Regras de test-integrity.md, comparando com o último estado aprovado (não só HEAD)."""
    test_globs = integ_cfg.get("tests_glob", [])
    ref = base_ref(project, baseline)
    approved = (baseline or {}).get("untracked_ok", {})
    suppress_ignore = DEFAULT_SUPPRESS_IGNORE + integ_cfg.get("suppress_ignore", [])
    integrity = count_test_integrity(project, test_globs) if test_globs else {"asserts": 0}
    if junit:
        integrity["tests"] = junit["tests"] - junit["skipped"]
        integrity["skipped"] = junit["skipped"]
    b = (baseline or {}).get("integrity", {}) if test_globs else {}
    issues, feedback = _check_counts(integrity, b)
    for rel, line in _added_lines(project, ref, approved):
        is_test = bool(test_globs) and _match_any(rel, test_globs)
        if is_test and SKIP_RE.search(line):
            issues.append(f"skip/xfail novo: {rel}: {line.strip()[:160]}")
            feedback.append(f"Integridade: marcador skip/xfail/only novo → {rel}: {line.strip()[:160]}")
        elif not is_test and SUPPRESS_RE.search(line) and not _match_any(rel, suppress_ignore):
            issues.append(f"supressão nova: {rel}: {line.strip()[:160]}")
            feedback.append(
                f"Integridade: comentário que desliga métrica/lint → {rel}: {line.strip()[:160]}. "
                "Resolva o problema em vez de suprimir."
            )
    for path in changed_protected(project, integ_cfg.get("protected", []), ref, approved):
        issues.append(f"arquivo protegido alterado: {path}")
        feedback.append(
            f"Integridade: `{path}` é protegido (avaliador/config) e mudou desde o último estado aprovado. "
            "Reverta, ou peça ao operador para aceitar (`gauntlet.py accept --reason`)."
        )
    return integrity, issues, feedback


def _metric_value(m: dict, project: Path, ctx: dict, timeout: int, budget: Budget) -> tuple:
    src = m.get("source", "regex")
    r = None
    if m.get("cmd"):
        r = run_cmd(m["name"], m["cmd"], project, ctx, m.get("env", {}), budget.cap(int(m.get("timeout_s", timeout))))
    if src == "coverage_json":
        coverage = read_coverage(_expand_path(m["path"], ctx))
        return (coverage.get("total") if coverage else None), {}, coverage
    if src == "ruff_json_count":
        items = ruff_items(r.stdout if r else "")
        return (None, {}, None) if items is None else (float(len(items)), {"items": items}, None)
    if src == "regex":
        mt = re.search(m["regex"], r.output if r else "")
        return (float(mt.group(1)) if mt else None), {}, None
    raise ValueError(f"source desconhecida: {src}")


def _collect_metrics(cfg: dict, project: Path, ctx: dict, timeout: int, budget: Budget) -> tuple:
    metrics: dict = {}
    feedback: list[str] = []
    coverage = None
    total_w = acc = 0.0
    for m in cfg.get("metrics", []):
        value, extra, cov = _metric_value(m, project, ctx, timeout, budget)
        coverage = cov or coverage
        if value is None:
            metrics[m["name"]] = {"value": None, "error": "métrica indisponível"}
            feedback.append(f"Métrica `{m['name']}` indisponível (comando falhou ou saída fora do padrão).")
            continue
        w = float(m.get("weight", 1))
        n = normalize(value, m.get("norm", "percent"))
        metrics[m["name"]] = {"value": round(value, 2), "norm": round(n, 4), "weight": w, **extra}
        total_w += w
        acc += w * n
    raw_score = round(100.0 * acc / total_w, 2) if total_w else 100.0
    return metrics, coverage, raw_score, feedback


def _decide(passed: bool, score: float, baseline: dict | None, rcfg: dict) -> str:
    if not passed:
        return "fail"
    if baseline is None or baseline.get("score") is None:
        return "baseline"
    b_score = baseline["score"]
    if score < b_score - float(rcfg.get("tolerance", 0.3)):
        return "regress"
    if score >= b_score + float(rcfg.get("min_gain", 0.3)):
        return "keep"
    return "same"


def evaluate(project: Path, ratchet: bool = True, budget_s: float | None = None) -> Evaluation:
    t0 = time.time()
    cfg = load_config(project)
    st = state_dir(project)
    ctx = {"python": project_python(project), "state": str(st), "project": str(project)}
    timeout = int(cfg.get("timeout_s", 300))
    budget = Budget(budget_s)
    baseline = _read_json(st / "baseline.json", None)

    # estado ANTES dos gates: arquivo criado por formatter/codegen durante a avaliação não vira "aprovado"
    snap = snapshot(project, cfg.get("integrity", {}).get("protected", []), pin=False)
    for m in cfg.get("metrics", []):  # artefato velho de métrica não pode ser relido
        if m.get("source") == "coverage_json" and m.get("path"):
            _expand_path(m["path"], ctx).unlink(missing_ok=True)
    gates, junit, issues, feedback = _run_gates(cfg, project, ctx, timeout, budget)
    integrity, i_issues, i_feedback = _check_integrity(project, cfg.get("integrity", {}), junit, baseline)
    metrics, coverage, raw_score, m_feedback = _collect_metrics(cfg, project, ctx, timeout, budget)
    issues += i_issues
    feedback += i_feedback + m_feedback

    passed = all(g["ok"] for g in gates.values()) and not i_issues
    score = raw_score if passed else 0.0
    verdict = _decide(passed, score, baseline, cfg.get("ratchet", {}))
    partial = any(m.get("value") is None for m in metrics.values()) or any(g.get("skipped") for g in gates.values())
    if passed and partial:
        # score parcial não é comparável: não move a catraca nem acusa regressão
        verdict = "incomplete"
        if not baseline:
            feedback.append("Baseline ainda não criada: corrija a métrica indisponível para ligar a catraca.")
    b_score = baseline.get("score") if baseline else None
    if verdict == "regress":
        issues.append(f"regressão de score {b_score} → {score}")
        feedback.append(f"Regressão: score {score} < baseline {b_score}.")
        feedback += _regression_details(project, baseline, metrics, coverage)

    ev = Evaluation(
        project=project.name,
        verdict=verdict,
        score=score,
        baseline_score=b_score,
        gates=gates,
        metrics={k: {kk: vv for kk, vv in v.items() if kk != "items"} for k, v in metrics.items()},
        issues=issues,
        feedback=feedback,
        seconds=round(time.time() - t0, 1),
        raw_score=raw_score,
        integrity=integrity,
    )
    if ratchet and ev.ok:
        _update_baseline(st, baseline, ev, metrics, coverage, project, snap)
    _append_history(st, project, ev.verdict, ev.score, ev.baseline_score, len(ev.issues), ev.seconds)
    return ev


def _regression_details(project: Path, baseline: dict, metrics: dict, coverage: dict | None) -> list[str]:
    out = []
    for name, cur in metrics.items():
        old = baseline.get("metrics", {}).get(name, {}).get("value")
        if old is not None and cur.get("value") is not None and cur["value"] != old:
            out.append(f"  - {name}: {old} → {cur['value']}")
    if coverage:
        old_files = baseline.get("coverage_files", {})
        drops = sorted(
            (
                (old_files[f] - pct, f, pct)
                for f, pct in coverage["files"].items()
                if f in old_files and pct < old_files[f] - 0.5
            ),
            reverse=True,
        )
        for _, f, pct in drops[:MAX_FEEDBACK_ITEMS]:
            out.append(f"  - coverage de {f}: {old_files[f]}% → {pct}%")
        ref = base_ref(project, baseline)
        changed = set(_git(project, "diff", ref, "--name-only", "--relative", "--", ".").splitlines())
        changed |= set(_git(project, "ls-files", "--others", "--exclude-standard").splitlines())
        for f in sorted(changed):
            miss = coverage["missing"].get(f)
            if miss:
                lines = ", ".join(map(str, miss[:20])) + (" …" if len(miss) > 20 else "")
                out.append(f"  - {f} (alterado): linhas sem teste {lines}")
    for name, cur in metrics.items():
        items = cur.get("items")
        if items:
            old = set(baseline.get("metric_items", {}).get(name, []))
            new = [i for i in items if i not in old]
            out += [f"  - {name} novo: {i}" for i in new[:MAX_FEEDBACK_ITEMS]]
    return out


def _update_baseline(st: Path, baseline, ev: Evaluation, metrics, coverage, project: Path, snap: dict) -> None:
    b = dict(baseline or {})
    # estado aprovado: integridade passou → vira a nova referência (commitar depois não esconde nada)
    if snap.get("ref"):
        pin_ref(project, snap["ref"])
    b.update(snap)
    b["config_sha"] = config_sha(project)
    # integridade: catraca independente do score (contagens só sobem)
    bi = dict(b.get("integrity", {}))
    for k, v in ev.integrity.items():
        if k == "skipped":
            bi[k] = min(v, bi.get(k, v))
        else:
            bi[k] = max(v, bi.get(k, 0))
    b["integrity"] = bi
    if ev.verdict in ("keep", "baseline"):
        b["score"] = ev.score
        b["metrics"] = {k: {"value": v.get("value")} for k, v in metrics.items()}
        b["metric_items"] = {k: v["items"] for k, v in metrics.items() if v.get("items") is not None}
        if coverage:
            b["coverage_files"] = coverage["files"]
        b["updated"] = time.strftime("%Y-%m-%dT%H:%M:%S")
        b["commit"] = _git(project, "rev-parse", "HEAD").strip()
    _write_json(st / "baseline.json", b)


def _append_history(st: Path, project: Path, verdict: str, score, baseline, issues: int, seconds) -> None:
    hist = st / "history.tsv"
    new = not hist.exists()
    with hist.open("a", encoding="utf-8") as fh:
        if new:
            fh.write("timestamp\tcommit\tverdict\tscore\tbaseline\tissues\tseconds\n")
        commit = _git(project, "rev-parse", "--short", "HEAD").strip() or "-"
        fh.write(
            f"{time.strftime('%Y-%m-%dT%H:%M:%S')}\t{commit}\t{verdict}\t{score}\t{baseline}\t{issues}\t{seconds}\n"
        )


def render(ev: Evaluation) -> str:
    icon = {"keep": "✅", "same": "✅", "incomplete": "❔", "baseline": "🆕", "regress": "⚠️", "fail": "❌"}[ev.verdict]
    delta = ""
    if ev.baseline_score is not None and ev.verdict != "fail":
        delta = f" (baseline {ev.baseline_score}, {ev.score - ev.baseline_score:+.2f})"
    lines = [f"🧪 Gauntlet {ev.project}: {icon} {ev.verdict} — score {ev.score}{delta} em {ev.seconds}s"]
    for name, g in ev.gates.items():
        extra = f", {g['tests']} testes" if "tests" in g else ""
        lines.append(f"  gate {name}: {'PASS' if g['ok'] else 'FAIL'} ({g['seconds']}s{extra})")
    for name, m in ev.metrics.items():
        if m.get("value") is not None:
            lines.append(f"  métrica {name}: {m['value']} (norm {m['norm']}, peso {m['weight']})")
    if ev.feedback:
        lines.append("")
        lines += ev.feedback
    return "\n".join(lines)


# --------------------------------------------------------------------- lock


class Lock:
    """Lock por arquivo com dono: só apaga o lock que criou."""

    def __init__(self, project: Path):
        self.path = state_dir(project) / "lock"
        self.token = f"{os.getpid()}-{uuid.uuid4().hex}"
        self.held = False

    def __enter__(self):
        try:
            if self.path.exists() and time.time() - self.path.stat().st_mtime > LOCK_STALE_S:
                self.path.unlink()
            fd = os.open(self.path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            os.write(fd, self.token.encode())
            os.close(fd)
            self.held = True
        except OSError:
            self.held = False
        return self

    def __exit__(self, *exc):
        if not self.held:
            return
        try:
            if self.path.read_text(encoding="utf-8") == self.token:
                self.path.unlink()
        except OSError:
            pass


# ---------------------------------------------------------------------- hook


def _session_cache_dir() -> Path:
    return Path(os.environ.get("GAUNTLET_CACHE_DIR") or Path.home() / ".claude" / "gauntlet-sessions")


def _scan_transcript(transcript: str | None, session: str) -> tuple[set[Path], bool]:
    """Arquivos editados (Edit/Write/...) e se a sessão rodou ferramenta que muda arquivo.

    Lê só o trecho novo do transcript (offset em cache): custo constante por turno.
    """
    if not transcript:
        return set(), False
    cache_path = _session_cache_dir() / f"{_short(session + transcript)}.json"
    cache = _read_json(cache_path, {})
    offset = int(cache.get("offset", 0))
    paths = set(cache.get("paths", []))
    mutated = bool(cache.get("mutated", False))
    try:
        size = os.path.getsize(transcript)
        if size < offset:  # transcript reescrito (compactação): relê do zero
            offset, paths, mutated = 0, set(), False
        with open(transcript, "rb") as fh:
            fh.seek(offset)
            chunk = fh.read()
        complete = chunk.rfind(b"\n") + 1  # só linhas inteiras; o resto fica p/ o próximo turno
        for raw in chunk[:complete].splitlines():
            if b'"tool_use"' not in raw:
                continue
            try:
                content = (json.loads(raw).get("message") or {}).get("content")
            except ValueError:
                continue
            for c in content if isinstance(content, list) else []:
                if not (isinstance(c, dict) and c.get("type") == "tool_use"):
                    continue
                name = c.get("name", "")
                inp = c.get("input") or {}
                cmd = str(inp.get("command", ""))
                mutated = mutated or name in EDIT_TOOLS or (name in SHELL_TOOLS and bool(MUTATING_CMD_RE.search(cmd)))
                fp = inp.get("file_path") or inp.get("notebook_path")
                if name in EDIT_TOOLS and fp:
                    paths.add(str(fp))
        cache = {"offset": offset + complete, "paths": sorted(paths), "mutated": mutated}
        _write_json(cache_path, cache)
    except OSError as exc:
        _log(f"transcript ilegível {transcript}: {exc!r}")
    return {Path(p) for p in paths}, mutated


def _candidate_projects(payload: dict, session: str) -> list[Path]:
    found: dict[str, Path] = {}

    def add(p: Path | None):
        if p:
            found[str(p.resolve()).lower()] = p.resolve()

    paths, mutated = _scan_transcript(payload.get("transcript_path"), session)
    for p in paths:
        add(find_project(p))
    cwd = payload.get("cwd")
    if cwd and (mutated or not payload.get("transcript_path")):
        add(find_project(Path(cwd)))  # só se a sessão mudou arquivo (Edit/Write ou shell que escreve)
    for root in payload.get("workspace_roots") or []:  # Cursor: sem transcript
        r = Path(root)
        add(find_project(r))
        try:
            for child in r.iterdir():
                if child.is_dir() and (child / CONFIG_NAME).is_file():
                    add(child)
        except OSError:
            pass
    return list(found.values())


def _judge_failure(project: Path, ev: Evaluation, sess: dict, max_blocks: int) -> tuple[str | None, str | None]:
    """Bloquear (agente continua) ou liberar. Progresso = alguma pendência anterior sumiu (I(t) > 0)."""
    current = sorted({_short(i) for i in ev.issues})
    prev = sess.get("prev")
    resolved = len(set(prev) - set(current)) if prev is not None else None
    sess["prev"] = current
    sess["blocks"] += 1
    sess["total"] = sess.get("total", 0) + 1
    stagnant = resolved == 0
    cap = max_blocks * 2  # teto por sessão: teste flaky não cicla bloco→ok→bloco para sempre
    if sess["blocks"] > max_blocks or stagnant or sess["total"] > cap:
        if stagnant:
            why = "estagnação (nenhuma pendência resolvida)"
        elif sess["total"] > cap:
            why = f"teto de {cap} bloqueios na sessão"
        else:
            why = f"limite de {max_blocks} tentativas"
        sess["blocks"], sess["prev"] = 0, None
        return None, (
            f"⚠️ Gauntlet {project.name}: {why} — liberando com pendências. "
            f"Relate ao operador: {'; '.join(ev.issues[:5])}"
        )
    return (
        render(ev) + f"\n\nTentativa {sess['blocks']}/{max_blocks}. Corrija o CÓDIGO, não os testes "
        "(rules/test-integrity.md). Não edite gauntlet.json nem arquivos protegidos. "
        "Depois de corrigir, finalize de novo: o gauntlet roda sozinho."
    ), None


def _hook_settings(project: Path) -> dict | None:
    """Config do hook do projeto, ou None se o gauntlet.json é ilegível ou o hook está desligado."""
    try:
        hcfg = load_config(project).get("hook", {})
    except ValueError:
        return None
    return hcfg if hcfg.get("enabled", True) else None


def _tamper_eval(project: Path, baseline: dict | None) -> Evaluation | None:
    """gauntlet.json diferente do último estado aprovado (inclusive quebrado ou `enabled: false`) → fail."""
    expected = (baseline or {}).get("config_sha")
    if not expected or config_sha(project) == expected:
        return None
    msg = (
        f"Integridade: `{CONFIG_NAME}` mudou desde o último estado aprovado (avaliador desligado, quebrado ou "
        "alterado). Reverta, ou peça ao operador para aceitar (`gauntlet.py accept --reason`)."
    )
    return Evaluation(
        project=project.name,
        verdict="fail",
        score=0.0,
        baseline_score=(baseline or {}).get("score"),
        issues=[f"arquivo protegido alterado: {CONFIG_NAME}"],
        feedback=[msg],
    )


def _evaluate_locked(project: Path, fp: str, budget_s: float) -> tuple[Evaluation | None, str | None]:
    with Lock(project) as lk:
        if not lk.held:
            return None, f"Gauntlet {project.name}: outra avaliação em andamento — pulei."
        try:
            return evaluate(project, budget_s=budget_s), None
        except Exception as exc:  # config/coverage malformado: registra e não reavalia o mesmo estado
            _log(f"avaliação falhou em {project}: {exc!r}")
            st = state_dir(project)
            state = _read_json(st / "state.json", {})
            state.update(last_fp=fp, last_ok=True)
            _write_json(st / "state.json", state)
            return None, f"⚠️ Gauntlet {project.name}: erro no avaliador ({exc.__class__.__name__}) — ver log."


def _hook_project(project: Path, session: str, budget_s: float) -> tuple[str | None, str | None]:
    """Avalia um projeto no Stop. Retorna (motivo_de_bloqueio, nota_para_o_usuário)."""
    st = state_dir(project)
    tampered = _tamper_eval(project, _read_json(st / "baseline.json", None))
    hcfg = {"max_blocks": 3} if tampered else _hook_settings(project)
    if hcfg is None:
        return None, None
    state = _read_json(st / "state.json", {})
    notes = []
    if state.get("accept_notice"):
        notes.append(f"⚠️ Gauntlet {project.name}: baseline rebaixada por accept — {state.get('last_accept', '')}")
    fp = fingerprint(project)
    if fp == state.get("last_fp"):
        if not state.get("last_ok", True):
            # parou de novo sem mudar nada depois de um bloqueio: I(t)=0 → libera uma vez
            state["last_ok"] = True
            notes.append(f"⚠️ Gauntlet {project.name}: pendências sem mudança desde a última avaliação — liberando.")
        if notes:
            state.pop("accept_notice", None)
            _write_json(st / "state.json", state)
        return None, "\n".join(notes) or None

    ev, note = (tampered, None) if tampered else _evaluate_locked(project, fp, budget_s)
    if ev is not None:
        block, note = _record_result(project, session, ev, int(hcfg.get("max_blocks", 3)))
    else:
        block = None
    if note:
        notes.append(note)
    return block, "\n".join(notes) or None


def _record_result(project: Path, session: str, ev: Evaluation, max_blocks: int) -> tuple:
    """Relê o state.json (outra sessão pode ter gravado), aplica o resultado e decide bloqueio/nota."""
    path = state_dir(project) / "state.json"
    state = _read_json(path, {})
    state.pop("accept_notice", None)  # já mostrado neste turno
    sessions = state.setdefault("sessions", {})
    sess = sessions.setdefault(session, {"blocks": 0, "prev": None, "total": 0})
    state.update(last_fp=fingerprint(project), last_ok=ev.ok, last_score=ev.score)
    if ev.ok:
        # verde zera a sequência; 3 verdes seguidos zeram o teto da sessão
        # (flaky alterna falha/verde e nunca chega a 3 → o teto continua valendo para ele)
        sess["blocks"], sess["prev"] = 0, None
        sess["greens"] = sess.get("greens", 0) + 1
        if sess["greens"] >= GREENS_TO_RESET:
            sess["total"] = 0
        block, note = None, render(ev).splitlines()[0]
    else:
        sess["greens"] = 0
        block, note = _judge_failure(project, ev, sess, max_blocks)
    for old in list(sessions)[:-20]:  # guarda só as 20 sessões mais recentes
        sessions.pop(old, None)
    _write_json(path, state)
    return block, note


def _prune_cache() -> None:
    cutoff = time.time() - CACHE_TTL_S
    try:
        for f in _session_cache_dir().glob("*.json"):
            if f.stat().st_mtime < cutoff:
                f.unlink()
    except OSError:
        pass


def hook_main(raw: str) -> dict:
    payload = json.loads(raw or "{}")
    is_cursor = "workspace_roots" in payload or "loop_count" in payload
    if is_cursor and payload.get("status") not in (None, "completed"):
        return {}
    session = str(payload.get("session_id") or payload.get("conversation_id") or "default")
    deadline = time.time() + HOOK_BUDGET_S
    blocks: list[str] = []
    notes: list[str] = []
    _prune_cache()
    for project in _candidate_projects(payload, session):
        remaining = deadline - time.time()
        if remaining < MIN_PROJECT_BUDGET_S:
            notes.append(f"Gauntlet {project.name}: sem tempo neste turno — avalia no próximo.")
            continue
        block, note = _hook_project(project, session, remaining)
        if block:
            blocks.append(block)
        if note:
            notes.append(note)
    if blocks:
        reason = "\n\n---\n\n".join(blocks)
        return {"followup_message": reason} if is_cursor else {"decision": "block", "reason": reason}
    if notes and not is_cursor:
        return {"systemMessage": "\n".join(notes)}
    return {}


# ---------------------------------------------------------------------- init


def _python_config() -> dict:
    return {
        "stack": "python",
        "gates": [
            {
                "name": "pytest",
                "cmd": [
                    "{python}",
                    "-m",
                    "pytest",
                    "-q",
                    "-p",
                    "no:cacheprovider",
                    "--cov=.",
                    "--cov-report=json:{state}/coverage.json",
                    "--junitxml={state}/junit.xml",
                ],
                "env": {"COVERAGE_FILE": "{state}/.coverage", "COVERAGE_RCFILE": "{project}/" + COVERAGE_RC},
                "junit": "{state}/junit.xml",
            },
            {"name": "ruff", "cmd": ["{python}", "-m", "ruff", "check", ".", "--output-format", "concise"]},
        ],
        "metrics": [
            {"name": "coverage", "source": "coverage_json", "path": "{state}/coverage.json", "weight": 70},
            {
                "name": "complexidade_c901",
                "cmd": [
                    "{python}",
                    "-m",
                    "ruff",
                    "check",
                    ".",
                    "--select",
                    "C901",
                    "--output-format=json",
                    "--exit-zero",
                ],
                "source": "ruff_json_count",
                "weight": 30,
                "norm": {"type": "inverse", "k": 20},
            },
        ],
        "integrity": {
            "tests_glob": ["tests/**/*.py", "**/test_*.py", "**/*_test.py"],
            "protected": [
                "gauntlet.json",
                COVERAGE_RC,
                "**/pytest.ini",
                "pyproject.toml",
                "setup.cfg",
                "tox.ini",
                "**/.coveragerc",
                "**/ruff.toml",
                "**/.ruff.toml",
                ".flake8",
                ".github/workflows/*",
            ],
        },
    }


def _node_config() -> dict:
    return {
        "stack": "node",
        "gates": [{"name": "test", "cmd": "npm test --silent"}, {"name": "typecheck", "cmd": "npx tsc --noEmit"}],
        "metrics": [],
        "integrity": {
            "tests_glob": ["**/*.test.*", "**/*.spec.*", "**/__tests__/**"],
            "protected": [
                "gauntlet.json",
                "**/jest.config.*",
                "**/vitest.config.*",
                "**/tsconfig*.json",
                "**/.eslintrc*",
                "**/eslint.config.*",
                ".github/workflows/*",
            ],
        },
    }


def _go_config() -> dict:
    return {
        "stack": "go",
        "gates": [
            {"name": "go-test", "cmd": ["go", "test", "-race", "./..."]},
            {"name": "go-vet", "cmd": ["go", "vet", "./..."]},
        ],
        "metrics": [],
        "integrity": {
            "tests_glob": ["**/*_test.go"],
            "protected": ["gauntlet.json", "**/.golangci.yml", ".github/workflows/*"],
        },
    }


def init_config(project: Path) -> dict:
    p = project
    if (p / "pytest.ini").exists() or ((p / "tests").is_dir() and any(p.glob("*.py"))):
        body = _python_config()
    elif (p / "package.json").exists():
        body = _node_config()
    elif (p / "go.mod").exists():
        body = _go_config()
    else:
        raise ValueError("stack não detectado (sem pytest.ini/tests, package.json ou go.mod)")
    return {
        "version": 1,
        "timeout_s": 600,
        **body,
        "ratchet": {"min_gain": 0.3, "tolerance": 0.3},
        "hook": {"enabled": True, "max_blocks": 3},
    }


# ----------------------------------------------------------------------- CLI


def _cmd_hook() -> int:
    try:
        sys.stdin.reconfigure(encoding="utf-8")  # type: ignore[attr-defined]
        out = hook_main(sys.stdin.read())
    except Exception as exc:  # fail-open: hook nunca derruba a sessão
        _log(f"hook erro: {exc!r}")
        out = {}
    if out:
        sys.stdout.write(json.dumps(out, ensure_ascii=False))
    return 0


def _cmd_init(start: Path) -> int:
    if (start / CONFIG_NAME).exists():
        print(f"{CONFIG_NAME} já existe em {start}")
        return 0
    cfg = init_config(start)
    _write_json(start / CONFIG_NAME, cfg)
    if cfg["stack"] == "python" and not (start / COVERAGE_RC).exists():
        (start / COVERAGE_RC).write_text(COVERAGE_RC_BODY, encoding="utf-8")
    print(f"criado {start / CONFIG_NAME}; commite-o (e o {COVERAGE_RC}, se houver) e rode `run`")
    return 0


def _cmd_status(project: Path) -> int:
    st = state_dir(project)
    print(json.dumps(_read_json(st / "baseline.json", {}), indent=2, ensure_ascii=False)[:4000])
    hist = st / "history.tsv"
    if hist.exists():
        print("\n".join(hist.read_text(encoding="utf-8").splitlines()[-10:]))
    return 0


def _cmd_accept(project: Path, reason: str | None) -> int:
    """Rebaixa a baseline para o estado atual. Uso exclusivo com aceite do operador; fica auditado."""
    if not reason or len(reason.strip()) < 10:
        print("accept exige --reason com o motivo do operador (mín. 10 caracteres).", file=sys.stderr)
        return 1
    with Lock(project) as lk:
        if not lk.held:
            print("outra avaliação em andamento; tente de novo", file=sys.stderr)
            return 4
        ev = evaluate(project, ratchet=False)
        refusal = None
        if any(not g["ok"] or g.get("skipped") for g in ev.gates.values()):
            refusal = "gates falhando ou não executados"
        elif any(m.get("value") is None for m in ev.metrics.values()):
            refusal = "métrica indisponível (score parcial)"
        if refusal:
            print(render(ev))
            print(f"\naccept recusado: {refusal}.")
            return 1
        st = state_dir(project)
        cfg = load_config(project)
        b = {
            "score": ev.raw_score,
            "metrics": {k: {"value": v.get("value")} for k, v in ev.metrics.items()},
            "integrity": ev.integrity,
            "commit": _git(project, "rev-parse", "HEAD").strip(),
            "config_sha": config_sha(project),
            "accepted": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "accept_reason": reason.strip(),
            # o estado atual (inclusive não commitado) vira o aprovado
            **snapshot(project, cfg.get("integrity", {}).get("protected", [])),
        }
        _write_json(st / "baseline.json", b)
        state = _read_json(st / "state.json", {})
        state.update(accept_notice=True, last_accept=reason.strip(), last_fp=None)
        _write_json(st / "state.json", state)
        _append_history(st, project, "accept", ev.raw_score, ev.baseline_score, len(ev.issues), ev.seconds)
    print(f"baseline redefinida por aceite do operador: score {ev.raw_score} — motivo: {reason.strip()}")
    return 0


def _cmd_run(project: Path, as_json: bool, ratchet: bool) -> int:
    with Lock(project) as lk:
        if not lk.held:
            print("outra avaliação em andamento", file=sys.stderr)
            return 4
        ev = evaluate(project, ratchet=ratchet)
    print(json.dumps(ev.to_dict(), ensure_ascii=False, indent=2) if as_json else render(ev))
    return 0 if ev.ok else (2 if ev.verdict == "regress" else 1)


def main(argv: list[str] | None = None) -> int:
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
        except (AttributeError, ValueError):
            pass
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("command", choices=["init", "run", "status", "accept", "hook"])
    ap.add_argument("--project", default=".")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--no-ratchet", action="store_true")
    ap.add_argument("--reason", help="motivo do operador (obrigatório no accept)")
    args = ap.parse_args(argv)

    if args.command == "hook":
        return _cmd_hook()
    start = Path(args.project).resolve()
    if args.command == "init":
        return _cmd_init(start)
    project = find_project(start)
    if not project:
        print(f"nenhum {CONFIG_NAME} em {start} ou acima", file=sys.stderr)
        return 3
    if args.command == "status":
        return _cmd_status(project)
    if args.command == "accept":
        return _cmd_accept(project, args.reason)
    return _cmd_run(project, args.json, not args.no_ratchet)


if __name__ == "__main__":
    sys.exit(main())
