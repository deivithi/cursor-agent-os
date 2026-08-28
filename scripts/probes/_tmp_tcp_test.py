from refresh_dre_cache_tmp import zo_bash, extract_stdout, VM_PROJECT
host = "cpservicos135751.rm.cloudtotvs.com.br"
cmd = f"python3 -c \"import socket; s=socket.socket(); s.settimeout(8); r=s.connect_ex(('{host}',8051)); print('TCP_OK' if r==0 else f'TCP_FAIL code={{r}}'); s.close()\""
print(extract_stdout(zo_bash(cmd, 30)))
