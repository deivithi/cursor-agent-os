import sys, time
sys.path.insert(0, r"C:\Users\deivithi.lopes\Documents\Cursor")
from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT

def status():
    cmd = "cd %s && (test -f data/cache/.refresh.lock && echo LOCK=yes || echo LOCK=no); ps aux | grep '[r]efresh_dre_cache'; tail -8 /tmp/dre_refresh_ocs.log 2>/dev/null || true" % VM_PROJECT
    return extract_stdout(zo_bash(cmd, timeout=45))

for i in range(40):
    print("--- poll", i + 1, "---")
    s = status()
    print(s)
    if "LOCK=no" in s and i > 0 and "refresh_dre_cache" not in s:
        break
    time.sleep(20)
print("DONE")
