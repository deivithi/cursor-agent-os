# 🧬 Evolve — Evolution Audit & Promotion Ladder

Você é o agente de evolução do sistema. Audita correções acumuladas, observações e regras existentes para propor promoções, graduações e podas.

**Argumentos:** $ARGUMENTS
Formato: `[--dry-run] [--scope corrections|rules|trends|all]`

---

## Fase 1: Carregar Estado

1. **Ler corrections log:**
   ```bash
   cat ouroboros/evolution/corrections.jsonl 2>/dev/null
   ```

2. **Ler learned-rules:**
   ```bash
   cat ouroboros/evolution/learned-rules.md 2>/dev/null
   ```

3. **Ler evolution-log (últimas 20 decisões):**
   ```bash
   tail -20 ouroboros/evolution/evolution-log.md 2>/dev/null
   ```

4. **Ler rules atuais:**
   ```bash
   ls .claude/rules/*.md
   ```

5. **Ler session scorecards:**
   ```bash
   cat ouroboros/evolution/sessions.jsonl 2>/dev/null
   ```

Se corrections.jsonl estiver vazio e não houver learned-rules, informar: *"Sistema limpo — nenhuma correção acumulada. Use o sistema normalmente e as correções serão capturadas automaticamente."*

---

## Fase 2: Análise de Correções

Para cada pattern único em corrections.jsonl:

1. **Contar ocorrências** (quantas vezes o pattern aparece)
2. **Contar sessões distintas** em que apareceu
3. **Classificar por frequência** (mais frequente primeiro)

Apresentar tabela:

| Pattern | Categoria | Ocorrências | Sessões | Status |
|---------|-----------|-------------|---------|--------|
| ... | ... | N | M | pending/promoted/graduated |

---

## Fase 3: Propor Ações

Para cada pattern/regra, aplicar a **Promotion Ladder**:

### Tier 1: Correction → Learned Rule (automático)
- **Critério:** Pattern aparece 2x+
- **Ação:** PROMOTE para `ouroboros/evolution/learned-rules.md`
- **Script:** `bash ouroboros/scripts/log-correction.sh` já faz isso automaticamente

### Tier 2: Learned Rule → Path-Scoped Rule (10+ sessões)
- **Critério:** Regra em learned-rules está ativa por 10+ sessões
- **Ação:** GRADUATE para `.claude/rules/{category}.md` como nova seção
- **Requer:** Aprovação humana

### Tier 3: Path-Scoped Rule → Core Rule (universal)
- **Critério:** Regra se aplica a TODOS os paths (não apenas um domínio)
- **Ação:** GRADUATE para CLAUDE.md (seção Code Style ou Regras)
- **Requer:** Aprovação humana + regra deve ser ≤ 2 linhas

### Poda
- **Critério:** Regra em learned-rules com 0 ocorrências nas últimas 10 sessões
- **Ação:** PRUNE — mover para evolution-log como rejeitada
- **Requer:** Aprovação humana

---

## Fase 4: Apresentar Propostas

Para cada ação proposta, mostrar:

```
📊 EVOLUTION AUDIT — {data}

### Propostas de Evolução

1. 🟢 PROMOTE: "{pattern}" → learned-rules.md
   Motivo: {N}x em {M} sessões
   Verify: `{regex}`

2. 🔵 GRADUATE: "{rule}" → .claude/rules/{file}.md
   Motivo: Ativa por {N} sessões, {M} ocorrências
   Impacto: Carrega em paths: {paths}

3. 🔴 PRUNE: "{rule}" — remover de learned-rules
   Motivo: 0 ocorrências em 10+ sessões
   Destino: evolution-log.md (arquivado)

Aprovar? (s/n por item, ou "all" para todas)
```

Se `--dry-run`: mostrar propostas mas NÃO executar.

---

## Fase 5: Executar Aprovadas

Para cada proposta aprovada:

1. **PROMOTE:** Já é automático via log-correction.sh
2. **GRADUATE:**
   - Adicionar regra ao arquivo .claude/rules/{category}.md apropriado
   - Remover de learned-rules.md
   - Registrar em evolution-log.md
3. **PRUNE:**
   - Remover de learned-rules.md
   - Registrar em evolution-log.md como "pruned"

---

## Fase 6: Trend Report

Se `--scope trends` ou `--scope all`:

1. Ler `ouroboros/evolution/sessions.jsonl`
2. Calcular tendências:
   - **Correções/sessão:** média móvel (5 sessões)
   - **Tendência:** ↗ crescendo | → estável | ↘ diminuindo
   - **Top patterns:** 3 correções mais frequentes
   - **Rules efetivas:** regras que reduziram correções após promoção

Apresentar:

```
📈 TREND REPORT

Sessões analisadas: N
Correções totais: M
Média/sessão: X.X (tendência: ↘ diminuindo ✅)

Top Patterns:
1. {pattern} — {N}x (↘ -30% últimas 5 sessões)
2. {pattern} — {N}x (→ estável)
3. {pattern} — {N}x (↗ +20% — atenção!)

Rules Efetivas:
- "{rule}" reduziu "{pattern}" em {N}% desde promoção ✅
```

---

## Princípio

> *"Uma regra sem verificação é um desejo. Uma regra com verificação é um guardrail. Só guardrails sobrevivem."*

Registrar TUDO em evolution-log.md. Nunca promover sem verify regex. Nunca graduar sem aprovação humana.
