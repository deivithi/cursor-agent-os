"""F2 OCS refresh with retry / stale-lock policy."""
import re
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from refresh_dre_cache_tmp import extract_stdout, zo_bash

VM = "/home/workspace/Projects/dre-eventos"
MAX_ATTEMPTS = 4  # 1 + 3 retries


def lock_status() -> str:
    return extract_stdout(
        zo_bash(
            f"ls -la {VM}/data/cache/.refresh.lock 2>/dev/null; "
            f"cat {VM}/data/cache/.refresh.lock 2>/dev/null || echo NO_LOCK",
            timeout=30,
        )
    )


def clear_stale_lock() -> None:
    out = extract_stdout(
        zo_bash(
            f"LOCK={VM}/data/cache/.refresh.lock; "
            "if [ ! -f \"$LOCK\" ]; then echo NO_LOCK; exit 0; fi; "
            "PID=$(python3 -c \"import re,sys; t=open(sys.argv[1]).read(); "
            "m=re.search(r'pid[=:\\s]+(\\d+)', t, re.I); print(m.group(1) if m else '')\" \"$LOCK\"); "
            "if [ -z \"$PID\" ]; then echo LOCK_NO_PID; rm -f \"$LOCK\"; echo REMOVED; exit 0; fi; "
            "if kill -0 \"$PID\" 2>/dev/null; then echo LOCK_ALIVE pid=$PID; "
            "else echo LOCK_DEAD pid=$PID; rm -f \"$LOCK\"; echo REMOVED; fi",
            timeout=30,
        )
    )
    print(out)


def refresh_ocs() -> str:
    cmd = (
        f"cd {VM} && {VM}/.venv/bin/python "
        "scripts/refresh_dre_cache.py --source ocs 2>&1; echo EXIT_CODE=$?"
    )
    return extract_stdout(zo_bash(cmd, timeout=900))


def is_totvs_timeout(text: str) -> bool:
    low = text.lower()
    return any(
        x in low
        for x in (
            "connecttimeout",
            "timed out",
            "timeout",
            "max retries",
            "connection to",
            "8051",
        )
    ) and (
        "exit_code=0" not in low
        and not re.search(r"exit_code=0\b", low)
    )


def main() -> int:
    for attempt in range(1, MAX_ATTEMPTS + 1):
        print(f"=== OCS attempt {attempt}/{MAX_ATTEMPTS} ===")
        clear_stale_lock()
        out = refresh_ocs()
        print(out[-8000:] if len(out) > 8000 else out)
        if re.search(r"EXIT_CODE=0\b", out) or "status.: .ok" in out.lower():
            # Prefer explicit exit code
            if re.search(r"EXIT_CODE=0\b", out):
                print("OCS_OK")
                return 0
        if "EXIT_CODE=0" in out:
            print("OCS_OK")
            return 0
        # stale lock message?
        if "refresh.lock" in out.lower() or "already running" in out.lower():
            print("Lock conflict — clearing stale if dead and retrying")
            clear_stale_lock()
            time.sleep(5)
            continue
        if is_totvs_timeout(out) and attempt < MAX_ATTEMPTS:
            wait = 90 + (attempt * 10)
            print(f"TOTVS timeout — waiting {wait}s before retry")
            time.sleep(wait)
            continue
        print("OCS_FAIL")
        return 1
    print("OCS_FAIL after retries")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
