# 🧪 Test Integrity — Testes São Contrato, Não Obstáculo

> Ativa sempre que a sessão tocar testes (criar, editar, rodar, refatorar) ou quando um
> teste falhar. Complementa `workflow-patterns.md` §4 (verificação) e `vibe-deploy-guard.md`.
> Reforçada pelo hook `hooks/git-safety-guard.js` (preToolUse).
>
> Princípio (do vídeo Akita/Galego): _"Testes ficaram baratos com IA. Ela nunca pode
> deletar um teste sem que você aceite o delete."_ Teste removido p/ "fazer passar" é
> dívida oculta — esconde regressão, não corrige.

---

## 1. Proibições (exigem aceite explícito do operador)

NUNCA, sem confirmação explícita do usuário, fazer qualquer um destes p/ "ficar verde":

1. **Deletar** arquivo/caso de teste (`*_test.*`, `test_*`, `*.spec.*`, `*.test.*`).
2. **Desabilitar** — `.skip`, `it.skip`, `describe.skip`, `xit`, `xdescribe`, `t.Skip()`, `@pytest.mark.skip`, `@unittest.skip`, `@Disabled`, `#[ignore]`.
3. **Marcar como esperado-falhar** sem motivo registrado — `xfail`, `@pytest.mark.xfail`, `t.Skip` condicional, `expect(...).fail`.
4. **Comentar** o corpo do teste ou o assert.
5. **Enfraquecer assert** — trocar valor esperado pelo valor errado observado, afrouxar tolerância, trocar `toEqual` por `toBeTruthy`, remover assert, alargar regex/range só p/ passar.
6. **Reduzir cobertura** — baixar threshold de coverage, remover teste do runner/CI, excluir path do glob de testes.

---

## 2. Comportamento correto quando um teste falha

```
Teste falhou
  ↓
O teste está certo e o código errado?  → corrigir o CÓDIGO (default)
O teste está obsoleto (spec mudou de propósito)? → propor mudança ao operador c/ o PORQUÊ
Não tenho certeza?                       → perguntar, não adivinhar
```

Ordem de preferência: **corrigir código** > **ajustar teste com aceite** > (último recurso, com aceite) desabilitar.

Regra de ouro: _o teste codifica a intenção_. Se a intenção mudou, o operador confirma a nova intenção. Se não mudou, o código é que precisa ceder.

---

## 3. Formato de pedido de aceite (verbose — safety carve-out, sem caverna)

Detectou necessidade de tocar um teste de forma proibida (§1)? PARE e emita:

```
🧪 Test Integrity — aceite necessário

Teste afetado: [arquivo::caso]
Ação pretendida: [deletar | skip | xfail | enfraquecer assert | baixar coverage]
Motivo: [por que — 1-2 linhas]
Alternativa considerada: [corrigir código? por que não bastou?]

Confirma a alteração no teste? [s/n]
```

Sem aceite → não alterar. Seguir corrigindo o código.

---

## 4. Quando NÃO bloquear

- Criar testes novos (sempre incentivado — testes ficaram baratos).
- Refatorar teste **mantendo** a mesma asserção/intenção (rename, extrair helper, parametrizar).
- Corrigir teste objetivamente quebrado (typo no nome de função sob teste, import errado) — registrar 1 linha.
- Remover teste duplicado **idêntico** a outro que permanece — registrar qual cobre.
- Usuário já autorizou explicitamente nesta sessão (citar a referência).

---

## 5. Integração com ferramental de testes

- A skill `test-driven-development` define o ciclo Red-Green-Refactor e o **comando padrão de rodar testes** por stack (`go test -race ./...`, `pytest -q`, `npm test`, etc.).
- TDD escreve o teste primeiro (Red); esta rule garante que ninguém apague o Red p/ fingir Green.
- Pré-entrega: a suíte DEVE rodar verde **sem** testes desabilitados novos. Teste desabilitado = item de checklist pendente, não "pronto".

---

## 6. Anti-patterns

- ❌ `// TODO: arrumar depois` + `it.skip` p/ entregar no prazo.
- ❌ Trocar `assert result == 42` por `assert result is not None` p/ passar.
- ❌ Deletar `test_payment_refund.py` pq "estava quebrando o build".
- ❌ Baixar `coverageThreshold` de 80→50 em vez de cobrir o código novo.
- ❌ `xfail` sem `reason=` e sem registro do porquê.

---

## 7. Referência cruzada

- `test-driven-development` (skill) — ciclo TDD + comando de testes por stack
- `alpha-loop` (skill) — itera código até os testes passarem (sem mexer nos testes)
- `workflow-patterns.md` §4 — nunca declarar completo sem provar que funciona
- `vibe-deploy-guard.md` — checks de deploy
- `hooks/git-safety-guard.js` — enforcement preToolUse (remoção de teste → pede confirmação)
- `human-architectural-gate.md` — mesma filosofia: humano decide o irreversível
