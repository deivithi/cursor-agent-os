import sys
sys.path.insert(0, r"C:\Users\deivithi.lopes\Documents\Cursor")
from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT
cmd = "cd %s && .venv/bin/python -c 'import pandas as pd; print(len(pd.read_parquet(\"data/cache/dre_snapshot.parquet\")))'" % VM_PROJECT
print(extract_stdout(zo_bash(cmd, timeout=120)))
