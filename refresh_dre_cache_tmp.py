"""Zo MCP bash helper for DRE Eventos VM operations.

Ação ``refresh``: roda dre_refresh_with_alerts.sh na VM (OCs TOTVS + Sheets +
derivados). Pode levar 10–15 min em dias com TOTVS lento — não é falha por si.
O timeout HTTP do urllib é sempre bash timeout + 60s (margem para MCP overhead).
"""
import json
import re
import sys
import urllib.request
from pathlib import Path

VM_PROJECT = "/home/workspace/Projects/dre-eventos"
DEFAULT_TIMEOUT = 30


def load_server():
    cfg = json.loads((Path.home() / ".cursor" / "mcp.json").read_text(encoding="utf-8"))
    servers = cfg.get("mcpServers", {})
    for name in ("cursor-to-zo2", "user-zo", "zo"):
        if name in servers:
            return servers[name]
    raise RuntimeError("Nenhum servidor Zo em mcp.json (cursor-to-zo2, user-zo, zo)")


def zo_bash(cmd: str, timeout: int = DEFAULT_TIMEOUT) -> str:
    server = load_server()
    url = server["url"]
    headers = dict(server.get("headers") or {})
    headers.update({"Content-Type": "application/json", "Accept": "application/json, text/event-stream"})
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {"name": "bash", "arguments": {"cmd": cmd, "timeout": timeout}},
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=timeout + 60) as r:
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


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "meta"
    if action == "meta":
        out = zo_bash(f"cat {VM_PROJECT}/data/cache/cache_meta.json")
        print(extract_stdout(out))
    elif action == "refresh_request":
        out = zo_bash(f"cat {VM_PROJECT}/data/cache/refresh_request.json 2>/dev/null || echo '{{}}'")
        print(extract_stdout(out))
    elif action == "fabric_mode":
        out = zo_bash(
            f"grep -E '^FABRIC_AUTH_MODE=' {VM_PROJECT}/.env 2>/dev/null || echo FABRIC_AUTH_MODE=unknown"
        )
        print(extract_stdout(out))
    elif action == "venv_check":
        out = zo_bash(f"test -x {VM_PROJECT}/.venv/bin/python && echo VENV_OK || echo VENV_MISSING")
        print(extract_stdout(out))
    elif action == "refresh":
        script = f"{VM_PROJECT}/scripts/zo/dre_refresh_with_alerts.sh"
        out = zo_bash(f"cd {VM_PROJECT} && bash {script}", timeout=900)
        print(extract_stdout(out))
        print("---RAW---")
        print(out[-4000:] if len(out) > 4000 else out)
    elif action == "clear_refresh_flag":
        out = zo_bash(
            f"python3 -c \"import json; p='{VM_PROJECT}/data/cache/refresh_request.json'; "
            f"d=json.load(open(p)) if __import__('os').path.exists(p) else {{}}; "
            f"d.update({{'pending': False, 'status': 'completed'}}); "
            f"json.dump(d, open(p,'w'), indent=2); print('cleared')\""
        )
        print(extract_stdout(out))
    else:
        raise SystemExit(f"acao desconhecida: {action}")


if __name__ == "__main__":
    main()
