#!/usr/bin/env python3
"""
validate-salesforce-spec.py
Valida a completude e conformidade de especificações técnicas Salesforce / BDD.
Garante que o documento contenha Modelo de Dados, FLS, Gherkin e Matriz de Testes Apex.
"""

import sys
import re
import argparse
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

REQUIRED_SECTIONS = [
    (r"(?i)#+.*(?:contexto|objetivo|business)", "Contexto de Negócio & Objetivos"),
    (r"(?i)#+.*(?:modelo de dados|schema|seguran[çc]a|fls)", "Modelo de Dados & Segurança"),
    (r"(?i)#+.*(?:l[óo]gica|automa[çc][ãa]o|arquitetura|trigger|flow)", "Lógica de Automação & Arquitetura"),
    (r"(?i)(?:Feature:|Cen[áa]rios BDD|Gherkin)", "Cenários BDD / Gherkin"),
    (r"(?i)#+.*(?:matriz de testes|apex|@istest|gauntlet)", "Matriz de Testes Apex / Gauntlet Check"),
]

GHERKIN_KEYWORDS = [r"\bGiven\b|\bDado\b", r"\bWhen\b|\bQuando\b", r"\bThen\b|\bEnt[ãa]o\b"]

def validate_spec(content: str) -> dict:
    results = {
        "valid": True,
        "missing_sections": [],
        "gherkin_valid": True,
        "gherkin_warnings": [],
        "has_bulk_test_mention": False,
        "has_fls_mention": False
    }

    # 1. Checar seções obrigatórias
    for pattern, name in REQUIRED_SECTIONS:
        if not re.search(pattern, content):
            results["missing_sections"].append(name)
            results["valid"] = False

    # 2. Validar palavras-chave do Gherkin
    for kw in GHERKIN_KEYWORDS:
        if not re.search(kw, content, re.IGNORECASE):
            results["gherkin_warnings"].append(f"Palavra-chave BDD ausente ou incompleta: {kw}")

    # 3. Validar requisitos de robustez do Gauntlet
    if re.search(r"(?i)200\s*registros|bulk|lote", content):
        results["has_bulk_test_mention"] = True
    else:
        results["gherkin_warnings"].append("Alerta: Nenhuma menção explícita a teste de volume/bulk (200 registros).")

    if re.search(r"(?i)fls|permission\s*set|sharing|field\s*level", content):
        results["has_fls_mention"] = True
    else:
        results["gherkin_warnings"].append("Alerta: Nenhuma menção explícita a FLS / Permission Sets.")

    return results

def main():
    parser = argparse.ArgumentParser(description="Validador de Especificações Salesforce BDD")
    parser.add_argument("--spec", help="Caminho para o arquivo Markdown de especificação")
    parser.add_argument("--test", action="store_true", help="Executa auto-teste sintético")

    args = parser.parse_args()

    if args.test:
        dummy_valid_spec = """
        # [SF-SPEC-001] Distribuição de Leads
        ## 1. Contexto de Negócio & Objetivos
        Melhorar SLA de atendimento de leads na Febracis.
        ## 2. Modelo de Dados & Segurança (Schema & FLS)
        Campos customizados no Lead. Permission Set para Consultores. FLS protegido.
        ## 3. Lógica de Automação & Arquitetura
        LeadTriggerHandler para After Insert.
        ## 4. Cenários BDD / Gherkin
        Feature: Distribuição
          Scenario: Lead Quente
            Given consultor ativo
            When novo lead criado
            Then atribuir proprietário
        ## 5. Matriz de Testes Apex / Gauntlet Check
        Teste com 200 registros (bulk test) e seeAllData=false.
        """
        res = validate_spec(dummy_valid_spec)
        if res["valid"] and not res["missing_sections"]:
            print("✅ Auto-teste concluído com sucesso: validador operando normalmente.")
            sys.exit(0)
        else:
            print(f"❌ Falha no auto-teste: {res}")
            sys.exit(1)

    if not args.spec:
        print("Erro: Especifique um arquivo via --spec ou use --test")
        sys.exit(1)

    path = Path(args.spec)
    if not path.exists():
        print(f"Erro: Arquivo não encontrado: {path}")
        sys.exit(1)

    content = path.read_text(encoding="utf-8")
    report = validate_spec(content)

    print(f"\n📋 Relatório de Validação Salesforce BDD Spec: {path.name}")
    print("=" * 60)
    if report["valid"]:
        print("✅ Status Geral: ESPECIFICAÇÃO VÁLIDA (Todas as seções presentes)")
    else:
        print("❌ Status Geral: ESPECIFICAÇÃO INCOMPLETA")
        print("\nSeções ausentes:")
        for s in report["missing_sections"]:
            print(f"  - ❌ {s}")

    if report["gherkin_warnings"]:
        print("\nAlertas / Sugestões:")
        for w in report["gherkin_warnings"]:
            print(f"  - ⚠️ {w}")

    sys.exit(0 if report["valid"] else 1)

if __name__ == "__main__":
    main()
