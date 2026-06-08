# Sprint Contract Protocol

> Fonte: [Anthropic Engineering — Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03-24)
> "The generator proposed what it would build and how success would be verified, and the evaluator reviewed that proposal to make sure the generator was building the right thing."

## Propósito

Antes de cada sprint de trabalho, **Generator e Evaluator negociam um contrato** que define exatamente o que é "done". Isso elimina:
- Scope creep silencioso
- Trabalho que não será avaliável
- Critérios de aceite ambíguos

## Quando Usar

- Tarefas com 3+ features ou componentes
- Qualquer build que terá QA formal
- Sempre que `/do` for executado com evaluator no loop

## Formato do Contrato

```markdown
## Sprint Contract #N

### Scope
- [ ] Feature A: descrição concreta do que será implementado
- [ ] Feature B: descrição concreta
- [ ] Feature C: descrição concreta

### Acceptance Criteria (por feature)
| Feature | Critério de Aceite | Como Verificar |
|---------|-------------------|----------------|
| A | Usuário consegue X | Playwright: navegar → clicar → verificar |
| B | API retorna Y dado Z | curl/fetch → assert response |
| C | Estado persiste após reload | Criar → reload → verificar |

### Fora do Escopo (explícito)
- O que NÃO será feito neste sprint
- Evita que evaluator cobre features não planejadas

### Definition of Done
- [ ] Todos os acceptance criteria PASS
- [ ] Zero bugs CRITICAL ou HIGH
- [ ] Score mínimo: 7.0/10 (weighted)
```

## Fluxo

```
Generator propõe contrato
       ↓
Evaluator revisa:
  ├── Aceita → Sprint inicia
  ├── Ajusta → Negocia escopo/critérios
  └── Rejeita → Generator reformula
       ↓
Sprint executa (Generator implementa)
       ↓
Evaluator avalia contra o contrato
  ├── 🟢 PASS → Próximo sprint
  ├── 🟡 CONDITIONAL → Fixes + re-avaliação
  └── 🔴 FAIL → Re-implementação ou pivot
```

## Regras

1. **Contrato ANTES de código** — Nunca começar a implementar sem contrato aceito
2. **Contrato é imutável durante o sprint** — Mudanças só no próximo sprint
3. **Evaluator avalia APENAS o que está no contrato** — Bugs fora do escopo são registrados mas não bloqueiam
4. **Critérios devem ser verificáveis** — "Boa UX" não é critério; "usuário completa fluxo em 3 cliques" é
5. **Fora do escopo é tão importante quanto o escopo** — Previne gold plating
