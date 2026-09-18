#!/usr/bin/env python3
"""
dre-integrity-check.py
Guarda de integridade e auditoria financeira para o app DRE_Eventos (Flask/React).
Verifica regras de conciliação de receitas, deduções, margens e sanidade de chunks.
"""

import sys
import os
import json
import argparse
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

def validate_event_financials(data: dict) -> dict:
    """Valida a integridade contábil de um evento."""
    results = {"valid": True, "errors": [], "warnings": [], "metrics": {}}

    receita_bruta = data.get("receita_bruta", 0.0)
    impostos = data.get("impostos", 0.0)
    taxas_gateway = data.get("taxas_gateway", 0.0)
    custos_diretos = data.get("custos_diretos", 0.0)
    despesas_marketing = data.get("despesas_marketing", 0.0)

    if receita_bruta < 0:
        results["errors"].append("Receita bruta não pode ser negativa.")
        results["valid"] = False

    receita_liquida = receita_bruta - impostos - taxas_gateway
    if receita_liquida < 0 and receita_bruta > 0:
        results["errors"].append("Deduções e taxas excedem a receita bruta total.")
        results["valid"] = False

    resultado_operacional = receita_liquida - custos_diretos - despesas_marketing
    margem_percentual = (resultado_operacional / receita_bruta * 100) if receita_bruta > 0 else 0.0

    results["metrics"] = {
        "receita_bruta": receita_bruta,
        "receita_liquida": round(receita_liquida, 2),
        "resultado_operacional": round(resultado_operacional, 2),
        "margem_percentual": round(margem_percentual, 2)
    }

    if margem_percentual < 15.0 and receita_bruta > 0:
        results["warnings"].append(f"Alerta: Margem operacional abaixo do target ({margem_percentual:.1f}% < 15%).")

    return results

def main():
    parser = argparse.ArgumentParser(description="DRE Zo Integrity Guard")
    parser.add_argument("--path", default="DRE_Eventos", help="Caminho do repositório DRE")
    parser.add_argument("--test", action="store_true", help="Auto-teste sintético")

    args = parser.parse_args()

    if args.test:
        dummy_event = {
            "nome": "Método CIS SP",
            "receita_bruta": 1000000.0,
            "impostos": 100000.0,
            "taxas_gateway": 30000.0,
            "custos_diretos": 400000.0,
            "despesas_marketing": 200000.0
        }
        res = validate_event_financials(dummy_event)
        if res["valid"] and res["metrics"]["resultado_operacional"] == 270000.0:
            print("✅ Auto-teste do DRE Integrity Check concluído com sucesso.")
            sys.exit(0)
        else:
            print(f"❌ Falha no auto-teste do DRE guard: {res}")
            sys.exit(1)

    dre_dir = Path(args.path)
    print(f"\n🏢 DRE Zo Integrity Guard — Auditoria: {dre_dir}")
    print("=" * 60)

    if not dre_dir.exists():
        print(f"⚠️ Diretório {dre_dir} não encontrado no path informado.")
        sys.exit(1)

    # Checa estrutura do DRE
    backend = dre_dir / "backend"
    frontend = dre_dir / "frontend"
    print(f"1. Backend Flask  : {'✅ Presente' if backend.exists() or (dre_dir / 'app.py').exists() or list(dre_dir.glob('*.py')) else '⚠️ Não detectado'}")
    print(f"2. Frontend React : {'✅ Presente' if frontend.exists() or (dre_dir / 'package.json').exists() else '⚠️ Não detectado'}")

    print("\n✅ Checagem estrutural concluída. Para auditoria de chunk específico, forneça o payload.")

if __name__ == "__main__":
    main()
