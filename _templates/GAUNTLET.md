# GAUNTLET.md — [NOME DO PROJETO]

> Extensão do protocolo universal (rules/gauntlet-protocol.md).
> Este arquivo define checks ESPECÍFICOS deste projeto além do mínimo universal.
> O mínimo universal NUNCA é reduzido — apenas estendido aqui.

## Stack

- **Linguagem:** [Python | Node/TS | Go | Apex | ...]
- **Framework:** [Flask | Next.js | Hono | ...]
- **Testes:** [pytest | jest | vitest | go test | ...]

## Comando único de verificação

```bash
# Ideal: um comando que roda TUDO
make verify
# ou: npm run check
# ou: ./scripts/verify.sh
```

## Thresholds

| Métrica | Mínimo | Atual |
|---|---|---|
| Coverage (linhas) | 80% | [preencher] |
| Coverage (branches) | 70% | [preencher] |
| Mutation score | [se aplicável] | [preencher] |
| Lint errors | 0 | — |
| Lint warnings novos | 0 | — |
| Type errors | 0 | — |

## Checks adicionais (além do mínimo universal)

- [ ] Testes Gherkin/BDD: [comando]
- [ ] Testes E2E: [comando]
- [ ] Testes de performance: [comando, se aplicável]
- [ ] Security scan: [comando, se aplicável]
- [ ] Build de produção: [comando]

## Ambiente de validação

- **Local:** [sim/não — quais checks rodam local]
- **CI:** [GitHub Actions | outro — quais checks rodam em CI]
- **Staging:** [URL — quais checks rodam em staging antes de prod]

## Notas específicas

- [Qualquer particularidade deste projeto que o agente precise saber]
- [Ex: "banco de dados de teste é SQLite em memória, não Postgres"]
- [Ex: "testes E2E requerem Docker rodando"]
