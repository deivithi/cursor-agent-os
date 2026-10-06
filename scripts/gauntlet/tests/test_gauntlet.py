"""Testes do gauntlet: catraca, gates, integridade, hook Stop e achados da revisão adversarial."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import gauntlet as g  # noqa: E402

FAKE_SUITE = """
import pathlib, sys
root = pathlib.Path(".")
fail = (root / "FAIL").exists()
out = pathlib.Path(sys.argv[1])
case_fail = '<failure message="assert 1 == 2">trace</failure>' if fail else ""
n = int((root / "NTESTS").read_text()) if (root / "NTESTS").exists() else 2
cases = "".join(f'<testcase classname="tests.test_x" name="t{i}"/>' for i in range(n - 1))
cases += f'<testcase classname="tests.test_x" name="t_calc">{case_fail}</testcase>'
out.write_text(f'<testsuites><testsuite tests="{n}">{cases}</testsuite></testsuites>')
sys.exit(1 if fail else 0)
"""

# "linter" falso: imprime um diagnóstico arquivo:linha por linha de LINT.txt e falha se houver algum
FAKE_LINT = """
import pathlib, sys
p = pathlib.Path("LINT.txt")
lines = [ln for ln in p.read_text().splitlines() if ln.strip()] if p.exists() else []
for ln in lines:
    print(ln)
