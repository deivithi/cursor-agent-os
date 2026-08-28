import importlib.util, sys
spec = importlib.util.spec_from_file_location("h", r"C:\Users\deivithi.lopes\Documents\Cursor\refresh_dre_cache_tmp.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
cmd = (
    "cd /home/workspace/Projects/dre-eventos && "
    "echo '=== F2 ocs ===' && .venv/bin/python scripts/refresh_dre_cache.py --source ocs; ec1=$?; "
    "echo '=== F2 orcado ===' && .venv/bin/python scripts/refresh_dre_cache.py --source orcado; ec2=$?; "
    "echo EXIT_OCS=$ec1 EXIT_ORCADO=$ec2; exit $(( ec1!=0 ? ec1 : ec2 ))"
)
out = h.zo_bash(cmd, timeout=900)
print(h.extract_stdout(out))
if 'EXIT_OCS=' in out or 'EXIT_ORCADO=' in out:
    pass
print('---TAIL---')
print(out[-8000:] if len(out)>8000 else out)
