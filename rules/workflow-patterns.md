# 🔄 Workflow Patterns & Plano Node Default

## 1. 📋 Planejamento

- Plan Mode para **QUALQUER** tarefa não trivial (3+ passos ou decisões arquiteturais)
- Se algo der errado, **PARE** e replaneje — não continue insistindo
- Especificações detalhadas reduzem ambiguidades
- **Progress updates:** Para tarefas 3+ passos: `✅ [feito] → 🔄 [próximo]`

## 2. 🤖 Subagentes & Reviewer-Agent por Etapa

**Leitura/pesquisa — use com liberdade (paralelo OK):**

- Descarregue pesquisa, exploração e análise para manter contexto principal limpo
- Uma tarefa por subagente; leitura de muitos arquivos/pesquisa extensa → SEMPRE delegue
- Paralelismo de leitura/exploração não tem teto — não há gargalo de revisão aqui

**Implementação — reviewer-agent obrigatório por etapa (resolve o "gargalo humano"):**

> Akita/Galego alertam: a 4+ agentes em paralelo o **humano** vira gargalo de revisão.
> Resolução adotada: em vez de limitar agentes, **um agente revisor independente revisa cada etapa** — humano sai do loop de revisão de rotina.

- Toda etapa de implementação (feature, fix não-trivial, refactor) passa por **agente revisor independente** ANTES de avançar/mergear
- Revisor roda em **contexto isolado** (`context: fork` ou subagente próprio), **adversarial** (tenta refutar/achar bug, não aprovar), com `data/severity-config.json`
- Motor de review: skill `code-review` + `spec-verify`; automação contínua já existe em `auto-pr-review` (n8n + `gh`)
- Loop: implementa → revisor reporta findings c/ severity → corrige acima do threshold → revisor re-checa → avança. Sem humano no meio.
- 🛡️ **Salvaguarda (humano permanece):** `human-architectural-gate.md` retém o humano em cripto / LGPD / sanitização de BD / operações destrutivas — o reviewer-agent NÃO substitui o gate nesses domínios irreversíveis.

## 3. 🔁 Auto-Melhoria

- Após correção do usuário: atualizar `tasks/lessons.md`
- Escrever regras que impeçam o mesmo erro
- Revisar lições no início da sessão

## 4. ✅ Verificação

- Nunca marcar tarefa como completa sem provar que funciona
- Perguntar: "Um engenheiro staff aprovaria isso?"
- Executar testes, verificar logs, demonstrar correção
- **Reviewer-agent é parte da verificação** (§2): "pronto" = passa testes **E** o agente revisor não tem finding acima do threshold. Sem review = não-pronto.
- Não enfraquecer/deletar teste p/ "provar que funciona" (`rules/test-integrity.md`)

## 5. 💎 Elegância (Equilibrada)

- Mudanças não triviais: "Existe forma mais elegante?"
- Gambiarra detectada: "Implemente a solução elegante"
- Correções simples: não exagerar na engenharia

## 6. 🐛 Correção Autônoma de Bugs

- Recebeu relatório de bug → apenas corrija (zero troca de contexto)
- Aponte logs, erros, testes falhando → resolva
- Corrija CI falhando sem que lhe digam como

## 📌 Gerenciamento de Tarefas

1. Planejar em `tasks/todo.md` com itens verificáveis
2. Confirmar plano antes de implementar
3. Marcar progresso conforme avança
4. Resumo de alto nível em cada etapa
5. Capturar lições em `tasks/lessons.md`

## 7. ⚡ Atalhos de Sessão

- **`/btw`** — side query sem interromper agent em execução (perguntas rápidas enquanto subagente trabalha)
- **`/voice`** — push-to-talk para prompts por voz (mais detalhados e naturais que digitados)
- **`/rewind` ou `Esc Esc`** — desfazer última ação que saiu do caminho, voltar ao checkpoint anterior
- **`--bare`** — startup 10x mais rápido (sem auto-discovery de MCPs). Usar para tasks quick: `claude --bare -p "git log --oneline -5"`
- **`/sandbox`** — isola file/network access, reduz permission prompts em ~84%. Testar em sessões de dev

## 8. 🔀 Git & PRs

- **Squash merge** como padrão — histórico limpo, revert fácil, `git bisect` funcional
- **PRs pequenas** — mediana ideal: ~120 linhas, p90 < 500 linhas. PRs menores = menos bugs
- **Commit ao menos 1x por hora** durante sessões longas — manter reversibilidade

## 9. 🧩 Context Fork vs Worktree

- **`isolation: worktree`** — isola o código (git worktree separado). Usar para implementação paralela
- **`context: fork`** — isola a conversa (contexto limpo). Usar para pesquisa, code review, exploração que polui contexto
- **Regra:** Pesquisa/análise → `context: fork` (mais leve). Implementação → `isolation: worktree` (mais seguro)

## 🎯 Princípios

- **Simplicidade Primeiro** — menor impacto de código possível
- **Sem Preguiça** — causas raízes, sem correções temporárias, padrão sênior
- **IA coda → agente revisa → humano arquiteta** — modelo operacional: a IA gera a maior parte do **código**; um agente revisor independente valida cada etapa (§2/§4); o **humano** arquiteta, decide trade-offs e detém os gates irreversíveis (`human-architectural-gate.md`). A IA _acelera_, não substitui o pensar/arquitetar (Akita/Galego)

## 10. 🔁 Rule Re-Hidratação

- Após `/compact` → re-ler `MEMORY.md` + rules ativas relevantes à task em andamento
- Sessão > 30 turnos → auto-checkpoint mental: "qual rule tocou esta task? ainda estou seguindo?"
- Violação de rule detectada (própria ou instruída pelo user) → flag imediato via `anti-sycophancy.md`, ñ prosseguir silenciosamente
- Rules são contrato — esquecer rule = bug, ñ feature
