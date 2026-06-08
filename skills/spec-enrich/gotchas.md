# Gotchas — spec-enrich

## G1: Falsos positivos em contradições
**Problema:** Diferença de terminologia interpretada como contradição (ex: "user" vs "usuário", "payment" vs "checkout").
**Solução:** Antes de reportar contradição, verificar se é apenas variação de termo. Se os significados convergem, não é contradição.

## G2: Enriquecer demais (40+ itens)
**Problema:** Spec grande gera muitos achados, sobrecarregando o usuário.
**Solução:** Priorizar: contradições > gaps na spec > edge cases. Apresentar top 15-20 mais críticos. Restantes como "itens menores" colapsáveis.

## G3: Inventar features disfarçadas de edge cases
**Problema:** "E se tivesse dark mode?" ou "E se suportasse múltiplos idiomas?" não são edge cases — são features novas.
**Solução:** Edge case = cenário dentro do escopo existente que não foi especificado. Se requer nova funcionalidade, não é edge case.

## G4: Contexto contaminado
**Problema:** Se o agente leu o histórico da conversa onde a spec foi gerada, ele já tem viés de confirmação.
**Solução:** Usar subagente com contexto limpo (apenas spec + PRD como input). Nunca rodar enrich no mesmo thread que gerou a spec.

## G5: Spec sem PRD para comparar
**Problema:** Usuário tem spec mas não gerou PRD formal (ex: spec escrita manualmente).
**Solução:** Só Categoria C (edge cases) é possível. Categorias A e B requerem PRD para comparação. Informar ao usuário e sugerir gerar PRD via spec-epic se quiser análise completa.

## G6: Contradição real vs decisão deliberada
**Problema:** Às vezes spec difere do PRD intencionalmente (decisão técnica sobrescreveu requisito de negócio).
**Solução:** Sempre apresentar como pergunta, nunca corrigir automaticamente. O usuário decide se é contradição ou decisão consciente.
