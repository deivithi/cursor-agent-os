# ⚠️ Alpha Loop — Gotchas

## 1. Rewrite completo a cada iteração
**Sintoma:** O agente reescreve todo o código em vez de corrigir cirurgicamente.
**Causa:** Sem análise de falha antes do refine.
**Fix:** SEMPRE diagnosticar QUAL sub-função falhou antes de alterar código.

## 2. Testes AI-generated com bugs
**Sintoma:** Testes adicionais geram falsos negativos (test está errado, não o código).
**Causa:** AI gerou teste com expected output incorreto.
**Fix:** Se um teste falha mas a lógica parece correta, validar o TESTE antes de mudar o código. Executar manualmente com input do teste.

## 3. Loop infinito em edge case obscuro
**Sintoma:** Corrigir edge case A quebra edge case B e vice-versa.
**Causa:** Abordagem fundamental não suporta ambos os cases.
**Fix:** EXIT STUCK → voltar a Solution Candidates e escolher abordagem diferente. Não insistir na mesma.

## 4. Over-modularization
**Sintoma:** 15 funções de 2 linhas cada — mais difícil de entender que o monolito original.
**Causa:** Aplicação mecânica da regra "dividir em sub-funções".
**Fix:** Modularizar apenas quando a função tem 20+ linhas OU lógica independente. 3 linhas inline é melhor que uma helper desnecessária.

## 5. Ignorar PASS_TO_PASS
**Sintoma:** Bug fix resolve o problema principal mas quebra funcionalidade existente.
**Causa:** Foco apenas nos fail_to_pass, sem rodar testes existentes.
**Fix:** SEMPRE rodar TODOS os testes (públicos + AI + existentes) a cada iteração, não apenas os que falharam.
