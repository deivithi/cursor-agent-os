#!/usr/bin/env python3
"""
gauntlet-runner.py
Orquestrador unificado para execução e validação do Gauntlet Protocol (ADR-008).
Detecta stacks, executa suites de testes, linters e cobertura, emitindo saída estruturada.
"""

import sys
import os
import json
import subprocess
import time
import argparse
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

def detect_stack(project_dir: Path) -> list:
    """Detecta os comandos padrão de Gauntlet aplicáveis ao diretório."""
    checks = []

    # 1. Checa se existe GAUNTLET.md personalizado
    gauntlet_file = project_dir / "GAUNTLET.md"
    if gauntlet_file.exists():
        # Retorna indicador para parse do GAUNTLET.md local se necessário
        pass

    # 2. DRE_Eventos (estrutura mista Backend/Frontend)
    if (project_dir / "backend").exists() and (project_dir / "frontend").exists():
        checks.append({"name": "Backend Unit Tests", "cmd": "pytest -q", "cwd": str(project_dir / "backend")})
        checks.append({"name": "Backend Lint", "cmd": "ruff check .", "cwd": str(project_dir / "backend")})
        checks.append({"name": "Frontend Type-Check", "cmd": "npx tsc --noEmit", "cwd": str(project_dir / "frontend")})
        return checks

    # 3. Python puro
    if (project_dir / "pyproject.toml").exists() or (project_dir / "requirements.txt").exists() or list(project_dir.glob("*.py")):
        checks.append({"name": "Python Lint (Ruff)", "cmd": "ruff check .", "cwd": str(project_dir)})
        checks.append({"name": "Python Unit Tests & Coverage", "cmd": "pytest -q --cov --cov-fail-under=80", "cwd": str(project_dir)})

    # 4. Node.js / TypeScript
    if (project_dir / "package.json").exists():
        checks.append({"name": "TypeScript Type-Check", "cmd": "npx tsc --noEmit", "cwd": str(project_dir)})
        checks.append({"name": "Node Tests", "cmd": "npm test --if-present", "cwd": str(project_dir)})

    # 5. Go
    if (project_dir / "go.mod").exists():
        checks.append({"name": "Go Tests with Race Detector", "cmd": "go test -race ./...", "cwd": str(project_dir)})
        checks.append({"name": "Go Vet", "cmd": "go vet ./...", "cwd": str(project_dir)})

    # 6. Salesforce DX
    if (project_dir / "sfdx-project.json").exists():
        checks.append({"name": "Salesforce Validation Deploy", "cmd": "sf project deploy start --check-only", "cwd": str(project_dir)})

    return checks

def run_check(check: dict) -> dict:
    start_time = time.time()
    try:
        proc = subprocess.run(
            check["cmd"],
            shell=True,
            cwd=check.get("cwd", "."),
            capture_output=True,
            text=True,
            timeout=180
        )
        duration = round(time.time() - start_time, 2)
        return {
            "name": check["name"],
            "command": check["cmd"],
            "passed": proc.returncode == 0,
            "exit_code": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "duration_sec": duration
        }
    except subprocess.TimeoutExpired:
        return {
            "name": check["name"],
            "command": check["cmd"],
            "passed": False,
            "exit_code": -1,
            "stdout": "",
            "stderr": "Execution timed out after 180 seconds",
            "duration_sec": 180.0
        }
    except Exception as e:
        return {
            "name": check["name"],
            "command": check["cmd"],
            "passed": False,
            "exit_code": -1,
            "stdout": "",
            "stderr": str(e),
            "duration_sec": round(time.time() - start_time, 2)
        }

def main():
    parser = argparse.ArgumentParser(description="Gauntlet Runner (ADR-008)")
    parser.add_argument("--project-path", default=".", help="Diretório do projeto a ser verificado")
    parser.add_argument("--json-output", action="store_true", help="Emite resultado em formato JSON")
    parser.add_argument("--test", action="store_true", help="Modo de auto-teste sintético")

    args = parser.parse_args()

    if args.test:
        dummy_checks = [
            {"name": "Self-Test Check 1", "cmd": "python -c \"print('OK')\"", "cwd": "."}
        ]
        res = [run_check(c) for c in dummy_checks]
        all_passed = all(r["passed"] for r in res)
        if all_passed:
            print("✅ Auto-teste do Gauntlet Runner concluído com sucesso.")
            sys.exit(0)
        else:
            print(f"❌ Falha no auto-teste do runner: {res}")
            sys.exit(1)

    project_dir = Path(args.project_path).resolve()
    if not project_dir.exists():
        print(f"Erro: Caminho não encontrado: {project_dir}")
        sys.exit(1)

    checks = detect_stack(project_dir)
    if not checks:
        print(f"⚠️ Nenhuma stack ou suite de testes detectada automaticamente em {project_dir}.")
        print("Consulte rules/gauntlet-protocol.md para configurar o GAUNTLET.md deste projeto.")
        sys.exit(0)

    results = []
    all_passed = True

    print(f"\n🧪 Executando Gauntlet Protocol (ADR-008) em: {project_dir}")
    print("=" * 70)

    for chk in checks:
        print(f"▶️ Executando: {chk['name']} (`{chk['cmd']}`)... ", end="", flush=True)
        res = run_check(chk)
        results.append(res)
        if res["passed"]:
            print(f"✅ PASS ({res['duration_sec']}s)")
        else:
            print(f"❌ FAIL ({res['duration_sec']}s)")
            all_passed = False

    if args.json_output:
        print("\n" + json.dumps({"passed": all_passed, "checks": results}, indent=2))
    else:
        print("\n" + "=" * 70)
        if all_passed:
            print("🎉 GAUNTLET STATUS: 100% APROVADO — Entrega válida.")
        else:
            print("🛑 GAUNTLET STATUS: FALHA — Autocura necessária (Self-Healing).")
            for r in results:
                if not r["passed"]:
                    print(f"\n[FAIL] {r['name']} (Code {r['exit_code']}):")
                    if r["stderr"]:
                        print(f"Stderr:\n{r['stderr'].strip()}")
                    if r["stdout"]:
                        print(f"Stdout:\n{r['stdout'].strip()[:500]}")

    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
