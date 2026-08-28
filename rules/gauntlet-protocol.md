# 🧪 Gauntlet Protocol — Confiança via Restrições Automatizadas

> Ativa sempre. Protocolo universal de verificação para QUALQUER agente.
> Princípio: *"O operador NÃO lê código gerado por agentes. A confiança vem
> exclusivamente do gauntlet automatizado. Done = passou o gauntlet."*
>
> Filosofia (Deivithi, 2026): cercar agentes com restrições extremas — testes
> unitários, Gherkin/BDD, QA, métricas, mutação, cobertura — de modo que passar
> pelo gauntlet É o sinal de qualidade. Sem leitura manual como fallback.

---

## 1. Regra fundamental

```
Tarefa completa ⟺ gauntlet aplicável passou.
Sem gauntlet executado → NÃO declarar "pronto", "feito", "resolvido".
```

Nenhum agente (Qwen Code, Cursor, Claude Code, Codex, ou outro) declara
entrega completa sem executar e reportar o resultado do gauntlet.

---

## 2. Hierarquia de verificação (mínimo universal)

Ordem de execução. Falha em qualquer nível → parar e corrigir antes de avançar.

| # | Check | Critério de aprovação |
|---|---|---|
| 1 | **Testes unitários** | Todos passam. Zero `.skip`/`xfail` novo sem aceite (test-integrity §1) |
| 2 | **Lint + Type-check** | Zero errors novos. Warnings novos devem ser justificados ou corrigidos |
| 3 | **Testes de integração / E2E** | Passam (se existem no projeto) |
| 4 | **Coverage** | ≥ threshold do projeto (default: 80% se não definido em GAUNTLET.md) |
| 5 | **Reviewer-agent** | Sem findings acima do threshold de severity (workflow-patterns §2) |
| 6 | **Checks de deploy** | vibe-deploy-guard (se aplicável a deploy) |

Projetos com `GAUNTLET.md` próprio podem adicionar checks além do mínimo.
O mínimo universal NUNCA é reduzido — apenas estendido.

---

## 3. Mínimos por stack

### Python (Flask, scripts, automações)
```bash
pytest -q                          # testes unitários
ruff check .                       # lint
ruff format --check .              # formatação (se configurado)
pytest --cov --cov-fail-under=80   # coverage (ou threshold do GAUNTLET.md)
```

### Node.js / TypeScript
```bash
npm test                           # testes (jest, vitest, mocha — o q existir)
npx tsc --noEmit                   # type-check
npx eslint . --max-warnings=0      # lint (ou config do projeto)
npm run build                      # build (se aplicável)
```

### Go
```bash
go test -race ./...                # testes com race detector
go vet ./...                       # vet
golangci-lint run                  # lint (se instalado)
go test -coverprofile=cover.out && go tool cover -func=cover.out  # coverage
```

### Salesforce (Apex, LWC, Flows)
```bash
sf project deploy start --check-only   # deploy check
sf apex run test --synchronous         # Apex tests
```

### Flask + React (DRE_Eventos)
```bash
cd backend && pytest -q && ruff check .
cd frontend && npm test && npx tsc --noEmit
```

### Sem stack identificada
Usar o mínimo universal (§2) com os comandos disponíveis.
Se nenhum comando de teste existe → gap policy (§4).

---

## 4. Gap policy (contexto-dependente)

Quando o projeto NÃO tem gauntlet configurado ou o gauntlet é incompleto:

### Produção / Deploy → BLOQUEAR
```
🧪 Gauntlet Protocol — BLOQUEIO

Este projeto não tem verificação automatizada suficiente para deploy.
Checks ausentes: [lista]

Não declaro completo até que existam. Posso criar os testes necessários — confirma?
```

### Protótipo / Experimento → FLAG + PROPOR
```
⚠️ GAUNTLET INCOMPLETO — confiança: BAIXA

Checks executados: [lista do que passou]
Checks ausentes: [lista]
Risco: [1 linha — o que pode estar errado sem verificação]

Proposta: criar [testes/checks específicos] para elevar confiança.
```

### Ambíguo → PERGUNTAR
```
🧪 Gauntlet Protocol — contexto necessário

Este trabalho é para produção ou é protótipo/experimento?
(Define se bloqueio ou entrego com flag)
```

---

## 5. GAUNTLET.md por projeto

Cada projeto PODE ter um `GAUNTLET.md` na raiz estendendo o mínimo universal.
Template em `_templates/GAUNTLET.md`.

