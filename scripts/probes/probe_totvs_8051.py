from refresh_dre_cache_tmp import run_and_print

CMD = (
    "python3 -c "
    "'import socket; s=socket.socket(); s.settimeout(20); "
    "r=s.connect_ex((\"cpservicos135751.rm.cloudtotvs.com.br\",8051)); "
    "print(\"TCP_8051\", \"OK\" if r==0 else \"FAIL:\"+str(r)); s.close()'"
)
run_and_print(CMD, timeout=40)
