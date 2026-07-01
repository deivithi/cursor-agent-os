"""Zo MCP bash helper for DRE Eventos VM operations.

Ação ``refresh``: roda dre_refresh_with_alerts.sh na VM (OCs TOTVS + Sheets +
derivados). Pode levar 10–15 min em dias com TOTVS lento — não é falha por si.

Ação ``refresh_source``: roda refresh_dre_cache.py --source FONTE (uma fonte
por invocação). Use para ocs/orcado/fabric isolados na VM.

Requer MCP Zo configurado em %USERPROFILE%\\.cursor\\mcp.json (URL api.zo.computer).
"""
import json
import re
import sys
import urllib.request
from pathlib import Path

VM_PROJECT = "/home/workspace/Projects/dre-eventos"
DEFAULT_TIMEOUT = 30
MCP_SERVER_NAMES = ("cursor-to-zo2", "user-cursor-to-zo2", "user-zo", "zo")

USAGE = """\
Uso: python refresh_dre_cache_tmp.py <acao> [args]

Diagnóstico (somente leitura):
  meta                 cache_meta.json na VM
  refresh_request      refresh_request.json (pull Fabric)
  fabric_mode          FABRIC_AUTH_MODE no .env da VM
  venv_check           .venv/bin/python existe na VM
  health               GET /api/health na VM (localhost)
  lock                 estado de data/cache/.refresh.lock
  parquet_check        contagem de linhas dre_snapshot.parquet

Operações na VM:
  pre                  git pull --ff-only no repo da VM
  refresh              dre_refresh_with_alerts.sh (cron completo, ~10–15 min)
  refresh_source SRC [timeout_s]
                       refresh_dre_cache.py --source SRC (default timeout 900)
  clear_refresh_flag   pending=false em refresh_request.json
  zo_bash "CMD" [timeout_s]
                       comando bash arbitrário na VM (default timeout 30)

  help                 esta mensagem

Exemplos:
  python refresh_dre_cache_tmp.py meta
  python refresh_dre_cache_tmp.py refresh_source ocs 900
  python refresh_dre_cache_tmp.py zo_bash "ls -la data/cache" 60
"""


def load_server():
    cfg_path = Path.home() / ".cursor" / "mcp.json"
    if not cfg_path.exists():
        raise RuntimeError(f"mcp.json não encontrado: {cfg_path}")
    cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
    servers = cfg.get("mcpServers", {})
    for name in MCP_SERVER_NAMES:
        if name in servers:
            return servers[name]
    raise RuntimeError(
        "Nenhum servidor Zo em mcp.json "
        f"({', '.join(MCP_SERVER_NAMES)})"
    )


def zo_bash(cmd: str, timeout: int = DEFAULT_TIMEOUT) -> str:
    server = load_server()
    url = server["url"]
    headers = dict(server.get("headers") or {})
    headers.update(
        {"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}
    )
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {"name": "bash", "arguments": {"cmd": cmd, "timeout": timeout}},
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers, method="POST")
    http_timeout = timeout + 90
    with urllib.request.urlopen(req, timeout=http_timeout) as r:
        parsed = json.loads(r.read().decode("utf-8", "replace"))
    if "error" in parsed:
        raise RuntimeError(json.dumps(parsed["error"], ensure_ascii=False))
    text = parsed.get("result", {}).get("content", [{}])[0].get("text", "")
    try:
        outer = json.loads(text)
        if isinstance(outer, dict) and "content" in outer:
            text = outer["content"][0].get("text", text)
    except json.JSONDecodeError:
        pass
    return text


def extract_stdout(text: str) -> str:
    m = re.search(r"stdout='(.*?)'\s*stderr=", text, re.DOTALL)
    if not m:
        m = re.search(r"stdout='(.*)'", text, re.DOTALL)
    if not m:
        return text
    return m.group(1).replace("\\n", "\n").replace("\\'", "'")


def run_and_print(cmd: str, timeout: int = DEFAULT_TIMEOUT, *, raw_suffix: bool = False) -> None:
    out = zo_bash(cmd, timeout=timeout)
    print(extract_stdout(out))
    if raw_suffix:
        print("---RAW---")
        print(out[-4000:] if len(out) > 4000 else out)


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "help"

    if action in ("help", "-h", "--help"):
        print(USAGE.strip())
        return

    if action == "meta":
        run_and_print(f"cat {VM_PROJECT}/data/cache/cache_meta.json")
    elif action == "refresh_request":
        run_and_print(
            f"cat {VM_PROJECT}/data/cache/refresh_request.json 2>/dev/null || echo '{{}}'"
        )
    elif action == "fabric_mode":
        run_and_print(
            f"grep -E '^FABRIC_AUTH_MODE=' {VM_PROJECT}/.env 2>/dev/null "
            "|| echo FABRIC_AUTH_MODE=unknown"
        )
    elif action == "venv_check":
        run_and_print(
            f"test -x {VM_PROJECT}/.venv/bin/python && echo VENV_OK || echo VENV_MISSING"
        )
    elif action == "pre":
        run_and_print(f"cd {VM_PROJECT} && git pull --ff-only 2>&1", timeout=180)
    elif action == "lock":
        run_and_print(
            f"ls -la {VM_PROJECT}/data/cache/.refresh.lock 2>/dev/null; "
            f"cat {VM_PROJECT}/data/cache/.refresh.lock 2>/dev/null || echo NO_LOCK",
            timeout=30,
        )
    elif action == "health":
        run_and_print("curl -sS http://127.0.0.1:5000/api/health", timeout=60)
    elif action == "parquet_check":
        cmd = (
            f"cd {VM_PROJECT} && {VM_PROJECT}/.venv/bin/python -c "
            "\"import pyarrow.parquet as pq; "
            "t=pq.read_table('data/cache/dre_snapshot.parquet'); "
            "print('dre_rows', t.num_rows)\" 2>&1"
        )
        run_and_print(cmd, timeout=120)
    elif action == "refresh":
        script = f"{VM_PROJECT}/scripts/zo/dre_refresh_with_alerts.sh"
        run_and_print(f"cd {VM_PROJECT} && bash {script}", timeout=900, raw_suffix=True)
    elif action == "refresh_source":
        if len(sys.argv) < 3:
            raise SystemExit("Uso: refresh_source <ocs|orcado|fabric|all> [timeout_s]")
        source = sys.argv[2]
        timeout = int(sys.argv[3]) if len(sys.argv) > 3 else 900
        cmd = (
            f"cd {VM_PROJECT} && {VM_PROJECT}/.venv/bin/python "
            f"scripts/refresh_dre_cache.py --source {source} 2>&1; echo EXIT_CODE=$?"
        )
        run_and_print(cmd, timeout=timeout)
    elif action == "clear_refresh_flag":
        run_and_print(
            f"python3 -c \"import json; p='{VM_PROJECT}/data/cache/refresh_request.json'; "
            f"d=json.load(open(p)) if __import__('os').path.exists(p) else {{}}; "
            f"d.update({{'pending': False, 'status': 'completed'}}); "
            f"json.dump(d, open(p,'w'), indent=2); print('cleared')\""
        )
    elif action == "zo_bash":
        if len(sys.argv) < 3:
            raise SystemExit('Uso: zo_bash "comando" [timeout_s]')
        cmd = sys.argv[2]
        timeout = int(sys.argv[3]) if len(sys.argv) > 3 else DEFAULT_TIMEOUT
        run_and_print(cmd, timeout=timeout)
    else:
        raise SystemExit(f"Ação desconhecida: {action}\n\n{USAGE.strip()}")


if __name__ == "__main__":
    main()
