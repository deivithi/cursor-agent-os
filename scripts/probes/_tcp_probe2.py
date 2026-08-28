import subprocess, sys
cmd = r"""python3 - <<'PY'
import socket
host='cpservicos135751.rm.cloudtotvs.com.br'
port=8051
s=socket.socket()
s.settimeout(12)
try:
    s.connect((host,port))
    print('TCP_OK')
except Exception as e:
    print('TCP_FAIL', type(e).__name__, e)
finally:
    s.close()
PY"""
rc = subprocess.call([sys.executable, "refresh_dre_cache_tmp.py", "zo_bash", cmd, "30"])
print("RC", rc)
sys.exit(rc)
