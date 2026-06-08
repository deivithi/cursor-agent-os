# Gotchas — spec-evaluate

## G1: Spec em formato livre (sem estrutura)
**Problema:** Spec chegou como paragrafo de texto, sem secoes, sem acceptance criteria.
**Solucao:** Antes de avaliar, pedir para o usuario reformatar OU oferecer para gerar versao estruturada a partir do texto.
**Nao fazer:** Tentar avaliar texto livre — os 12 criterios nao se aplicam sem estrutura.

## G2: Score inflado por tipo de spec
**Problema:** Epic Brief recebe Sim automatico em C3-C6 (opcionais), inflando o score.
**Solucao:** Usar tabela da secao 6 do SKILL.md. Criterios opcionais nao contam no denominador.
**Calculo correto:** Score = (soma dos pontos dos criterios obrigatorios) / (max pontos obrigatorios) * 100.

## G3: Perguntas vagas que nao ajudam
**Problema:** "Voce quer adicionar edge cases?" nao gera resposta util.
**Solucao:** Formular cenarios concretos: "Quando o usuario tenta login com email invalido, deve mostrar 'Email invalido' ou redirecionar para signup?"
**Regra:** Cada pergunta deve ter 2-3 opcoes concretas quando possivel.

## G4: Loop infinito de re-evaluate
**Problema:** Cada rodada de perguntas gera novas perguntas, spec nunca avanca.
**Solucao:** Max 2 rodadas de perguntas. Na 3a iteracao:
- Se score >= 70: aprovar com ressalvas, registrar gaps como notas
- Se score < 70: escalar para spec-epic (elicitacao mais profunda)

## G5: File hints que referenciam arquivos inexistentes
**Problema:** Spec diz "modificar src/auth/login.tsx" mas arquivo nao existe.
**Solucao:** Se codebase access disponivel, validar via Glob. Marcar C6 como Parcial se >30% dos paths nao existem.
**Nao fazer:** Reprovar spec inteira por paths — pode ser arquivo a criar.

## G6: Boundaries 3-tier ausente em projetos pequenos
**Problema:** Projeto simples (landing page, script) nao justifica 3-tier formal.
**Solucao:** Para specs com <= 2 sprints e complexidade Simples, C8 (Boundaries) e opcional. Registrar como "N/A — projeto simples".

## G7: Spec em JSON sem campo esperado
**Problema:** Spec JSON usa nomes de campo diferentes (ex: "tasks" em vez de "sprints").
**Solucao:** Aceitar variantes comuns: sprints/phases/waves/stages, features/tasks/items, acceptance/criteria/definition_of_done.
**Nao fazer:** Rejeitar por nomenclatura — avaliar pelo conteudo.

## G8: Avaliar spec que ja esta sendo implementada
**Problema:** Codigo ja esta sendo escrito, evaluate roda tarde demais.
**Solucao:** Ainda avaliar — gaps encontrados viram issues para spec-verify. Registrar: "Avaliacao pos-inicio — gaps viram issues de verificacao".