Conteúdo esperado:
- Stack e comandos de verificação
- Thresholds específicos (coverage, mutation score, lint strictness)
- Checks adicionais (Gherkin, E2E, performance, segurança)
- Ambiente de validação (local, CI, staging)
- Comando único de verificação (ideal: `make verify` ou `npm run check`)

Se o projeto tem GAUNTLET.md → usá-lo COMO EXTENSÃO do mínimo (§2), nunca como substituição.

---

## 6. Comportamento quando teste falha

Referência completa: `test-integrity.md`.

Resumo operacional:
1. Default: corrigir o CÓDIGO, não o teste
2. Teste obsoleto (spec mudou)? → propor ao operador com o PORQUÊ
3. Incerteza? → perguntar, não adivinhar
4. NUNCA deletar/skip/enfraquecer teste sem aceite explícito

---

## 7. Report de gauntlet (formato de entrega)

Ao declarar tarefa completa, incluir SEMPRE:

```
✅ Gauntlet executado:
- [check 1]: PASS
- [check 2]: PASS
- [check N]: PASS
- Coverage: [X%] (threshold: [Y%])
- Reviewer-agent: [sem findings | N findings abaixo do threshold]
```

Ou, se incompleto (protótipo):
```
⚠️ Gauntlet parcial:
- [check 1]: PASS
- [check ausente]: NÃO EXECUTADO — [motivo]
- Confiança: [BAIXA|MÉDIA]
```

---

## 8. Anti-patterns

- ❌ Declarar "pronto" / "feito" / "resolvido" sem executar NENHUM check
- ❌ Rodar só lint e chamar de gauntlet completo
- ❌ Ignorar coverage abaixo do threshold ("tá quase")
- ❌ Pular reviewer-agent em implementação não-trivial
- ❌ Criar teste vazio (`pass` / `assert True`) para inflar coverage
- ❌ Rodar gauntlet, falhar, e entregar mesmo assim sem flag
- ❌ Assumir que "funciona na minha máquina" substitui verificação automatizada
- ❌ Reduzir threshold de coverage para passar (test-integrity §1.6)

---

## 9. Integração com outras rules

| Rule | Relação |
|---|---|
| `test-integrity.md` | Protege testes de serem removidos/enfraquecidos. Gauntlet exige que rodem |
| `workflow-patterns.md` §2 | Reviewer-agent é o nível 5 do gauntlet |
| `workflow-patterns.md` §4 | "Nunca marcar completo sem provar" — gauntlet formaliza o "provar" |
| `vibe-deploy-guard.md` | Nível 6 do gauntlet (checks de deploy) |
| `human-architectural-gate.md` | Gate ANTES de implementar; gauntlet DEPOIS de implementar |
| `anti-sycophancy.md` | Agente não pode bajular dizendo "tá pronto" sem rodar checks |
| `calibration.md` | Report de gauntlet inclui nível de confiança quando incompleto |

---

## 10. Exemplos

### Cenário A — projeto com gauntlet completo
```
User: "implementa endpoint de export CSV"

Agente:
1. Implementa código
2. Cria testes unitários (test-integrity: testes novos são incentivados)
3. Roda: pytest -q → PASS
4. Roda: ruff check → PASS
5. Roda: pytest --cov → 84% (threshold 80%) → PASS
6. Reviewer-agent → sem findings críticos
7. Report:
   ✅ Gauntlet executado:
   - pytest: 12 passed
   - ruff: 0 errors
   - coverage: 84% (≥80%)
   - reviewer: clean
```

### Cenário B — protótipo sem testes
```
User: "faz um script rápido pra validar os dados do CSV"

Agente:
1. Implementa script
2. Roda: python script.py --dry-run → funciona
3. Report:
   ⚠️ GAUNTLET INCOMPLETO — confiança: BAIXA
   - Execução manual: OK
   - Testes unitários: NÃO EXISTEM
   - Lint: ruff check → PASS
   Proposta: criar test_script.py com casos de borda.
```

### Cenário C — deploy bloqueado
```
User: "deploy do DRE_Eventos"

Agente:
🧪 Gauntlet Protocol — BLOQUEIO

Checks ausentes para deploy:
- Testes do frontend (npm test não configurado)
- Build check (npm run build nunca rodou)

Não deployo sem verificação. Posso configurar os checks — confirma?
```
