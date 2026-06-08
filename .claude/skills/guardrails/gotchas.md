# ⚠️ Gotchas — Guardrails

## 1. Falso positivo em input guard com texto legítimo

**Sintoma:** Texto sobre "instrução para ignorar" é bloqueado (ex: manual de treinamento).
**Causa:** Regex `ignore.*previous.*instructions` é muito amplo.
**Solução:** Usar threshold de 2+ padrões matched para BLOCK. 1 padrão = SUSPICIOUS, não BLOCK.
**Prevenção:** Testar com corpus de textos legítimos antes de ativar em produção.

## 2. PII redaction com CPF inválido

**Sintoma:** Números aleatórios no formato XXX.XXX.XXX-XX são redactados mesmo sem ser CPF.
**Causa:** Regex de CPF não valida dígitos verificadores.
**Solução:** Adicionar validação de dígitos verificadores (mod 11) antes de redactar.
**Prevenção:** Para dados internos conhecidos, usar allowlist de formatos válidos.

## 3. Action auth bypass via alias

**Sintoma:** `git push -f` não é bloqueado (lista só contém `git push --force`).
**Causa:** Lista de ações destrutivas não cobre todas as variações de flags.
**Solução:** Normalizar aliases antes de comparar (ex: `-f` → `--force`).
**Prevenção:** Manter lista de aliases por comando.

## 4. Output guard trunca JSON no meio

**Sintoma:** JSON de resposta fica inválido após truncamento.
**Causa:** Size guard corta no byte 100000 sem respeitar estrutura.
**Solução:** Truncar no último `}` ou `]` válido antes do limite.
**Prevenção:** Comprimir JSON (remover whitespace) antes de aplicar size guard.

## 5. Encoding attack em múltiplas camadas

**Sintoma:** URL-encoded + Base64-encoded injection passa pelo guard.
**Causa:** Guard só decodifica uma camada de encoding.
**Solução:** Aplicar decodificação recursiva (max 3 camadas) antes da análise.
**Prevenção:** Rejeitar inputs com mais de 2 camadas de encoding como SUSPICIOUS.
