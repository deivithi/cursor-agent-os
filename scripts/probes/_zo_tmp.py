import importlib.util
spec = importlib.util.spec_from_file_location("h", r"C:\Users\deivithi.lopes\Documents\Cursor\refresh_dre_cache_tmp.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
cmd = (
    "cd /home/workspace/Projects/dre-eventos && "
    ".venv/bin/python scripts/refresh_dre_cache.py --source ocs --dry-run 2>/dev/null | head -1 || "
    ".venv/bin/python -c \"import socket; s=socket.create_connection(('127.0.0.1',8051),5); print('skip')\" 2>/dev/null; "
    "python3 -c 'import socket,re; from pathlib import Path; "
    "e=dict(l.split(\"=\",1) for l in Path(\".env\").read_text().splitlines() if \"=\" in l and not l.strip().startswith(\"#\")); "
    "raw=e.get(\"TOTVS_HOST\",e.get(\"TOTVS_URL\",\"\")).strip().strip(chr(34)); "
    "host=re.search(r\"//([^:/]+)\",raw).group(1) if \"//\" in raw else raw.split(\":\")[0]; "
    "s=socket.socket(); s.settimeout(5); "
    "exec(\"try:\\n s.connect((host,8051)); print(\\\"TCP_OK\\\",host,8051)\\nexcept Exception as ex: print(\\\"TCP_FAIL\\\",host,8051,ex)\\nfinally: s.close()\")'"
)
out = h.zo_bash(cmd, timeout=45)
print(h.extract_stdout(out))
