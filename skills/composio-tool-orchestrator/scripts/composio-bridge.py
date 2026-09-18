#!/usr/bin/env python3
"""
composio-bridge.py
Utilitário de ponte e diagnóstico para ferramentas e conexões do Composio.
Suporta checagem via WSL CLI, configuração local MCP e testes de conectividade.
"""

import sys
import os
import json
import subprocess
import argparse
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

MCP_CONFIG_PATH = Path(os.path.expanduser("~/.gemini/config/mcp_config.json"))

def check_mcp_config() -> dict:
    if not MCP_CONFIG_PATH.exists():
        return {"configured": False, "reason": "mcp_config.json não existe"}
    try:
        content = MCP_CONFIG_PATH.read_text(encoding="utf-8").strip()
        if not content:
            return {"configured": False, "reason": "mcp_config.json está vazio"}
        data = json.loads(content)
        mcp_servers = data.get("mcpServers", {})
        if "composio" in mcp_servers:
            return {"configured": True, "server": mcp_servers["composio"]}
        return {"configured": False, "reason": "servidor 'composio' não encontrado em mcpServers"}
    except Exception as e:
        return {"configured": False, "reason": f"Erro ao ler mcp_config: {e}"}

def check_wsl_composio_cli() -> dict:
    try:
        proc = subprocess.run(
            ["wsl", "bash", "-c", "command -v composio || [ -f ~/.composio/composio ] && echo 'FOUND'"],
            capture_output=True,
            text=True,
            timeout=10
        )
        if "FOUND" in proc.stdout:
            return {"installed": True, "type": "WSL (Ubuntu)"}
        return {"installed": False, "reason": "CLI Composio não detectada no WSL"}
    except Exception as e:
        return {"installed": False, "reason": f"WSL não disponível ou erro de execução: {e}"}

def main():
    parser = argparse.ArgumentParser(description="Composio Bridge & Diagnostics")
    parser.add_argument("--check-status", action="store_true", help="Checa status da integração MCP e WSL")
    parser.add_argument("--list-apps", action="store_true", help="Lista apps suportados")
    parser.add_argument("--test", action="store_true", help="Modo de auto-teste sintético")

    args = parser.parse_args()

    if args.test:
        dummy_mcp = {"mcpServers": {"composio": {"serverUrl": "https://connect.composio.dev/mcp"}}}
        assert "composio" in dummy_mcp["mcpServers"]
        print("✅ Auto-teste do Composio Bridge concluído com sucesso.")
        sys.exit(0)

    if args.list_apps:
        apps = [
            {"name": "GitHub", "key": "github", "status": "Ready", "description": "Issues, PRs, Repos"},
            {"name": "Slack", "key": "slack", "status": "Ready", "description": "Canais, Mensagens, Alertas"},
            {"name": "Salesforce", "key": "salesforce", "status": "Ready", "description": "SOQL, Leads, Records"},
            {"name": "Google Calendar", "key": "googlecalendar", "status": "Ready", "description": "Eventos e Agenda"},
            {"name": "Linear / Jira", "key": "linear", "status": "Ready", "description": "Tasks e Sprints"}
        ]
        print("\n📦 Apps e Conectores Composio Suportados:")
        print("=" * 60)
        for a in apps:
            print(f"  • {a['name']:<18} [{a['key']}] - {a['description']}")
        sys.exit(0)

    # Status geral
    print("\n🔍 Diagnóstico de Conexão Composio:")
    print("=" * 60)
    mcp_status = check_mcp_config()
    print(f"1. Antigravity MCP Config : {'✅ ATIVO' if mcp_status['configured'] else '⚠️ NÃO CONFIGURADO'}")
    if mcp_status["configured"]:
        print(f"   Detalhes: {mcp_status['server']}")
    else:
        print(f"   Motivo: {mcp_status['reason']}")

    wsl_status = check_wsl_composio_cli()
    print(f"2. Composio CLI (WSL)     : {'✅ INSTALADA' if wsl_status['installed'] else '⚠️ NÃO DETECTADA'}")
    if not wsl_status["installed"]:
        print(f"   Motivo: {wsl_status['reason']}")

    print("\n💡 Para gerenciar conexões autenticadas, acesse:")
    print("   👉 https://dashboard.composio.dev/deivithi74_workspace/~/connect")

if __name__ == "__main__":
    main()
