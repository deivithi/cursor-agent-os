from refresh_dre_cache_tmp import run_and_print

CMD = (
    "python3 -c "
    "\"import hashlib,json,pathlib; "
    "p=pathlib.Path('/home/workspace/Projects/dre-eventos/data/cache'); "
    "f=p/'ocs_snapshot.parquet'; "
    "meta=json.loads((p/'cache_meta.json').read_text()); "
    "file_md5=hashlib.md5(f.read_bytes()).hexdigest(); "
    "meta_md5=meta['snapshots']['ocs_snapshot'].get('md5'); "
    "print('ocs_file_md5', file_md5); "
    "print('ocs_meta_md5', meta_md5); "
    "print('ocs_md5_match', file_md5==meta_md5); "
    "print('ocs_rows', meta['snapshots']['ocs_snapshot'].get('rows')); "
    "df=p/'dre_snapshot.parquet'; "
    "dre_file=hashlib.md5(df.read_bytes()).hexdigest(); "
    "dre_meta=meta['snapshots']['dre_snapshot'].get('md5'); "
    "print('dre_file_md5', dre_file); "
    "print('dre_meta_md5', dre_meta); "
    "print('dre_md5_match', dre_file==dre_meta); "
    "print('dre_rows', meta['snapshots']['dre_snapshot'].get('rows'))\""
)
run_and_print(CMD, timeout=60)
