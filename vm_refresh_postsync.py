import sys, time
sys.path.insert(0, r"C:\Users\deivithi.lopes\Documents\Cursor")
from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT

for src in ("ocs", "orcado"):
    log = "/tmp/dre_refresh_%s_postsync.log" % src
    cmd = "cd %s && nohup .venv/bin/python scripts/refresh_dre_cache.py --source %s > %s 2>&1 &" % (VM_PROJECT, src, log)
    zo_bash(cmd, timeout=60)
    print("started", src)
    for i in range(40):
        s = extract_stdout(zo_bash(
            "cd %s && (test -f data/cache/.refresh.lock && echo LOCK=yes || echo LOCK=no); tail -3 %s 2>/dev/null" % (VM_PROJECT, log),
            timeout=45))
        if "LOCK=no" in s:
            full = extract_stdout(zo_bash("tail -15 %s" % log, timeout=30))
            if "refresh_finalizado" in full:
                print(src, "OK")
                print(full[-800:])
                break
        time.sleep(12)
    else:
        print(src, "TIMEOUT")
