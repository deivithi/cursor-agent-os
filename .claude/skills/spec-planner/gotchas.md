# ⚠️ Gotchas — spec-planner

## 1. Arquivo fantasma no plano
**Sintoma:** Plano referencia `src/utils/helpers.ts` mas o arquivo não existe.
**Causa:** Plano gerado sem verificação via Glob.
**Fix:** SEMPRE confirmar existência de arquivos com Glob antes de incluir no plano. Se for arquivo novo, marcar como "Criar".

## 2. Diagrama Mermaid quebrado
**Sintoma:** Mermaid renderiza erro ou nada.
**Causa:** Syntax incorreta — parênteses, aspas, ou keywords inválidos.
**Fix:** Validar syntax mentalmente. Testar com blocos simples primeiro. Usar `mermaid-diagrams` skill como referência.

## 3. Acceptance criteria subjetivos
**Sintoma:** Critério como "código limpo" ou "boa performance" — impossível verificar.
**Causa:** Pressa na geração do plano.
**Fix:** Todo critério deve responder SIM/NÃO. Se não pode ser verificado com assert ou teste manual, reescrever.

## 4. Plano monolítico para projeto complexo
**Sintoma:** Plano com 20+ steps em sequência linear para feature complexa.
**Causa:** Não decompôs em fases.
**Fix:** Se plano excede 10 steps ou 10 arquivos, sugerir `spec-phases` para decomposição.

## 5. Contexto insuficiente do codebase
**Sintoma:** Plano ignora padrões existentes (ex: já existe utility que faz o mesmo).
**Causa:** Exploração superficial do codebase.
**Fix:** Usar subagente Explore com thoroughness "medium" ou "very thorough". Buscar padrões existentes ANTES de propor novos.

## 6. Handoff sem AGENTS.md
**Sintoma:** Agente externo não segue convenções do projeto.
**Causa:** Prompt de handoff não inclui contexto do projeto.
**Fix:** Verificar se existe AGENTS.md ou CLAUDE.md e incluir convenções no prompt de handoff.
