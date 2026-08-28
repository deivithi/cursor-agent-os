import subprocess, sys
cmd = [
    sys.executable,
    "refresh_dre_cache_tmp.py",
    "zo_bash",
    "timeout 12 bash -c 'echo >/dev/tcp/cpservicos135751.rm.cloudtotvs.com.br/8051 && echo TCP_OK || echo TCP_FAIL'",
]
sys.exit(subprocess.call(cmd))