sys.exit(1 if lines else 0)
"""

TEST_BODY = "def test_a():\n    assert soma(1, 1) == 2\n    assert soma(2, 2) == 4\n"


def _git(repo: Path, *args: str) -> None:
    subprocess.run(
        ["git", "-c", "user.email=t@t", "-c", "user.name=t", "-C", str(repo), *args],
        check=True,
        capture_output=True,
    )


@pytest.fixture(autouse=True)
def _cache_isolado(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("GAUNTLET_CACHE_DIR", str(tmp_path / "cache"))


@pytest.fixture()
def proj(tmp_path: Path) -> Path:
    p = tmp_path / "proj"
    (p / "tests").mkdir(parents=True)
    (p / "suite.py").write_text(FAKE_SUITE, encoding="utf-8")
    (p / "lint.py").write_text(FAKE_LINT, encoding="utf-8")
    (p / "metric.txt").write_text("80", encoding="utf-8")
    (p / "tests" / "test_x.py").write_text(TEST_BODY, encoding="utf-8")
    cfg = {
        "version": 1,
        "gates": [
            {"name": "suite", "cmd": ["{python}", "suite.py", "{state}/junit.xml"], "junit": "{state}/junit.xml"},
            {"name": "lint", "cmd": ["{python}", "lint.py"]},
        ],
        "metrics": [
            {
                "name": "cov",
                "cmd": ["{python}", "-c", "print('VALUE=' + open('metric.txt').read())"],
                "source": "regex",
                "regex": r"VALUE=([\d.]+)",
                "weight": 1,
                "norm": "percent",
            }
        ],
        "integrity": {"tests_glob": ["tests/**/*.py"], "protected": ["gauntlet.json", "**/ruff.toml"]},
        "ratchet": {"min_gain": 0.5, "tolerance": 0.5},
        "hook": {"enabled": True, "max_blocks": 3},
    }
    (p / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    _git(p, "init", "-q")
    _git(p, "add", "-A")
    _git(p, "commit", "-qm", "init")
    return p


def _metric(p: Path, v: str) -> None:
    (p / "metric.txt").write_text(v, encoding="utf-8")


def _hook(payload: dict) -> dict:
    return g.hook_main(json.dumps(payload))


# ------------------------------------------------------------------ catraca


def test_primeira_execucao_cria_baseline(proj: Path) -> None:
    ev = g.evaluate(proj)
    assert ev.verdict == "baseline"
    assert ev.score == 80.0
    base = json.loads((proj / ".gauntlet" / "baseline.json").read_text(encoding="utf-8"))
    assert base["score"] == 80.0
    assert base["integrity"] == {"asserts": 2, "tests": 2, "skipped": 0}
    assert len(base["commit"]) == 40


def test_catraca_keep_same_regress(proj: Path) -> None:
    g.evaluate(proj)
    _metric(proj, "80.2")
    assert g.evaluate(proj).verdict == "same"  # dentro do ruído: baseline não sobe
    _metric(proj, "85")
    ev = g.evaluate(proj)
    assert ev.verdict == "keep" and ev.baseline_score == 80.0
    _metric(proj, "82")
    ev = g.evaluate(proj)
    assert ev.verdict == "regress"
    assert ev.baseline_score == 85.0  # catraca: baseline ficou no melhor valor
    assert any("cov: 85.0 → 82.0" in f for f in ev.feedback)


def test_state_dir_se_auto_ignora(proj: Path) -> None:
    g.evaluate(proj)
    status = subprocess.run(["git", "-C", str(proj), "status", "--porcelain"], capture_output=True, text=True).stdout
    assert ".gauntlet" not in status


def test_no_ratchet_nao_altera_baseline(proj: Path) -> None:
    g.evaluate(proj)
    _metric(proj, "95")
    assert g.evaluate(proj, ratchet=False).verdict == "keep"
    assert g.evaluate(proj).baseline_score == 80.0


def test_history_registra_cada_execucao(proj: Path) -> None:
    g.evaluate(proj)
    g.evaluate(proj)
    lines = (proj / ".gauntlet" / "history.tsv").read_text(encoding="utf-8").splitlines()
    assert lines[0].startswith("timestamp\tcommit\tverdict")
    assert len(lines) == 3


def test_metrica_indisponivel_nao_move_catraca(proj: Path) -> None:
    g.evaluate(proj)
    _metric(proj, "sem numero")
    ev = g.evaluate(proj)
    assert ev.metrics["cov"]["value"] is None
    assert ev.verdict == "incomplete" and ev.ok
    base = json.loads((proj / ".gauntlet" / "baseline.json").read_text(encoding="utf-8"))
    assert base["score"] == 80.0


def test_incompleto_sem_baseline_avisa(proj: Path) -> None:
    _metric(proj, "sem numero")
    ev = g.evaluate(proj)
    assert ev.verdict == "incomplete"
    assert any("Baseline ainda não criada" in f for f in ev.feedback)


# -------------------------------------------------------------------- gates


def test_gate_falho_zera_score_e_lista_teste(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "FAIL").write_text("1")
    ev = g.evaluate(proj)
    assert ev.verdict == "fail" and ev.score == 0.0 and not ev.ok
    assert any("tests.test_x::t_calc" in f and "assert 1 == 2" in f for f in ev.feedback)


def test_gate_sem_junit_gera_uma_pendencia_por_diagnostico(proj: Path) -> None:
    (proj / "LINT.txt").write_text("app.py:1:1 E1 a\napp.py:2:1 E2 b\napp.py:3:1 E3 c\n")
    ev = g.evaluate(proj)
    assert sum(i.startswith("gate lint: app.py:") for i in ev.issues) == 3


def test_gate_sem_diagnostico_usa_resumo_com_hash(proj: Path) -> None:
    (proj / "LINT.txt").write_text("erro genérico sem arquivo\n")
    ev = g.evaluate(proj)
    assert any(i.startswith("gate lint falhou (exit 1) #") for i in ev.issues)


def test_timeout_mata_arvore_de_processos(tmp_path: Path) -> None:
    """Achado 4: no Windows o neto segurava o pipe e o timeout não funcionava."""
    neto = "import subprocess, sys, time; subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(60)']); "
    neto += "time.sleep(60)"
    ctx = {"python": sys.executable, "state": str(tmp_path), "project": str(tmp_path)}
    t0 = time.time()
    r = g.run_cmd("lento", ["{python}", "-c", neto], tmp_path, ctx, {}, 3)
    assert not r.ok and r.code == -1 and "TIMEOUT" in r.output
    assert time.time() - t0 < 30


def test_orcamento_esgotado_nao_roda(tmp_path: Path) -> None:
    ctx = {"python": sys.executable, "state": str(tmp_path), "project": str(tmp_path)}
    r = g.run_cmd("x", ["{python}", "-c", "print(1)"], tmp_path, ctx, {}, 0.5)
    assert r.code == -3


# --------------------------------------------------------------- integridade


def test_remover_assert_falha(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "tests" / "test_x.py").write_text("def test_a():\n    assert soma(1, 1) == 2\n", encoding="utf-8")
    ev = g.evaluate(proj)
    assert ev.verdict == "fail" and "asserts removidos" in ev.issues


def test_assert_trivial_nao_compensa_assert_removido(proj: Path) -> None:
    """Achado 9: trocar assert real por `assert True` não mantém a contagem."""
    g.evaluate(proj)
    body = "def test_a():\n    assert soma(1, 1) == 2\n    assert True\n    assert 1\n"
    (proj / "tests" / "test_x.py").write_text(body, encoding="utf-8")
    assert "asserts removidos" in g.evaluate(proj).issues


def test_remover_teste_falha(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "NTESTS").write_text("1")
    ev = g.evaluate(proj)
    assert ev.verdict == "fail" and "testes removidos" in ev.issues


def test_skip_novo_falha(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "tests" / "test_x.py").write_text("import pytest\n@pytest.mark.skip\n" + TEST_BODY, encoding="utf-8")
    assert any(i.startswith("skip/xfail novo") for i in g.evaluate(proj).issues)


def test_alterar_arquivo_protegido_falha(proj: Path) -> None:
    g.evaluate(proj)
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["ratchet"]["tolerance"] = 99
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    assert "arquivo protegido alterado: gauntlet.json" in g.evaluate(proj).issues


def test_commit_nao_apaga_checagem_de_integridade(proj: Path) -> None:
    """Achado 2: editar protegido + skip e commitar continuava passando (diff só vs HEAD)."""
    g.evaluate(proj)
    (proj / "sub").mkdir()
    (proj / "sub" / "ruff.toml").write_text("[lint]\nignore = ['ALL']\n")
    (proj / "tests" / "test_x.py").write_text("import pytest\n@pytest.mark.skipif(True, reason='x')\n" + TEST_BODY)
    _git(proj, "add", "-A")
    _git(proj, "commit", "-qm", "esconde")
    ev = g.evaluate(proj)
    assert "arquivo protegido alterado: sub/ruff.toml" in ev.issues
    assert any(i.startswith("skip/xfail novo") for i in ev.issues)


def test_supressao_nova_em_codigo_de_producao_falha(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "app.py").write_text("def f():  # noqa: C901\n    return 1  # pragma: no cover\n", encoding="utf-8")
    ev = g.evaluate(proj)
    assert sum(i.startswith("supressão nova: app.py") for i in ev.issues) == 2


def test_noqa_especifico_e_permitido(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "app.py").write_text("import os  # noqa: F401\n", encoding="utf-8")
    assert not any(i.startswith("supressão") for i in g.evaluate(proj).issues)


def test_adicionar_testes_sobe_catraca_de_integridade(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "NTESTS").write_text("5")
    assert g.evaluate(proj).ok
    (proj / "NTESTS").write_text("3")
    assert "testes removidos" in g.evaluate(proj).issues


def test_projeto_aninhado_usa_caminhos_relativos(tmp_path: Path, proj: Path) -> None:
    repo = tmp_path / "mono"
    shutil.copytree(proj, repo / "sub", ignore=shutil.ignore_patterns(".git", ".gauntlet"))
    (repo / "outro.txt").write_text("a")
    _git(repo, "init", "-q")
    _git(repo, "add", "-A")
    _git(repo, "commit", "-qm", "init")
    sub = repo / "sub"
    assert g.evaluate(sub).verdict == "baseline"
    fp = g.fingerprint(sub)
    (repo / "outro.txt").write_text("mudou fora do projeto")
    assert g.fingerprint(sub) == fp
    cfg = json.loads((sub / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["hook"]["max_blocks"] = 9
    (sub / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    assert "arquivo protegido alterado: gauntlet.json" in g.evaluate(sub).issues


def test_projeto_sem_git_usa_fingerprint_por_arquivo(tmp_path: Path) -> None:
    p = tmp_path / "solto"
    p.mkdir()
    (p / "a.py").write_text("x = 1")
    fp = g.fingerprint(p)
    assert fp.startswith("nogit-")
    time.sleep(0.01)
    (p / "a.py").write_text("x = 2")
    assert g.fingerprint(p) != fp


def test_nome_com_acento_entra_no_fingerprint(proj: Path) -> None:
    (proj / "relatório.py").write_text("a")
    fp = g.fingerprint(proj)
    (proj / "relatório.py").write_text("ab")
    assert g.fingerprint(proj) != fp


# --------------------------------------------------------------------- hook


def test_hook_ignora_sessao_sem_projeto(tmp_path: Path) -> None:
    assert _hook({"session_id": "s", "cwd": str(tmp_path)}) == {}


def test_hook_ciclo_completo(proj: Path) -> None:
    base = {"session_id": "s1", "cwd": str(proj)}
    assert "Gauntlet proj" in _hook(base)["systemMessage"]
    assert _hook(base) == {}  # nada mudou: não reroda

    (proj / "FAIL").write_text("1")
    out = _hook(base)
    assert out["decision"] == "block"
    assert "t_calc" in out["reason"] and "Tentativa 1/3" in out["reason"]

    out = _hook(base)  # parar de novo sem mudar nada → libera uma vez
    assert "decision" not in out and "sem mudança" in out["systemMessage"]
    assert _hook(base) == {}  # e depois silencia

    (proj / "FAIL").unlink()
    assert "decision" not in _hook(base)


def test_hook_libera_por_estagnacao(proj: Path) -> None:
    base = {"session_id": "s2", "cwd": str(proj)}
    _hook(base)
    (proj / "FAIL").write_text("1")
    assert _hook(base)["decision"] == "block"
    (proj / "outro.txt").write_text("mudou mas não corrigiu")
    out = _hook(base)
    assert "decision" not in out and "estagnação" in out["systemMessage"]


def test_hook_progresso_parcial_continua_bloqueando(proj: Path) -> None:
    """Achado 1: corrigir 2 de 3 erros do lint é progresso, não estagnação."""
    base = {"session_id": "s5", "cwd": str(proj)}
    _hook(base)
    (proj / "LINT.txt").write_text("app.py:1:1 E1\napp.py:2:1 E2\napp.py:3:1 E3\n")
    assert _hook(base)["decision"] == "block"
    (proj / "LINT.txt").write_text("app.py:3:1 E3\n")
    out = _hook(base)
    assert out["decision"] == "block" and "Tentativa 2/3" in out["reason"]


def test_hook_teto_por_sessao_contra_flaky(proj: Path) -> None:
    base = {"session_id": "s6", "cwd": str(proj)}
    _hook(base)
    for i in range(6):
        (proj / "FAIL").write_text("1")
        (proj / "LINT.txt").write_text(f"app.py:{i}:1 E{i}\n")  # pendência nova a cada vez: não estagna
        assert _hook(base).get("decision") == "block"
        (proj / "FAIL").unlink()
        (proj / "LINT.txt").unlink()
        assert "decision" not in _hook(base)
    (proj / "FAIL").write_text("1")
    out = _hook(base)
    assert "decision" not in out and "teto" in out["systemMessage"]


def _transcript(tmp_path: Path, *uses: tuple[str, str]) -> Path:
    tr = tmp_path / "t.jsonl"
    with tr.open("a", encoding="utf-8") as fh:
        for name, fp in uses:
            content = [{"type": "tool_use", "name": name, "input": {"file_path": fp}}]
            fh.write(json.dumps({"type": "assistant", "message": {"content": content}}) + "\n")
    return tr


def test_hook_acha_projeto_pelo_transcript(proj: Path, tmp_path: Path) -> None:
    tr = _transcript(tmp_path, ("Edit", str(proj / "suite.py")))
    out = _hook({"session_id": "s3", "cwd": str(tmp_path), "transcript_path": str(tr)})
    assert "Gauntlet proj" in out["systemMessage"]


def test_hook_read_nao_dispara_avaliacao(proj: Path, tmp_path: Path) -> None:
    """Achado 5: só ler um arquivo do projeto não pode custar uma suíte inteira."""
    tr = _transcript(tmp_path, ("Read", str(proj / "suite.py")))
    assert _hook({"session_id": "s7", "cwd": str(proj), "transcript_path": str(tr)}) == {}
    assert not (proj / ".gauntlet" / "history.tsv").exists()


def test_hook_le_transcript_incrementalmente(proj: Path, tmp_path: Path) -> None:
    tr = _transcript(tmp_path, ("Read", str(proj / "suite.py")))
    payload = {"session_id": "s8", "cwd": str(tmp_path), "transcript_path": str(tr)}
    assert _hook(payload) == {}
    _transcript(tmp_path, ("Write", str(proj / "novo.py")))  # anexa: só o trecho novo é lido
    assert "Gauntlet proj" in _hook(payload)["systemMessage"]
    cache = next((tmp_path / "cache").glob("*.json"))
    assert json.loads(cache.read_text(encoding="utf-8"))["offset"] == tr.stat().st_size


def test_hook_config_malformada_nao_reroda(proj: Path) -> None:
    """Achado 11: erro no avaliador não pode custar a suíte inteira em todo turno."""
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["metrics"][0]["norm"] = "inexistente"
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    base = {"session_id": "s9", "cwd": str(proj)}
    assert "erro no avaliador" in _hook(base)["systemMessage"]
    assert _hook(base) == {}


def test_hook_cursor_usa_followup(proj: Path) -> None:
    (proj / "FAIL").write_text("1")
    out = _hook({"conversation_id": "c", "status": "completed", "loop_count": 0, "workspace_roots": [str(proj.parent)]})
    assert "followup_message" in out and "t_calc" in out["followup_message"]


def test_hook_cursor_ignora_abortado(proj: Path) -> None:
    assert _hook({"conversation_id": "c", "status": "aborted", "workspace_roots": [str(proj)]}) == {}


def test_hook_cli_fail_open() -> None:
    script = Path(__file__).resolve().parents[1] / "gauntlet.py"
    r = subprocess.run([sys.executable, str(script), "hook"], input="não é json", capture_output=True, text=True)
    assert r.returncode == 0 and r.stdout == ""


# ------------------------------------------------------------------- accept


def test_accept_exige_motivo_e_fica_auditado(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "tests" / "test_x.py").write_text("def test_a():\n    assert soma(1, 1) == 2\n", encoding="utf-8")
    assert "asserts removidos" in g.evaluate(proj).issues
    assert g.main(["accept", "--project", str(proj)]) == 1
    assert g.main(["accept", "--project", str(proj), "--reason", "spec mudou: soma(2,2) saiu do escopo"]) == 0
    assert g.evaluate(proj).ok
    hist = (proj / ".gauntlet" / "history.tsv").read_text(encoding="utf-8")
    assert "\taccept\t" in hist
    out = _hook({"session_id": "s10", "cwd": str(proj)})
    assert "rebaixada por accept" in out["systemMessage"] and "spec mudou" in out["systemMessage"]


def test_accept_recusa_com_gate_falhando(proj: Path) -> None:
    g.evaluate(proj)
    (proj / "FAIL").write_text("1")
    assert g.main(["accept", "--project", str(proj), "--reason", "tentativa de aceitar falha"]) == 1


def test_accept_recusa_score_parcial(proj: Path) -> None:
    g.evaluate(proj)
    _metric(proj, "nada")
    assert g.main(["accept", "--project", str(proj), "--reason", "métrica sumiu mas tudo bem"]) == 1


def test_run_cli_codigos_de_saida(proj: Path) -> None:
    assert g.main(["run", "--project", str(proj)]) == 0
    _metric(proj, "50")
    assert g.main(["run", "--project", str(proj)]) == 2
    (proj / "FAIL").write_text("1")
    assert g.main(["run", "--project", str(proj), "--json"]) == 1


def test_cli_em_pipe_cp1252_nao_quebra(proj: Path) -> None:
    """Achado 15: emoji no render com stdout cp1252."""
    script = Path(__file__).resolve().parents[1] / "gauntlet.py"
    env = {**__import__("os").environ, "PYTHONIOENCODING": "cp1252"}
    r = subprocess.run([sys.executable, str(script), "run", "--project", str(proj)], capture_output=True, env=env)
    assert r.returncode == 0, r.stderr.decode("utf-8", "replace")


# ---------------------------------------------------------------- unitários


@pytest.mark.parametrize(
    ("value", "norm", "expected"),
    [
        (86.0, "percent", 0.86),
        (0.0, {"type": "inverse", "k": 20}, 1.0),
        (20.0, {"type": "inverse", "k": 20}, 0.5),
        (5.0, {"type": "linear", "min": 0, "max": 10}, 0.5),
        (2.0, {"type": "linear", "min": 0, "max": 10, "lower_is_better": True}, 0.8),
        (150.0, "percent", 1.0),
    ],
)
def test_normalize(value: float, norm, expected: float) -> None:
    assert g.normalize(value, norm) == pytest.approx(expected)


def test_match_glob_recursivo() -> None:
    assert g._match_any("tests/test_a.py", ["tests/**/*.py"])
    assert g._match_any("tests/sub/test_a.py", ["tests/**/*.py"])
    assert g._match_any("ruff.toml", ["**/ruff.toml"])
    assert g._match_any("a/b/ruff.toml", ["**/ruff.toml"])
    assert not g._match_any("app.py", ["tests/**/*.py"])


@pytest.mark.parametrize(
    ("line", "hit"),
    [
        ("@pytest.mark.skip(reason='x')", True),
        ("    @pytest.mark.xfail", True),
        ("@pytest.mark.skipif(sys.platform == 'win32', reason='x')", True),
        ("pytestmark = pytest.mark.skip", True),
        ("np = pytest.importorskip('numpy')", True),
        ("pytest.importorskip('numpy')", True),
        ("    raise unittest.SkipTest('x')", True),
        ("  it.skip('a', () => {})", True),
        ("describe.only('a', () => {})", True),
        ("    t.Skip()", True),
        ("    pytest.skip('sem rede')", True),
        ('    src = "import pytest\\n@pytest.mark.skip\\ndef t(): pass"', False),
        ("# comentário sobre @pytest.mark.skip", False),
        ("def test_skip_logic():", False),
    ],
)
def test_skip_re(line: str, hit: bool) -> None:
    assert bool(g.SKIP_RE.search(line)) is hit


@pytest.mark.parametrize(
    ("line", "hit"),
    [
        ("def f():  # noqa: C901", True),
        ("x = 1  # noqa", True),
        ("x = 1  # pragma: no cover", True),
        ("/* istanbul ignore next */", True),
        ("// eslint-disable-next-line", True),
        ("import os  # noqa: F401", False),
        ("x = 1  # comentário normal", False),
    ],
)
def test_suppress_re(line: str, hit: bool) -> None:
    assert bool(g.SUPPRESS_RE.search(line)) is hit


def test_assert_trivial() -> None:
    assert g.TRIVIAL_ASSERT_RE.match("    assert True")
    assert g.TRIVIAL_ASSERT_RE.match("    assert 1, 'msg'")
    assert not g.TRIVIAL_ASSERT_RE.match("    assert soma(1, 1) == 2")


def test_read_coverage_e_ruff_items(tmp_path: Path) -> None:
    data = {"totals": {"percent_covered": 50.0}, "files": {r"a\b.py": {"summary": {"percent_covered": 50.0}}}}
    (tmp_path / "c.json").write_text(json.dumps(data), encoding="utf-8")
    assert g.read_coverage(tmp_path / "c.json") == {"total": 50.0, "files": {"a/b.py": 50.0}, "missing": {"a/b.py": []}}
    assert g.read_coverage(tmp_path / "nao_existe.json") == {}
    (tmp_path / "ruim.json").write_text('{"files": {}}', encoding="utf-8")
    assert g.read_coverage(tmp_path / "ruim.json") == {}
    item = {"filename": "x\\app.py", "location": {"row": 7}, "message": "`f` is too complex (12 > 10)"}
    assert g.ruff_items(json.dumps([item])) == ["app.py:7 `f` is too complex (12 > 10)"]
    assert g.ruff_items("[]\nwarning: aviso no fim [deprecated]") == []  # achado 3
    assert g.ruff_items("sem json") is None
    assert g.ruff_items("[quebrado") is None


def test_ruff_ilegivel_vira_metrica_indisponivel(proj: Path) -> None:
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["metrics"].append(
        {"name": "c901", "cmd": ["{python}", "-c", "print('ruff: erro')"], "source": "ruff_json_count", "weight": 1}
    )
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    _git(proj, "commit", "-qam", "cfg")
    ev = g.evaluate(proj)
    assert ev.metrics["c901"]["value"] is None and ev.verdict == "incomplete"


def test_regressao_de_coverage_aponta_arquivo_e_linhas(proj: Path) -> None:
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    # o gate gera o cov.json (como o pytest-cov faz); o motor apaga o velho antes de rodar
    cfg["gates"].append(
        {"name": "cov", "cmd": ["{python}", "-c", "import shutil; shutil.copy('cov_src.json', 'cov.json')"]}
    )
    cfg["metrics"] = [
        {"name": "coverage", "source": "coverage_json", "path": "cov.json", "weight": 70, "norm": "percent"},
        {
            "name": "c901",
            "cmd": ["{python}", "-c", "print(open('ruff.json').read())"],
            "source": "ruff_json_count",
            "weight": 30,
            "norm": {"type": "inverse", "k": 20},
        },
    ]
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    (proj / "ruff.json").write_text("[]", encoding="utf-8")
    _cov(proj, {"suite.py": (90.0, []), "app.py": (90.0, [])})
    _git(proj, "add", "-A")
    _git(proj, "commit", "-qm", "cfg")
    assert g.evaluate(proj).verdict == "baseline"

    (proj / "app.py").write_text("x = 1\n", encoding="utf-8")
    _cov(proj, {"suite.py": (90.0, []), "app.py": (40.0, [10, 11])})
    hot = [{"filename": "app.py", "location": {"row": 1}, "message": "`f` is too complex (15 > 10)"}]
    (proj / "ruff.json").write_text(json.dumps(hot), encoding="utf-8")
    ev = g.evaluate(proj)
    assert ev.verdict == "regress"
    text = "\n".join(ev.feedback)
    assert "coverage de app.py: 90.0% → 40.0%" in text
    assert "app.py (alterado): linhas sem teste 10, 11" in text
    assert "c901 novo: app.py:1 `f` is too complex (15 > 10)" in text


def _cov(p: Path, files: dict[str, tuple[float, list[int]]]) -> None:
    total = sum(v for v, _ in files.values()) / len(files)
    data = {
        "totals": {"percent_covered": total},
        "files": {f: {"summary": {"percent_covered": v}, "missing_lines": m} for f, (v, m) in files.items()},
    }
    (p / "cov_src.json").write_text(json.dumps(data), encoding="utf-8")


def test_init_detecta_stacks(tmp_path: Path) -> None:
    (tmp_path / "pytest.ini").write_text("[pytest]\n")
    cfg = g.init_config(tmp_path)
    assert cfg["stack"] == "python" and "**/ruff.toml" in cfg["integrity"]["protected"]
    node = tmp_path / "n"
    node.mkdir()
    (node / "package.json").write_text("{}")
    assert g.init_config(node)["stack"] == "node"
    go = tmp_path / "g"
    go.mkdir()
    (go / "go.mod").write_text("module x")
    assert g.init_config(go)["stack"] == "go"
    vazio = tmp_path / "vazio"
    vazio.mkdir()
    with pytest.raises(ValueError):
        g.init_config(vazio)


def test_cli_init_status_e_sem_projeto(tmp_path: Path, proj: Path, capsys) -> None:
    (tmp_path / "py").mkdir()
    (tmp_path / "py" / "pytest.ini").write_text("[pytest]\n")
    assert g.main(["init", "--project", str(tmp_path / "py")]) == 0
    assert (tmp_path / "py" / "gauntlet.json").exists()
    assert g.main(["init", "--project", str(tmp_path / "py")]) == 0  # idempotente
    g.evaluate(proj)
    assert g.main(["status", "--project", str(proj)]) == 0
    assert '"score": 80.0' in capsys.readouterr().out
    vazio = tmp_path / "vazio"
    vazio.mkdir()
    assert g.main(["run", "--project", str(vazio)]) == 3


def test_lock_tem_dono(proj: Path) -> None:
    with g.Lock(proj) as a:
        assert a.held
        with g.Lock(proj) as b:
            assert not b.held
        assert g.main(["run", "--project", str(proj)]) == 4
        (proj / ".gauntlet" / "lock").write_text("outro-dono")  # lock roubado após stale
    assert (proj / ".gauntlet" / "lock").read_text() == "outro-dono"  # `a` não apaga lock alheio


def test_init_python_gera_coveragerc_sem_testes(tmp_path: Path) -> None:
    (tmp_path / "pytest.ini").write_text("[pytest]\n")
    assert g.main(["init", "--project", str(tmp_path)]) == 0
    rc = (tmp_path / g.COVERAGE_RC).read_text(encoding="utf-8")
    assert "tests/*" in rc
    cfg = json.loads((tmp_path / "gauntlet.json").read_text(encoding="utf-8"))
    assert cfg["gates"][0]["env"]["COVERAGE_RCFILE"] == "{project}/" + g.COVERAGE_RC
    assert g.COVERAGE_RC in cfg["integrity"]["protected"]


# ------------------------------------------------- revisão adversarial, rodada 2


def test_budget_zero_e_teto_zero_nao_ilimitado() -> None:
    assert g.Budget(0).cap(600) <= 0
    assert g.Budget(None).cap(600) == 600


def test_hook_bloqueia_config_desligada(proj: Path) -> None:
    """Rodada 2, achado 2: `"enabled": false` desligava o gauntlet sem aviso."""
    base = {"session_id": "t1", "cwd": str(proj)}
    _hook(base)
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["hook"]["enabled"] = False
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    out = _hook(base)
    assert out["decision"] == "block" and "gauntlet.json" in out["reason"]


def test_hook_bloqueia_config_quebrada(proj: Path) -> None:
    base = {"session_id": "t2", "cwd": str(proj)}
    _hook(base)
    (proj / "gauntlet.json").write_text("{ quebrado", encoding="utf-8")
    assert _hook(base)["decision"] == "block"


def test_referencia_avanca_apos_verde(proj: Path) -> None:
    """Rodada 2, achado 1: a referência é o último estado aprovado, não o 1º commit."""
    g.evaluate(proj)
    (proj / "app.py").write_text("def f():\n    return 1\n", encoding="utf-8")
    assert g.evaluate(proj).ok
    _git(proj, "add", "-A")
    _git(proj, "commit", "-qm", "app")
    assert g.evaluate(proj).ok
    base = json.loads((proj / ".gauntlet" / "baseline.json").read_text(encoding="utf-8"))
    assert g.base_ref(proj, base) == base["ref"]


def test_accept_com_arvore_suja_aprova_estado_atual(proj: Path) -> None:
    """Rodada 2, achado 7: accept com mudança não commitada não pode voltar a bloquear."""
    g.evaluate(proj)
    (proj / "sub").mkdir()
    (proj / "sub" / "ruff.toml").write_text("[lint]\n")  # protegido, não rastreado
    (proj / "app.py").write_text("x = 1  # noqa\n", encoding="utf-8")  # supressão, não rastreada
    issues = g.evaluate(proj).issues
    assert any(i.startswith("arquivo protegido") for i in issues) and any(i.startswith("supressão") for i in issues)
    assert g.main(["accept", "--project", str(proj), "--reason", "operador aprovou config de lint local"]) == 0
    assert g.evaluate(proj).ok
    (proj / "app.py").write_text("x = 2  # noqa\n", encoding="utf-8")  # mudou depois do aceite → volta a contar
    assert any(i.startswith("supressão") for i in g.evaluate(proj).issues)


def test_supressao_em_gerado_e_nao_codigo_e_ignorada(proj: Path) -> None:
    """Rodada 2, achado 4."""
    g.evaluate(proj)
    (proj / "dist").mkdir()
    (proj / "dist" / "bundle.js").write_text("/* eslint-disable */\n", encoding="utf-8")
    (proj / "NOTAS.md").write_text("use `# noqa` com cuidado\n", encoding="utf-8")
    (proj / "tipos.d.ts").write_text("/* eslint-disable */\n", encoding="utf-8")
    assert not any(i.startswith("supressão") for i in g.evaluate(proj).issues)


def test_junit_velho_nao_e_relido(proj: Path) -> None:
    """Rodada 2, achado 12."""
    g.evaluate(proj)
    stale = (
        '<testsuite tests="1"><testcase classname="x" name="t_velho"><failure message="velho"/></testcase></testsuite>'
    )
    (proj / ".gauntlet" / "junit.xml").write_text(stale, encoding="utf-8")
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["gates"][0]["cmd"] = ["{python}", "-c", "import sys; sys.exit(3)"]
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    ev = g.evaluate(proj)
    assert not any("t_velho" in i for i in ev.issues)
    assert "testes removidos" not in ev.issues


@pytest.mark.parametrize(
    ("cmd", "mutates"),
    [
        ("ls -la", False),
        ("git log --oneline -5", False),
        ("cat app.py | grep x", False),
        ("sed -i 's/a/b/' app.py", True),
        ("echo x > app.py", True),
        ("git commit -m x", True),
        ("Set-Content -Path a.txt -Value x", True),
        ("ruff format .", True),
    ],
)
def test_comando_mutante(cmd: str, mutates: bool) -> None:
    assert bool(g.MUTATING_CMD_RE.search(cmd)) is mutates


def test_hook_bash_so_leitura_nao_dispara(proj: Path, tmp_path: Path) -> None:
    """Rodada 2, achado 6: `ls` no projeto não pode custar uma suíte nem culpar a sessão."""
    tr = tmp_path / "b.jsonl"
    content = [{"type": "tool_use", "name": "Bash", "input": {"command": "ls -la"}}]
    tr.write_text(json.dumps({"message": {"content": content}}) + "\n", encoding="utf-8")
    assert _hook({"session_id": "t3", "cwd": str(proj), "transcript_path": str(tr)}) == {}
    content = [{"type": "tool_use", "name": "Bash", "input": {"command": "sed -i 's/a/b/' suite.py"}}]
    with tr.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps({"message": {"content": content}}) + "\n")
    assert "Gauntlet proj" in _hook({"session_id": "t3", "cwd": str(proj), "transcript_path": str(tr)})["systemMessage"]


def test_diag_re_exige_arquivo() -> None:
    assert g.DIAG_RE.match("app.py:12:5 E501 linha longa")
    assert g.DIAG_RE.match("src/a.ts:3: erro")
    assert not g.DIAG_RE.match("12:30:45 INFO servidor subiu")


def test_teto_zera_apos_tres_verdes(proj: Path) -> None:
    fail = g.Evaluation(project="proj", verdict="fail", score=0.0, baseline_score=None, issues=["x"])
    ok = g.Evaluation(project="proj", verdict="same", score=80.0, baseline_score=80.0)
    for i in range(3):
        g._record_result(proj, "t4", g.Evaluation(**{**fail.__dict__, "issues": [f"x{i}"]}), 3)
        g._record_result(proj, "t4", ok, 3)
    sess = json.loads((proj / ".gauntlet" / "state.json").read_text(encoding="utf-8"))["sessions"]["t4"]
    assert sess["total"] == 3  # alternância flaky não zera o teto
    g._record_result(proj, "t4", ok, 3)
    g._record_result(proj, "t4", ok, 3)
    sess = json.loads((proj / ".gauntlet" / "state.json").read_text(encoding="utf-8"))["sessions"]["t4"]
    assert sess["total"] == 0


# ------------------------------------------------- revisão adversarial, rodada 3


def test_supressao_em_arquivo_com_espaco_no_caminho(proj: Path) -> None:
    """Rodada 3, achado 1: git escreve `+++ b/meu app.py<TAB>`; o TAB escondia a extensão."""
    (proj / "pasta x").mkdir()
    (proj / "pasta x" / "meu app.py").write_text("x = 1\n", encoding="utf-8")
    _git(proj, "add", "-A")
    _git(proj, "commit", "-qm", "app com espaço")
    g.evaluate(proj)
    (proj / "pasta x" / "meu app.py").write_text("x = 1\ny = 2  # noqa\n", encoding="utf-8")
    assert any(i.startswith("supressão nova: pasta x/meu app.py") for i in g.evaluate(proj).issues)


def test_diff_path() -> None:
    assert g._diff_path("+++ b/app.py") == "app.py"
    assert g._diff_path("+++ b/meu app.py\t") == "meu app.py"
    assert g._diff_path('+++ "b/a\\"b.py"') == 'a"b.py'
    assert g._diff_path("+++ /dev/null") is None


def test_snapshot_mantem_referencia_quando_stash_falha(proj: Path) -> None:
    """Rodada 3, achado 2: merge em andamento faz `stash create` falhar; não pode cair para HEAD sujo."""
    g.evaluate(proj)
    base = json.loads((proj / ".gauntlet" / "baseline.json").read_text(encoding="utf-8"))
    _git(proj, "checkout", "-qb", "outra")
    (proj / "metric.txt").write_text("81", encoding="utf-8")
    _git(proj, "commit", "-qam", "outra")
    _git(proj, "checkout", "-q", "-")
    (proj / "metric.txt").write_text("82", encoding="utf-8")
    _git(proj, "commit", "-qam", "main")
    subprocess.run(["git", "-C", str(proj), "merge", "outra"], capture_output=True)  # conflito
    assert g.snapshot(proj, []) == {}
    assert g.base_ref(proj, base) == base["ref"]


def test_referencia_aprovada_fica_presa_contra_gc(proj: Path) -> None:
    (proj / "app.py").write_text("x = 1\n", encoding="utf-8")
    _git(proj, "add", "app.py")
    snap = g.snapshot(proj, [])
    refs = subprocess.run(["git", "-C", str(proj), "for-each-ref", "refs/gauntlet"], capture_output=True, text=True)
    assert snap["ref"] in refs.stdout


def test_repo_sem_commit_usa_arvore_vazia(tmp_path: Path) -> None:
    p = tmp_path / "novo"
    p.mkdir()
    _git(p, "init", "-q")
    assert g.base_ref(p, None) == g.EMPTY_TREE
    assert g.snapshot(p, []) == {}


def test_fonte_grande_nao_escapa(proj: Path) -> None:
    """Rodada 3, achado 3: arquivo > 1 MB era pulado."""
    g.evaluate(proj)
    (proj / "grande.py").write_text("x = 1\n" * 300_000 + "y = 2  # noqa\n", encoding="utf-8")
    assert any(i.startswith("supressão nova: grande.py") for i in g.evaluate(proj).issues)


def test_config_sha_ignora_formatacao(proj: Path) -> None:
    """Rodada 3, achado 4: CRLF/reformatação não é adulteração."""
    sha = g.config_sha(proj)
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    (proj / "gauntlet.json").write_bytes(json.dumps(cfg, indent=4).replace("\n", "\r\n").encode("utf-8"))
    assert g.config_sha(proj) == sha
    cfg["hook"]["enabled"] = False
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    assert g.config_sha(proj) != sha


def test_coverage_velho_e_apagado_antes_do_gate(proj: Path) -> None:
    cfg = json.loads((proj / "gauntlet.json").read_text(encoding="utf-8"))
    cfg["metrics"] = [{"name": "coverage", "source": "coverage_json", "path": "{state}/cov.json", "weight": 1}]
    (proj / "gauntlet.json").write_text(json.dumps(cfg), encoding="utf-8")
    _git(proj, "commit", "-qam", "cfg")
    st = g.state_dir(proj)
    (st / "cov.json").write_text(json.dumps({"totals": {"percent_covered": 99.0}, "files": {}}), encoding="utf-8")
    ev = g.evaluate(proj)
    assert ev.metrics["coverage"]["value"] is None and ev.verdict == "incomplete"
