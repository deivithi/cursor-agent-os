"""One-shot: TCP probe TOTVS :8051 via Zo bash helper."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from refresh_dre_cache_tmp import extract_stdout, zo_bash

CMD = (
    "timeout 20 bash -c "
    "'echo >/dev/tcp/cpservicos135751.rm.cloudtotvs.com.br/8051' "
    "&& echo TCP_8051_OK || echo TCP_8051_FAIL"
)
print(extract_stdout(zo_bash(CMD, timeout=60)))
