# Mythos Security Research Report — Template

> Copiar e preencher. Compativel com formato de `security-audit`.

---

```markdown
# Mythos Security Research Report

**Projeto:** {nome do projeto}
**Data:** {DD/MM/YYYY HH:MM} BRT
**Pesquisador:** Claude Code (metodologia Mythos) + {nome do humano}
**Escopo:** {arquivos/modulos/features analisados}
**Metodologia:** Mythos Deep Comprehension + Variant Analysis + Exploit Chain Analysis
**Nivel:** L1 Recon / L2 Hunt / L3 Siege
**Time Budget:** {tempo planejado} | **Tempo Real:** {tempo gasto}

---

## Resumo Executivo

- **Arquivos analisados:** X (de Y total no escopo)
- **File Prioritization:** Priority 5: X | Priority 4: X | Priority 3: X
- **Findings totais:** X
  - 🔴 Critical: X | 🟠 High: X | 🟡 Medium: X | 🔵 Low: X | ⚪ Info: X
- **Exploit chains identificadas:** X
- **Variantes encontradas:** X (de Y findings originais)
- **False positives descartados:** X
- **Postura geral:** {Seguro / Necessita Atencao / Critico}

### Principais Riscos
1. {Risco mais critico em 1 frase}
2. {Segundo risco}
3. {Terceiro risco}

---

## File Prioritization Map

| Score | Arquivo | Justificativa |
|-------|---------|---------------|
| [5] | `src/path/file.ts:linha` | {razao do score} |
| [4] | `src/path/file.ts` | {razao} |
| [3] | `src/path/file.ts` | {razao} |

**Hunt order aplicado:** [5] → [4] → [3 parcial]

---

## Findings

### [MYTH-001] {Titulo descritivo do finding}

- **Severity:** 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🔵 LOW / ⚪ INFO
- **CVSS:** {X.X}
- **Classe Mythos:** {Sentinel Collision / Integer Issue / Race Condition / Memory Safety / Logic Flaw / Crypto Issue}
- **OWASP:** {A01-A10 se aplicavel, ou "N/A — classe nao coberta pelo OWASP"}
- **CWE:** {CWE-XXX — descricao}
- **Localizacao:** `src/path/file.ts:42-58`
- **Descricao:** {O que esta errado, explicado from first principles}
- **Root Cause:** {A suposicao implicita que e violada}
- **Impacto:** {O que um atacante REALISTICAMENTE poderia alcancar}
- **Exploit Chain:** {Referencia a CHAIN-XXX se parte de uma chain, ou "Standalone"}
- **Variantes:** {Referencia a MYTH-XXX relacionados, ou "Nenhuma encontrada"}
- **Reproducao:** {Conceito de PoC — DEFENSIVO. Descrever O QUE, nao COMO weaponizar}
- **Remediacao:**
  ```typescript
  // Codigo corrigido com explicacao
  ```
- **Verificacao:** {Como verificar que o fix esta correto — test case ou check manual}
- **Referencia:** {CWE link, documentacao, research paper}

---

## Exploit Chains

### [CHAIN-001] {Titulo da chain}

**Confianca:** HIGH / MEDIUM / LOW
**Impacto se completa:** {descricao do worst case}

```
STEP 1 (ENTRY):       [MYTH-001] {descricao curta}
STEP 2 (PRIMITIVE):   [MYTH-003] {descricao curta}
STEP 3 (ESCALATION):  [MYTH-007] {descricao curta}
RESULTADO:             {impacto final}
```

**Remediacao prioritaria:** Quebrar a chain no elo mais facil de corrigir: Step {N}.

---

## Variant Analysis

### Variantes de [MYTH-001]

| # | Arquivo | Status | Notas |
|---|---------|--------|-------|
| V1 | `src/path/other.ts:15` | TRUE POSITIVE | Mesmo pattern, contexto diferente |
| V2 | `src/path/another.ts:88` | FALSE POSITIVE | Sanitizado upstream por middleware |
| V3 | `src/path/third.ts:42` | UNDETERMINED | Requer review humano |

---

## Recomendacoes de Defesa (Priorizadas)

### Imediato (antes do proximo deploy)
1. {Fix de finding Critical MYTH-XXX}
2. {Fix de finding Critical MYTH-XXX}

### Curto Prazo (proximo sprint)
3. {Fix de findings High}
4. {Adicionar mitigacao X}

### Medio Prazo (proximo mes)
5. {Melhoria arquitetural X}
6. {Adicionar tooling Y}

### Longo Prazo (roadmap)
7. {Prevencao sistematica X}
8. {Migrar para Y}

---

## Escopo NAO Analisado

- {Listar o que ficou fora do escopo e por que}
- {Dependencias externas — usar npm audit / pip audit separadamente}
- {Infra/cloud — fora do escopo de code review}

## Notas de Metodologia

- {Desvios da metodologia padrao Mythos}
- {Limitacoes encontradas}
- {Confianca geral na analise: Alta / Media / Baixa}
- {Recomendacoes para proxima analise}
```
