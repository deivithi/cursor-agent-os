import subprocess, sys, hashlib, pathlib
p = pathlib.Path(r"C:\Users\deivithi.lopes\Documents\Cursor\DRE_Eventos\data\cache\dre_snapshot.parquet")
h = hashlib.md5(p.read_bytes()).hexdigest()
print("PC_MD5", h, "SIZE", p.stat().st_size)
cmd = """python3 - <<'PY'
import hashlib, json, pathlib
base=pathlib.Path('/home/workspace/Projects/dre-eventos/data/cache')
b=(base/'dre_snapshot.parquet').read_bytes()
print('ZO_MD5', hashlib.md5(b).hexdigest(), 'SIZE', len(b))
meta=json.loads((base/'cache_meta.json').read_text())
d=meta['snapshots']['dre_snapshot']
print('META_DRE', d.get('updated_at'), d.get('rows'), d.get('md5'))
o=meta['snapshots']['ocs_snapshot']
print('META_OCS', o.get('updated_at'), o.get('rows'), o.get('md5'))
oe=meta['snapshots']['orcado_eventos_snapshot']
print('META_ORCADO_EVT', oe.get('updated_at'), oe.get('rows'))
PY"""
subprocess.call([sys.executable, r"C:\Users\deivithi.lopes\Documents\Cursor\refresh_dre_cache_tmp.py", "zo_bash", cmd, "60"])
