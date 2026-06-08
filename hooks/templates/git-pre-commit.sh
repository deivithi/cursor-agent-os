#!/usr/bin/env sh
# git pre-commit hook (template) — boas práticas Akita/Galego
# Instala em <projeto>/.git/hooks/pre-commit via install-git-hooks.ps1
#
# Faz:
#   1. Branch protection local: bloqueia commit direto em main/master.
#   2. Test/lint gate: detecta a stack e roda o comando padrão; bloqueia se falhar.
#
# Bypass de emergência (use com parcimônia): git commit --no-verify
# Pular só o gate de testes (mantém branch protection): PRECOMMIT_SKIP_TESTS=1 git commit ...

set -e

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

# --- 1. Branch protection ---
case "$branch" in
  main|master)
    echo "🛑 pre-commit: commit direto em '$branch' bloqueado."
    echo "   Crie uma branch:  git switch -c feat/minha-mudanca"
    echo "   (bypass consciente: git commit --no-verify)"
    exit 1
    ;;
esac

if [ "${PRECOMMIT_SKIP_TESTS:-0}" = "1" ]; then
  echo "⏭️  pre-commit: testes pulados (PRECOMMIT_SKIP_TESTS=1). Branch protection ok."
  exit 0
fi

run() { echo "▶ $*"; "$@"; }

# --- 2. Test/lint gate por stack (primeiro manifesto encontrado vence) ---
if [ -f "go.mod" ]; then
  run gofmt -l .
  run go vet ./...
  run go test -race ./...
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  command -v ruff >/dev/null 2>&1 && run ruff check .
  run pytest -q
elif [ -f "package.json" ]; then
  # roda apenas scripts que existem
  if node -e "process.exit(require('./package.json').scripts?.lint?0:1)" 2>/dev/null; then run npm run lint --silent; fi
  if node -e "process.exit(require('./package.json').scripts?.typecheck?0:1)" 2>/dev/null; then run npm run typecheck --silent; fi
  if node -e "process.exit(require('./package.json').scripts?.test?0:1)" 2>/dev/null; then
    CI=1 run npm test --silent
  else
    echo "ℹ️  package.json sem script 'test' — pulando testes."
  fi
elif [ -f "Cargo.toml" ]; then
  run cargo test
else
  echo "ℹ️  pre-commit: stack não reconhecida — só branch protection aplicada."
fi

echo "✅ pre-commit: gate passou."
