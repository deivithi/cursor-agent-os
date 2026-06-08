---
name: freeze
description: >
  Ativa modo read-only para a sessão. Impede qualquer Edit ou Write em arquivos.
  Permite apenas leitura, busca e comandos bash read-only. Use para sessões de
  investigação, debugging ou exploração onde você não quer mudanças acidentais.
allowed-tools: Bash, Read, Glob, Grep, Agent, WebFetch, WebSearch
---

# 🧊 Modo Freeze (Read-Only) — ATIVADO

> **On-demand hook:** Este modo permanece ativo durante toda a sessão.

## Regras Ativas

### ⛔ Ferramentas BLOQUEADAS

| Ferramenta | Status | Motivo |
|-----------|--------|--------|
| **Edit** | 🔒 BLOQUEADO | Não pode modificar arquivos |
| **Write** | 🔒 BLOQUEADO | Não pode criar/sobrescrever arquivos |
| **NotebookEdit** | 🔒 BLOQUEADO | Não pode editar notebooks |

### ✅ Ferramentas LIBERADAS

| Ferramenta | Status | Uso |
|-----------|--------|-----|
| **Read** | ✅ LIVRE | Ler qualquer arquivo |
| **Glob** | ✅ LIVRE | Buscar arquivos por pattern |
| **Grep** | ✅ LIVRE | Buscar conteúdo em arquivos |
| **Bash** | ⚠️ READ-ONLY | Apenas comandos que não modificam (git status, ls, cat, curl GET) |
| **Agent** | ✅ LIVRE | Subagentes de exploração e pesquisa |
| **WebFetch** | ✅ LIVRE | Buscar conteúdo web |
| **WebSearch** | ✅ LIVRE | Pesquisar na web |

### ⚠️ Bash — Apenas Read-Only

No modo Freeze, comandos Bash devem ser **somente leitura**:

**Permitidos:**
```bash
git status, git log, git diff, git branch
ls, pwd, which, echo, cat, head, tail
curl (GET only), node -e (sem fs.write)
npm list, npx vercel ls
```

**Bloqueados:**
```bash
git add, git commit, git push, git reset
npm install, npm update
rm, mv, cp, mkdir, touch
```

## Quando Usar

- 🔍 **Debugging:** Investigar um bug sem risco de alterar o código
- 📊 **Análise:** Explorar o codebase para entender arquitetura
- 📋 **Auditoria:** Revisar código sem possibilidade de alteração acidental
- 🔬 **Investigação:** Runbook de incidente — coletar dados sem interferir

## Comportamento do Assistente

1. **NÃO usar Edit ou Write** em nenhuma circunstância
2. Se o usuário pedir para editar algo: informar que o modo Freeze está ativo
3. Se precisar salvar notas: apresentar o conteúdo em texto para o usuário copiar
4. Focar em **observação, análise e relatório**

### Exemplo de Interação
```
Usuário: "Corrija esse bug no arquivo X"
Assistente: "🧊 MODO FREEZE ativo — não posso editar arquivos nesta sessão.

Posso:
1. Analisar o bug e explicar a causa
2. Propor a correção em texto para você aplicar
3. Desativar o freeze se quiser que eu corrija

Qual prefere?"
```

## Para Desativar

Inicie uma nova sessão ou diga: "desativar freeze"

---

*🧊 Modo freeze ativo. Nenhum arquivo será modificado nesta sessão.*
