# ⚠️ Gotchas — Skill Architect

Problemas conhecidos e workarounds na criação de skills.

---

## G-01: Description vaga = skill nunca ativa

**Sintoma:** Skill criada mas nunca é selecionada pelo agente.
**Causa:** Description genérica sem keywords de ativação.
**Fix:** Adicionar keywords explícitas entre aspas: `Use quando pedir "X", "Y", "Z"`.

## G-02: SKILL.md muito longo consome contexto desnecessário

**Sintoma:** Respostas do agente ficam diluídas quando a skill ativa.
**Causa:** SKILL.md com 500+ linhas de conteúdo que deveria estar em references/.
**Fix:** Hub ≤ 250 linhas. Mover detalhes para `references/`. Usar Progressive Disclosure.

## G-03: Skill ativa em contextos errados (false positive)

**Sintoma:** Skill é acionada para tarefas que não são seu escopo.
**Causa:** Description com termos genéricos demais ("ajuda com código", "análise").
**Fix:** Tornar o trigger mais específico. Adicionar seção "Quando NÃO Usar".

## G-04: Skill no diretório global vs. projeto

**Sintoma:** Duas versões da mesma skill (global `~/.claude/skills/` e projeto `.claude/skills/`).
**Causa:** Skill criada globalmente e depois replicada no projeto.
**Fix:** Projeto tem prioridade. Manter versão definitiva no projeto. Global como fallback.

## G-05: Gotchas seção vazia no dia 1

**Sintoma:** Skill nova sem gotchas documentados.
**Causa:** Normal — gotchas são descobertos com uso.
**Fix:** Criar gotchas.md com pelo menos 1 entrada. Atualizar a cada falha encontrada. "Dia 1: 1 entrada. Mês 3: 10 entradas."

## G-06: Chat-to-Skill extrai padrões errados

**Sintoma:** Skill criada de conversa captura preferências que eram contextuais, não permanentes.
**Causa:** Confundir decisão pontual com preferência estável.
**Fix:** SEMPRE validar com o usuário: "Extraí esses padrões. Correto?" Marcar como [Inferido] padrões com confiança < 0.8.

## G-07: Knowledge-to-Skill importa conhecimento datado

**Sintoma:** Skill baseada em curso/artigo com informação desatualizada.
**Causa:** Fonte original pode ter meses/anos.
**Fix:** Registrar data da fonte no frontmatter (`metadata.source`). Incluir gotcha: "Verificar se princípios ainda são válidos."

## G-08: Voice-to-Skill perde nuances da fala

**Sintoma:** Transcrição perde intenção, ênfase ou condicionais ("tipo", "mais ou menos").
**Causa:** Transcrição de voz é literal, não interpretativa.
**Fix:** Etapa CLEAN obrigatória: remover hesitações, reorganizar em tópicos, confirmar interpretação com usuário.

## G-09: Sub-skills sem coesão

**Sintoma:** Várias sub-skills criadas que não se integram bem.
**Causa:** Falta de planejamento de composição.
**Fix:** Usar padrão Pipeline do ADK. Definir handoff points entre sub-skills. Testar fluxo completo.

## G-10: Skill tenta fazer tudo (Frankenstein)

**Sintoma:** Trigger impreciso, execução parcial, agente confuso.
**Causa:** Múltiplas responsabilidades em uma skill.
**Fix:** Regra: 1 skill = 1 responsabilidade. Se description precisa de 3+ verbos de ação → dividir.
