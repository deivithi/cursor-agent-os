import subprocess, sys
cmd = r"""python3 - <<'PY'
import json, hashlib, pathlib
p=pathlib.Path('/home/workspace/Projects/dre-eventos/data/cache')
pq=p/'dre_snapshot.parquet'
meta=json.loads((p/'cache_meta.json').read_text())
h=hashlib.md5(pq.read_bytes()).hexdigest()
print('file_md5', h, 'size', pq.stat().st_size)
dre=meta['snapshots']['dre_snapshot']
print('meta_md5', dre.get('md5'), 'rows', dre.get('rows'), 'updated_at', dre.get('updated_at'))
print('ocs', meta['snapshots']['ocs_snapshot'].get('rows'), meta['snapshots']['ocs_snapshot'].get('updated_at'))
print('orcado_eventos', meta['snapshots']['orcado_eventos_snapshot'].get('rows'), meta['snapshots']['orcado_eventos_snapshot'].get('updated_at'))
PY"""
subprocess.check_call([sys.executable, "refresh_dre_cache_tmp.py", "zo_bash", cmd, "60"])
