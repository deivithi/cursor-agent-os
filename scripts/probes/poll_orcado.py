import sys, time
sys.path.insert(0, r"C:\Users\deivithi.lopes\Documents\Cursor")
from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT

cmd = "cd %s && nohup .venv/bin/python scripts/refresh_dre_cache.py --source orcado > /tmp/dre_refresh_orcado.log 2>&1 &" % VM_PROJECT
print("start:", extract_stdout(zo_bash(cmd, timeout=60)))

for i in range(30):
    s = extract_stdout(zo_bash(
        "cd %s && (test -f data/cache/.refresh.lock && echo LOCK=yes || echo LOCK=no); tail -5 /tmp/dre_refresh_orcado.log 2>/dev/null" % VM_PROJECT,
        timeout=45))
    print("poll", i+1, s[:500])
    if "LOCK=no" in s and "refresh_finalizado" in s:
        break
    if "LOCK=no" in s and i > 2:
        log = extract_stdout(zo_bash("tail -20 /tmp/dre_refresh_orcado.log", timeout=30))
        if "refresh_finalizado" in log or "etapa_ok" in log:
            print(log)
            break
    time.sleep(15)
