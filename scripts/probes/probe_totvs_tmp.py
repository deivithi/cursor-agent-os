"""One-shot TOTVS TCP probe via Zo helper. Avoids PowerShell quoting issues."""
import sys
from refresh_dre_cache_tmp import extract_stdout, zo_bash

CMD = (
    "python3 -c "
    "'import socket,sys;\n"
    "try:\n"
    " s=socket.create_connection((\"cpservicos135751.rm.cloudtotvs.com.br\",8051),15)\n"
    " s.close(); print(\"TCP_OK\")\n"
    "except Exception as e:\n"
    " print(\"TCP_FAIL\", type(e).__name__, e); sys.exit(1)'"
)

def main():
    out = zo_bash(CMD, timeout=30)
    print(extract_stdout(out))

if __name__ == "__main__":
    main()
