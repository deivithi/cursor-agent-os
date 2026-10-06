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

A parte **executável** do gauntlet vive em `gauntlet.json` (§11). O `GAUNTLET.md` explica; o `gauntlet.json` roda sozinho.

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
| `adaptive-depth.md` | Hook usa I(t): pendências não caíram → libera (estagnação) |

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

---

## 11. Gauntlet contínuo — score, catraca e hook automático (ADR-015)

> Base: Wang/Meta (Startup School 2026, paráfrase) — o enxame só rende com "o loop certo + a métrica certa".
> Karpathy autoresearch (métrica única + keep/discard + git), Anthropic "Demystifying evals for AI agents"
> (grader code-based, resistente a hack), EvilGenie/ImpossibleBench (agentes editam testes p/ passar).

**Pass/fail diz "pare". Score contínuo diz "para onde melhorar".** O gauntlet tem as duas camadas:

| Camada | O que é | Efeito |
|---|---|---|
| Gates | Comandos binários (testes, lint, type-check, build) | Qualquer falha zera o score → `fail` |
| Integridade | Comparada com o commit da baseline: testes executados não caem; skips não sobem; asserts não triviais não caem; sem skip/xfail/only novo em teste; sem `noqa` nu / `noqa: C901` / `pragma: no cover` novo em código; arquivos `protected` sem mudança | Violação zera o score → `fail` |
| Score 0-100 | Métricas normalizadas × pesos (ex.: coverage 70 + complexidade C901 30) | Ranqueia a mudança |
| Catraca | Baseline em `.gauntlet/baseline.json`; só sobe | `keep` ≥ baseline + `min_gain` · `regress` < baseline − `tolerance` · `same` no meio |

**Motor:** `scripts/gauntlet/gauntlet.py` (stdlib, Windows/Linux). Comandos: `init`, `run [--json]`, `status`, `accept`, `hook`.

**Automático, sem comando do operador:**

1. O hook `Stop` (Claude Code e Cursor) roda ao fim de cada turno do agente.
2. Ele acha projetos com `gauntlet.json` pelos arquivos **editados** na sessão, pelo `cwd` (se a sessão mudou arquivo) e pelas raízes do workspace (Cursor). Ler arquivo não dispara.
3. Sem mudança no código desde a última avaliação → custo < 0,5 s, silêncio.
4. Código mudou → roda o gauntlet. Passou → linha de status ao operador. Falhou/regrediu → **bloqueia o fim do turno** e devolve o feedback ao agente, que continua corrigindo.
5. Saída do loop: `max_blocks` (padrão 3) **ou** estagnação — nenhuma pendência anterior foi resolvida (`adaptive-depth.md`: I(t)=0 → EXIT) **ou** teto de `2 × max_blocks` na sessão. Libera com aviso para o agente relatar as pendências.
6. Instalação dos hooks: `py -3 scripts/gauntlet/install_hooks.py` (idempotente, com backup; o operador roda uma vez).

**Regras para o agente:**

- Projeto novo com testes e sem `gauntlet.json` → rodar `gauntlet.py init` + `run` (baseline) e commitar o `gauntlet.json`. Ajustar pesos ao projeto.
- Feedback do hook = trabalho do agente (ADR-010). Corrigir o **código**, nunca o teste nem o avaliador.
- `gauntlet.py accept --reason "..."` rebaixa a baseline → **só com aceite explícito do operador** (spec mudou de propósito). Fica no histórico e o hook avisa o operador.
- Mudança em arquivo `protected` só passa com `accept` do operador — commitar não basta.
- Report de entrega (§7) inclui a linha do gauntlet: `score X (baseline Y, verdict)`.

**Limites conhecidos (não esconder):**

- Mutation testing não roda nativo no Windows (`mutmut` exige fork). Entra quando houver CI Linux noturno.
- Coverage pode ser inflado com teste fraco; asserts não triviais e o reviewer-agent (§2 nível 5) compensam em parte. O LLM-judge **não** roda no hook (custo por turno).
- Coverage do Python exclui os arquivos de teste (`gauntlet.coveragerc`); no DRE o número real caiu de 86% para 77%.
- O agente consegue rodar `accept` sozinho; a defesa é a trilha (histórico + aviso ao operador), não bloqueio. O hook é guarda-corpo, não controle de acesso.
- Mudança de outra pessoa depois do último verde (commit, pull) também é avaliada; se for supressão/protegido, só o `accept` libera.
- Cursor não informa arquivos editados: avalia os projetos das raízes do workspace quando o código muda.
- Sem git, a integridade cobre só contagens (testes, asserts, skips); diff de skip/supressão/protegido exige git.
- Revisão adversarial em 3 rodadas (21 → 17 → 9 achados); LOW restantes: corrida rara no lock velho e custo do `git diff --binary` com binário rastreado grande modificado.

---

## 12. Referências da pesquisa (06/10/2026)

- https://github.com/karpathy/autoresearch — métrica única, budget fixo, keep/discard via git, `results.tsv`
- https://anthropic.com/engineering/demystifying-evals-for-ai-agents — tipos de grader, resistência a hack, pass@k vs pass^k
- https://arxiv.org/abs/2511.21654 (EvilGenie) — detecção de edição de teste e LLM-judge funcionam; holdout ajuda pouco
- https://arxiv.org/abs/2510.20270 (ImpossibleBench) — atalhos: editar assert, special-case, `sys.exit(0)`
- https://arxiv.org/abs/2507.19457 (GEPA) — feedback textual rende mais que escalar
- https://stryker-mutator.io/docs/stryker-js/incremental/ · https://mutmut.readthedocs.io/ — mutation incremental
- Wang/Meta: só paráfrase verificada (https://cryptobriefing.com/meta-ai-agent-swarm-outperforms-engineers/) — não citar como aspas literais
