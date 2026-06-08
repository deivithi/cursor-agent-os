# Git Hooks Templates — Branch Protection + Test Gate

> Boas práticas do vídeo Akita/Galego: nunca commitar em `main` sem PR; rodar lint/testes
> antes de cada commit. Duas camadas de defesa:
>
> | Camada                     | Arquivo                  | Protege contra                             |
> | -------------------------- | ------------------------ | ------------------------------------------ |
> | **Agente** (preToolUse)    | `../git-safety-guard.js` | o agente commitar em main / deletar testes |
> | **Git real** (por projeto) | `git-pre-commit.sh`      | qualquer commit (humano ou agente)         |

## Instalar num projeto

```powershell
pwsh hooks\templates\install-git-hooks.ps1 -ProjectPath C:\caminho\do\repo
# reinstalar por cima:  $env:FORCE_INSTALL=1; pwsh ...\install-git-hooks.ps1 -ProjectPath ...
```

## O que o pre-commit faz

1. **Branch protection** — bloqueia `git commit` direto em `main`/`master`.
2. **Test/lint gate** — detecta a stack pelo manifesto e roda:
   - Go → `gofmt -l . && go vet ./... && go test -race ./...`
   - Python → `ruff check .` (se houver) + `pytest -q`
   - Node → `npm run lint`/`typecheck`/`test` (só os scripts existentes)
   - Rust → `cargo test`

## Bypass (consciente)

- Pular tudo: `git commit --no-verify`
- Pular só testes (mantém branch protection): `PRECOMMIT_SKIP_TESTS=1 git commit ...`

## Notas

- O hook é copiado com quebras de linha **LF** (git no Windows roda hooks via `sh`).
- Combina com `rules/test-integrity.md` (não enfraquecer testes p/ passar o gate) e o
  reviewer-agent de `workflow-patterns.md` §2 (review antes do merge).
