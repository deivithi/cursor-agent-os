"""Smoke tests for refresh_dre_cache_tmp.py (stdlib only).

Sem MCP: valida help e mensagens de erro.
Com MCP (opcional): valida meta e venv_check.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

HELPER = Path(__file__).resolve().parent / "refresh_dre_cache_tmp.py"


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(HELPER), *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=120,
    )


def test_help():
    r = run("help")
    assert r.returncode == 0, r.stderr
    for token in ("meta", "refresh_source", "zo_bash", "parquet_check", "pre", "lock"):
        assert token in r.stdout, f"missing {token} in help"


def test_unknown_action():
    r = run("acao_inexistente_xyz")
    assert r.returncode != 0
    assert "desconhecida" in (r.stderr + r.stdout).lower()


def test_refresh_source_requires_arg():
    r = run("refresh_source")
    assert r.returncode != 0
    assert "refresh_source" in (r.stderr + r.stdout)


def test_mcp_optional():
    """Falha graciosa ou sucesso — prova que MCP está acessível quando configurado."""
    r = run("venv_check")
    combined = r.stdout + r.stderr
    if r.returncode == 0 and ("VENV_OK" in combined or "VENV_MISSING" in combined):
        print("mcp_ok: venv_check respondeu")
        return
    if "mcp.json" in combined.lower() or "servidor zo" in combined.lower():
        print("mcp_skip: Zo MCP não configurado neste ambiente")
        return
    raise AssertionError(f"venv_check inesperado: rc={r.returncode} out={combined[:500]}")


if __name__ == "__main__":
    test_help()
    test_unknown_action()
    test_refresh_source_requires_arg()
    test_mcp_optional()
    print("smoke_ok")
