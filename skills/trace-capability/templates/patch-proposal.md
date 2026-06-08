# Patch Proposal — {gap_id}: {capability_name}

> Gerado por: trace-capability Stage 3
> Skill alvo: {skill-name}
> Data: {YYYY-MM-DD HH:MM BRT}

---

## Gap Identificado

- **Taxonomy ID:** {IG-01|PR-02|TU-03|...}
- **Nome:** {capability_name}
- **Impact Score:** {score}
- **Gap Report:** {path do relatório Stage 1}

## Classificação do Patch

- **Tipo:** {knowledge|rule|tool|structural}
  - `knowledge` — SKILL.md falta instruções para esta capacidade
  - `rule` — Agente sabe mas aplica inconsistentemente
  - `tool` — Agente não usa a ferramenta certa
  - `structural` — Arquitetura da skill precisa redesign

## Evidência

### Pares contrastivos que demonstram o gap:

**Par 1:**
- PASS: {o que fez certo}
- FAIL: {o que faltou}
- Delta: {diferença observada}

**Par 2:**
- PASS: {o que fez certo}
- FAIL: {o que faltou}
- Delta: {diferença observada}

## Mudança Proposta

**Arquivo:** `{path completo}`
**Tipo de edição:** {adicionar seção|modificar passo|criar regra|reestruturar}

```markdown
{conteúdo proposto — diff ou bloco completo}
```

## Efeito Esperado

- **Métrica afetada:** {checklist item N / judge criteria / composite}
- **Direção:** {melhoria esperada}
- **Magnitude estimada:** {+X pontos baseado nos deltas observados}

## Riscos

- {risco de regressão em outro item}
- {risco de ultrapassar limite de linhas}
- {dependência de outro componente}

## Path de Integração

- [ ] Se `knowledge` → alimentar Ouroboros Step 2.2 como hipótese
- [ ] Se `rule` → append a `ouroboros/evolution/corrections.jsonl`
- [ ] Se `tool` → adicionar a gotchas.md da skill
- [ ] Se `structural` → flag para review humano (NÃO auto-apply)
