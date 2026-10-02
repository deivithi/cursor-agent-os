#!/usr/bin/env python3
"""Gera assets/prancha-ste-pt.html a partir do template + references/dicionario.json.

Uso: py skills/ste-ptbr/scripts/build_prancha.py
Rode sempre depois de editar o dicionário. O teste test_prancha_usa_dicionario_atual falha se esquecer.
"""

from __future__ import annotations

import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TEMPLATE = RAIZ / "assets" / "prancha-ste-pt.template.html"
SAIDA = RAIZ / "assets" / "prancha-ste-pt.html"
DICIONARIO = RAIZ / "references" / "dicionario.json"
MARCADOR = "__DICIONARIO__"


def gerar() -> str:
    dados = json.loads(DICIONARIO.read_text(encoding="utf-8"))
    compacto = json.dumps(dados, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    template = TEMPLATE.read_text(encoding="utf-8")
    if template.count(MARCADOR) != 1:
        raise ValueError(f"o template precisa ter exatamente um {MARCADOR}")
    return template.replace(MARCADOR, compacto)


def main() -> None:
    SAIDA.write_text(gerar(), encoding="utf-8", newline="\n")
    print(f"gerado: {SAIDA}")


if __name__ == "__main__":
    main()
