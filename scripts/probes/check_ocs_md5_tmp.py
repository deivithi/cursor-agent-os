"""Confirm ocs_snapshot meta.md5 == file md5 on VM."""
from refresh_dre_cache_tmp import extract_stdout, zo_bash

CMD = (
    "cd /home/workspace/Projects/dre-eventos && "
    ".venv/bin/python -c "
    "\"import hashlib,json; "
    "m=json.load(open('data/cache/cache_meta.json')); "
    "meta=m['snapshots']['ocs_snapshot']['md5']; "
    "h=hashlib.md5(open('data/cache/ocs_snapshot.parquet','rb').read()).hexdigest(); "
    "print('ocs_meta_md5', meta); print('ocs_file_md5', h); "
    "print('MD5_MATCH', 'YES' if meta==h else 'NO'); "
    "dre_meta=m['snapshots']['dre_snapshot']['md5']; "
    "dre_h=hashlib.md5(open('data/cache/dre_snapshot.parquet','rb').read()).hexdigest(); "
    "print('dre_meta_md5', dre_meta); print('dre_file_md5', dre_h); "
    "print('DRE_MD5_MATCH', 'YES' if dre_meta==dre_h else 'NO'); "
    "orc=m['snapshots']['orcado_eventos_snapshot']; "
    "print('orcado_eventos_rows', orc['rows'], 'updated', orc['updated_at']); "
    "print('dre_rows', m['snapshots']['dre_snapshot']['rows'], m['snapshots']['dre_snapshot']['updated_at']); "
    "print('ocs_rows', m['snapshots']['ocs_snapshot']['rows'], m['snapshots']['ocs_snapshot']['updated_at'])\""
)

print(extract_stdout(zo_bash(CMD, timeout=60)))
