# GitHub Action Setup — Claude Code Review

## Pré-requisitos

1. **ANTHROPIC_API_KEY** configurada como GitHub Secret
2. **GITHUB_TOKEN** já disponível por padrão

## Instalação

1. Copiar `.github/workflows/claude-review.yml` para o repositório alvo
2. Configurar secret:
   ```
   gh secret set ANTHROPIC_API_KEY --body "sk-ant-..."
   ```
3. Push e criar um PR para testar

## Notas

- GitHub Action é para repos remotos. Para repos locais, usar o modo polling do auto-pr-review
- O workflow só roda em PRs não-draft
- Custo: ~$0.10-0.50 por review (Opus) ou ~$0.01-0.05 (Haiku)
