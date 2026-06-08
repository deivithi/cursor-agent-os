---
name: careful
description: >
  Ativa modo cauteloso para a sessão. Bloqueia operações destrutivas (rm -rf, DROP TABLE,
  git reset --hard, git push --force) e exige confirmação antes de editar arquivos críticos.
  Use quando for trabalhar perto de produção, dados sensíveis ou operações irreversíveis.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
hooks:
  - type: PostToolUse
    matcher: "Bash"
    command: "bash \"$CLAUDE_PROJECT_DIR/.claude/scripts/careful-hook.sh\""
    timeout: 5
---

# 🛡️ Modo Cauteloso — ATIVADO

> **On-demand hook:** Este modo permanece ativo durante toda a sessão.

## Regras Ativas

### ⛔ Operações BLOQUEADAS (nunca executar sem confirmação explícita)

Os seguintes comandos/patterns estão **PROIBIDOS** nesta sessão a menos que o usuário EXPLICITAMENTE confirme:

| Categoria | Patterns Bloqueados |
|-----------|-------------------|
| **Filesystem** | `rm -rf`, `rm -r`, `rmdir`, `del /s` |
| **Git destrutivo** | `git reset --hard`, `git push --force`, `git push -f`, `git clean -f`, `git checkout .` |
| **Database** | `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` (sem WHERE) |
| **Kubernetes** | `kubectl delete`, `kubectl drain` |
| **Supabase** | `supabase db reset` (em produção) |

### ⚠️ Arquivos que EXIGEM confirmação antes de Edit/Write

- `.env`, `.env.*` — Variáveis de ambiente
- `*.json` em raiz do projeto — Configurações (package.json, tsconfig, etc.)
- `supabase/migrations/*` — Migrations de banco
- `.claude/settings*` — Configurações do Claude Code
- `vercel.json`, `netlify.toml` — Configurações de deploy

### ✅ Operações LIBERADAS

- Leitura de qualquer arquivo (Read, Glob, Grep)
- Edição de arquivos de código fonte (.ts, .tsx, .js, .md)
- Execução de testes e builds
- Git add, commit, status, diff, log
- Consulta a APIs (curl read-only)

## Comportamento do Assistente

Ao receber solicitação que envolva operação bloqueada:

1. **PARAR** antes de executar
2. **INFORMAR** o usuário sobre o risco da operação
3. **LISTAR** exatamente o que será feito e qual o impacto
4. **AGUARDAR** confirmação explícita ("sim, pode executar")
5. **LOGAR** a operação com timestamp

### Exemplo de Interação
```
Usuário: "Resete o banco de staging"
Assistente: "🛡️ MODO CAUTELOSO: Essa operação (`supabase db reset`) é destrutiva
e irá deletar TODOS os dados do banco de staging.

Impacto:
- Todas as tabelas serão dropadas
- Todos os dados serão perdidos
- Migrations serão reaplicadas do zero

Confirma a execução? (sim/não)"
```

## Para Desativar

Inicie uma nova sessão ou diga: "desativar modo cauteloso"

---

*🛡️ Modo cauteloso ativo. Operações destrutivas serão interceptadas.*
