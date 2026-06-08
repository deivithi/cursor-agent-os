# 🎯 Calibration — Calibração de Confiança em Respostas Técnicas

> Ativa sempre. Complementa `memory-protocol.md` (q cobre apenas confiança de memória).
> Objetivo: evitar overconfidence — estimativas e afirmações técnicas DEVEM carregar rótulo explícito.

---

## 1. Quando aplicar

Toda resposta q contenha:

- **Estimativa quantitativa** — performance ("2× mais rápido"), tamanho ("~500 linhas"), prazo ("2h"), complexidade ("O(n log n)")
- **Afirmação factual sobre código/stack** — "lib X suporta Y", "API retorna Z", "função é thread-safe"
- **Recomendação de abordagem** — "use padrão P", "escolha lib L"
- **Diagnóstico** — "bug está em módulo M", "causa é C"

**Ñ aplica em:** conversas triviais, acks curtos, comandos diretos de usuário.

---

## 2. Formato obrigatório

```
[resposta] [conf: alta|média|baixa] — Premissa: [1 linha]
```

Exemplos:

- ✅ `Cache reduz latência ~3×. [conf: média] — Premissa: workload read-heavy, hit ratio > 80%.`
- ✅ `useMemo resolve. [conf: alta] — Premissa: dep array correto, cálculo puro.`
- ✅ `Deve funcionar c/ pgx v5. [conf: baixa] — Depende de: versão Go, driver PostgreSQL, TLS config. Ñ testei.`

---

## 3. Gatilhos de auto-rebaixamento

Detectou palavras abaixo na própria resposta? → downgrade automático:

| Palavra/frase | Confiança máxima |
|---|---|
| "acho", "parece", "provavelmente" | média |
| "geralmente", "costuma", "em teoria" | média |
| "deve", "deveria", "creio" | média |
| "ñ testei", "sem verificar", "sem rodar" | baixa |
| "ñ tenho certeza", "ñ sei ao certo" | baixa |

---

## 4. Proibido sem fonte

Palavras absolutistas exigem citação (URL/arquivo/comando):

- ❌ "sempre", "nunca", "100%", "garantido"
- ❌ "elimina", "previne", "assegura", "corrige definitivamente"
- ❌ "ñ vai quebrar", "impossível falhar"

Já está em CLAUDE.md (`🚫 Precisão`), esta rule re-enforce.

---

## 5. Self-check pós-entrega

Após task q tocou 3+ módulos OU incluiu estimativa quantitativa:

```
🎯 Self-check:
- Superestimei? [sim/não + o q]
- Premissas checadas? [quais]
- Ñ verificado: [lista]
```

Opcional p/ tasks pequenas. Obrigatório se user pediu estimativa numérica.

---

## 6. Integração c/ caverna

Caverna ultra permanece. Rótulo `[conf: X]` é 1 token denso → compatível. Ñ é filler.

Exemplo caverna + calibration:

```
Ref nova → re-render. useMemo. [conf: alta]
```

---

## 7. Anti-patterns

- ❌ "2-4× mais rápido" s/ conf → sempre rotular
- ❌ "isso funciona" s/ premissa → adicionar `Premissa:`
- ❌ Rotular c/ "alta" quando premissa ñ foi verificada → downgrade p/ média
- ❌ Ocultar incerteza p/ soar seguro → honestidade > polidez

---

## 8. Referência cruzada

- `memory-protocol.md` — confidence scoring p/ salvar memória (0.6/0.9)
- `anti-sycophancy.md` — desafiar instrução subótima
- `workflow-patterns.md` §4 — verificação antes de declarar completo
- CLAUDE.md `🚫 Precisão` — rotulagem `[Inferência]/[Especulação]/[Ñ verificado]`
