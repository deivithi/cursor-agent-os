# Gauntlet — avaliador automático com score e catraca

Regra: `rules/gauntlet-protocol.md` §11 · Decisão: `DECISIONS.md` ADR-015.

O agente melhora contra uma métrica que ele não controla. Gates binários bloqueiam. Um score
0-100 ranqueia. A baseline só sobe. O feedback em texto diz o que corrigir.

## Instalar (uma vez)

```powershell
py -3 scripts/gauntlet/install_hooks.py      # registra o Stop hook no Claude Code e no Cursor
py -3 scripts/gauntlet/install_hooks.py --uninstall
```

O instalador é idempotente e grava backup `*.bak-gauntlet`.

## Ativar num projeto

```powershell
py -3 scripts/gauntlet/gauntlet.py init --project <dir>   # gera gauntlet.json (python | node | go)
git -C <dir> add gauntlet.json; git -C <dir> commit -m "chore: gauntlet"
py -3 scripts/gauntlet/gauntlet.py run --project <dir>    # 1ª execução cria a baseline
```

Projeto Python: o `init` também gera `gauntlet.coveragerc` (coverage sem os arquivos de teste). Commite os dois.

Depois disso, nada mais é manual. O hook roda ao fim de cada turno do agente, se o código mudou.

## Comandos

| Comando | Faz |
|---|---|
| `run [--json] [--no-ratchet]` | Avalia. Exit 0 `keep`/`same`/`incomplete`/`baseline` · 1 `fail` · 2 `regress` · 3 sem projeto · 4 lock ocupado |
| `status` | Baseline e últimas 10 linhas do histórico |
| `accept --reason "..."` | Rebaixa a baseline para o estado atual. **Só com aceite do operador.** Fica no `history.tsv` e o hook avisa o operador |
| `hook` | Stop hook (lê JSON do stdin). Fail-open: erro vai para `~/.claude/gauntlet-hook.log` |

## `gauntlet.json`

```jsonc
{
  "gates":   [{"name": "pytest", "cmd": ["{python}", "-m", "pytest", "..."], "junit": "{state}/junit.xml",
               "env": {"COVERAGE_FILE": "{state}/.coverage"}}],
  "metrics": [{"name": "coverage", "source": "coverage_json", "path": "{state}/coverage.json",
               "weight": 70, "norm": "percent"},
              {"name": "complexidade_c901", "cmd": ["{python}", "-m", "ruff", "check", ".", "--select", "C901",
               "--output-format", "json", "--exit-zero"], "source": "ruff_json_count",
               "weight": 30, "norm": {"type": "inverse", "k": 20}}],
  "integrity": {"tests_glob": ["tests/**/*.py"], "protected": ["gauntlet.json", "pytest.ini"]},
  "ratchet":  {"min_gain": 0.3, "tolerance": 0.3},
  "hook":     {"enabled": true, "max_blocks": 3}
}
```

- Placeholders: `{python}` (venv do projeto, senão o Python do hook), `{state}` (`.gauntlet/`), `{project}`.
- Caminho relativo é relativo ao projeto. `cmd` em lista roda sem shell. Em string, roda com shell.
- `source`: `coverage_json` · `ruff_json_count` · `regex` (com `"regex"` que captura 1 número).
- `norm`: `percent` · `{"type": "inverse", "k": K}` (menor é melhor) · `{"type": "linear", "min", "max", "lower_is_better"}`.

## Vereditos

| Veredito | Quando | Baseline |
|---|---|---|
| `baseline` | 1ª execução com gates verdes | criada |
| `keep` | score ≥ baseline + `min_gain` | sobe |
| `same` | dentro do ruído | fica (contagens de integridade sobem) |
| `incomplete` | alguma métrica indisponível | fica (score parcial não é comparável) |
| `regress` | score < baseline − `tolerance` | fica; feedback por arquivo/função |
| `fail` | gate ou integridade falhou | fica; score 0 |

## Integridade (anti reward hacking)

Comparada com o **último estado aprovado** (avaliação verde ou `accept`), não com o HEAD: commitar não apaga a checagem,
e mudanças antigas já aprovadas não voltam a contar. O estado aprovado é um commit (`git stash create`, preso em
`refs/gauntlet/<projeto>` contra o `gc`) mais o hash dos arquivos não rastreados. O `gauntlet.json` também tem o hash
guardado: desligar o hook (`enabled: false`) ou quebrar o JSON bloqueia.

| Check | Falha quando |
|---|---|
| Testes | executados caem; pulados sobem |
| Asserts | asserts **não triviais** caem (`assert True` não conta) |
| Marcadores | linha nova em teste com skip/skipif/xfail/only/importorskip/SkipTest |
| Supressão | linha nova em **código-fonte** (fora de `dist/`, `build/`, `*.min.*`, `*.d.ts`, `generated/`, `vendor/` e de `integrity.suppress_ignore`) com `# noqa` nu, `# noqa: C901`, `# pragma: no cover`, `istanbul ignore`, `eslint-disable`, `c8 ignore` |
| Protegidos | arquivo de `integrity.protected` mudou desde a baseline |

Mudança legítima nesses pontos → o operador aprova com `accept --reason`.

## Hook: quando roda e quando para

- Só roda em projeto que a sessão **editou** (Edit/Write) ou no `cwd`, se a sessão usou ferramenta que muda arquivo. Ler arquivo não dispara.
- Sem mudança desde a última avaliação: < 0,5 s, silêncio. Transcript lido de forma incremental.
- Para de bloquear quando: `max_blocks` seguidos, nenhuma pendência resolvida (estagnação), ou teto de `2 × max_blocks` na sessão.
- Orçamento de 700 s por turno; timeout mata a árvore de processos; gate sem tempo vira `incomplete`, não `fail`.
- Shell só conta como mudança se o comando escreve (`sed -i`, `>`, `git commit`, `Set-Content`...). `ls`/`git log` não.
- Teto de bloqueios da sessão zera só depois de 3 verdes seguidos (teste flaky alternando não zera).

## Estado (`<projeto>/.gauntlet/`, auto-ignorado pelo git)

`baseline.json` · `history.tsv` (ledger) · `state.json` (fingerprint, sessões do hook) ·
`junit.xml` · `coverage.json` · `lock`.

## Testes

```powershell
cd scripts/gauntlet; py -3 -m pytest tests -q
```

O próprio gauntlet tem `gauntlet.json`: editar este código dispara a mesma avaliação.
