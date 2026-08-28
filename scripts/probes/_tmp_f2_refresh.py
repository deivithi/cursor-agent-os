from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT
import sys

def run_refresh(source):
    cmd = f"cd {VM_PROJECT} && .venv/bin/python scripts/refresh_dre_cache.py --source {source}; echo EXIT_CODE=$?"
    out = zo_bash(cmd, timeout=900)
    text = extract_stdout(out)
    print(f"=== --source {source} ===")
    print(text[-8000:] if len(text) > 8000 else text)
    if "EXIT_CODE=" in text:
        for line in text.splitlines():
            if line.strip().startswith("EXIT_CODE="):
                print(line.strip())

for src in ("ocs", "orcado"):
    run_refresh(src)
