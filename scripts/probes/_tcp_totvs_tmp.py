import socket, re
from pathlib import Path
env = Path("/home/workspace/Projects/dre-eventos/.env").read_text(errors="replace")
cands = set()
for line in env.splitlines():
    if line.strip().startswith("#") or "=" not in line:
        continue
    k, v = line.split("=", 1)
    ku = k.upper()
    if not any(x in ku for x in ("TOTVS", "PROTHEUS", "SOAP", "WSDL", "REST")) and ":8051" not in v:
        continue
    print("KEY", k)
    for m in re.finditer(r"([A-Za-z0-9_.-]+):8051", v):
        cands.add(m.group(1))
    for m in re.finditer(r"https?://([A-Za-z0-9_.-]+)", v):
        cands.add(m.group(1))
if not cands:
    print("NO_CANDIDATES")
for h in sorted(cands):
    try:
        s = socket.create_connection((h, 8051), 8)
        s.close()
        print(f"TCP_OK {h}:8051")
    except Exception as e:
        print(f"TCP_FAIL {h}:8051 {type(e).__name__}:{e}")
