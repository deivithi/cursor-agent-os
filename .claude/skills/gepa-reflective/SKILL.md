---
name: gepa-reflective
description: GEPA (Generate-Execute-Plan-Adapt) Reflective Evolution pattern para auto-aprimoramento de agentes autônomos. O LLM lê traces de execução (logs, ledger, git diffs) para diagnosticar POR QUE uma hipótese falhou, e propõe correções direcionadas em vez de exploração aleatória. Substitui keep/discard simples por evolução baseada em evidências. Use ao otimizar skills via Ouroboros, debugar falhas recorrentes, ou implementar loops de agentes auto-aprimoráveis.
license: Custom (educational extraction + implementation)
metadata:
    skill-author: Deivithi (baseado em gepa-ai/gepa, ICLR 2026)
    source: https://github.com/gepa-ai/gepa
    version: 1.0.0
    created: 2026-03-22
---

# 🔬 GEPA Reflective Evolution — Evolução Reflexiva para Agentes Autônomos

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo ciclo GEPA abaixo.
- `references/gepa-pattern.md` — Documentação detalhada do padrão GEPA, origem e implementação.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `autonomous-agent-loop` — Loop base que o GEPA aprimora (substitui step 2.2 com diagnóstico)
- `agent-skill-patterns` — Estruturação das skills que o agente executa
- `code-review` — Protocolo de revisão que complementa a fase de análise reflexiva
- `trace-capability` — Análise contrastiva PASS vs FAIL (deep path). Usar TRACE quando há 3+ PASS e 2+ FAIL traces para comparação lado a lado; GEPA quando há apenas o trace da falha

---

## 🎯 O Problema que o GEPA Resolve

O loop autônomo clássico (Karpathy) usa **keep/discard binário**:

```
Experimento rodou → score melhorou? → KEEP
                  → score piorou?   → DISCARD
                  → crashou?        → LOG + skip
```

**Limitação crítica:** após um DISCARD, o agente **não sabe por quê** falhou. A próxima hipótese é essencialmente um **chute aleatório** — random walk no espaço de soluções.

**GEPA resolve isso** adicionando uma camada de **reflexão baseada em evidências** entre o resultado e a próxima hipótese.

---

## 🔄 O Ciclo GEPA

```
┌─────────────────────────────────────────────────────┐
│                    CICLO GEPA                       │
│                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │ GENERATE │───▶│ EXECUTE  │───▶│   PLAN   │      │
│  │ hipótese │    │ experim. │    │ analisar │      │
│  └──────────┘    └──────────┘    │  trace   │      │
│       ▲                          └────┬─────┘      │
│       │          ┌──────────┐         │            │
│       └──────────│  ADAPT   │◀────────┘            │
│                  │ fix dir. │                       │
│                  └──────────┘                       │
└─────────────────────────────────────────────────────┘
```

### G — Generate (Gerar Hipótese)

Na **primeira** iteração, funciona como o loop clássico: analisar estado e formular hipótese.
Nas iterações seguintes, a hipótese é **informada pelo diagnóstico** da fase Adapt anterior.

```
INPUT:  estado atual + diagnóstico anterior (se houver)
OUTPUT: hipótese específica com predição mensurável
```

**Regra:** A hipótese DEVE incluir:
- O que vai mudar
- Por que espera que melhore
- Qual métrica será afetada e em qual direção

### E — Execute (Executar Experimento)

Igual ao loop clássico: implementar, commitar, rodar, medir.

```
INPUT:  hipótese formulada
OUTPUT: resultado do experimento + trace completo de execução
```

**Regra:** Capturar **trace completo**:
- Logs de execução (stdout/stderr)
- Git diff da mudança
- Score antes e depois (por item do checklist, não só total)
- Tempo de execução
- Erros ou warnings intermediários

### P — Plan (Planejar via Análise Reflexiva)

**Esta é a fase que diferencia GEPA do loop clássico.**

O agente lê o trace completo e realiza **diagnóstico causal**:

```
INPUT:  trace completo da execução
OUTPUT: diagnóstico estruturado com causa raiz e classificação
```

#### Protocolo de Análise Reflexiva

1. **Ler o trace inteiro** — não só o score final
2. **Identificar o padrão de falha** — ver taxonomia abaixo
3. **Classificar o tipo de falha** — determina a estratégia de adaptação
4. **Formular diagnóstico** — frase única explicando a causa raiz

```markdown
## Diagnóstico da Iteração N

**Score:** 6/10 → 5/10 (delta: -1)
**Itens que pioraram:** [checklist item 3: "gotchas.md presente"]
**Trace relevante:** "Error: file not found .claude/skills/X/gotchas.md"
**Causa raiz:** Hipótese adicionou novo padrão mas não criou arquivo de gotchas
**Classificação:** Tipo 2 — melhoria em um eixo, piora em outro
**Ação indicada:** Criar gotchas.md com padrões reais antes de submeter
```

### A — Adapt (Adaptar com Correção Direcionada)

Em vez de descartar e chutar de novo, o agente aplica **correção cirúrgica**:

```
INPUT:  diagnóstico estruturado
OUTPUT: próxima hipótese BASEADA no diagnóstico (não aleatória)
```

**Regra:** A adaptação DEVE referenciar o diagnóstico:
- "O trace mostrou X, portanto a próxima hipótese endereça X diretamente"
- Nunca "vou tentar algo diferente" sem justificativa baseada em evidência

---

## 🏷️ Taxonomia de Falhas

### Tipo 1 — Mesmo Item Falha Repetidamente

**Sintoma:** O mesmo checklist item fica vermelho por 3+ iterações consecutivas.
**Diagnóstico:** A abordagem atual não resolve este item. Ajustes incrementais não funcionam.
**Ação:** Mudar a abordagem **radicalmente**. Não iterar mais no mesmo ângulo.

```
Exemplo: "references/ vazia" falha 4x seguidas
→ Parar de tentar preencher com conteúdo genérico
→ Mudar: criar referência a partir de trace real de uso da skill
```

### Tipo 2 — Score Melhora em Um Eixo, Piora em Outro

**Sintoma:** Item A passa de vermelho para verde, mas Item B vai de verde para vermelho.
**Diagnóstico:** A mudança tem efeito colateral. Existe acoplamento entre os itens.
**Ação:** Encontrar solução que resolve A **sem sacrificar** B. Não aceitar trade-off.

```
Exemplo: Adicionar seção de anti-patterns (item 7 ✓) mas ultrapassar 300 linhas (item 2 ✗)
→ Não: remover anti-patterns para caber
→ Sim: condensar outras seções para abrir espaço
```

### Tipo 3 — Crash Repetido (Limitação Estrutural)

**Sintoma:** Experimento crasha 2+ vezes no mesmo ponto.
**Diagnóstico:** Limitação técnica ou estrutural que não se resolve com mudança de conteúdo.
**Ação:** Registrar a limitação, pular este ângulo, explorar outro.

```
Exemplo: Eval script crasha ao parsear YAML com caracteres especiais
→ Registrar: "eval não suporta YAML com emoji no frontmatter"
→ Pular: remover emoji do frontmatter e seguir
```

---

## 🔗 Integração com Ouroboros

O GEPA **substitui o passo 2.2** do loop Ouroboros:

### Antes (Keep/Discard Simples)
```
2.1 Snapshot (git commit)
2.2 Formular hipótese ← CHUTE baseado em intuição
2.3 Implementar
2.4 Avaliar
2.5 Se melhorou → keep, senão → revert
```

### Depois (GEPA Reflective)
```
2.1 Snapshot (git commit)
2.2 [GEPA-G] Formular hipótese ← INFORMADA pelo diagnóstico anterior
2.3 [GEPA-E] Implementar + capturar trace completo
2.4 [GEPA-P] Analisar trace, diagnosticar causa raiz, classificar falha
2.5 [GEPA-A] Se melhorou → keep + registrar o que funcionou
                Se piorou → adaptar com correção direcionada (NÃO random discard)
                Se crashou → classificar e decidir: fix ou skip
```

**Resultado:** Convergência mais rápida porque cada iteração **aprende** com a anterior.

---

## 📝 Commit Messages Estruturados

Cada iteração GEPA produz um commit com formato padronizado:

```
gepa(skill-name): iteração N — [KEEP|ADAPT|SKIP]

Score: 7/10 → 8/10 (delta: +1)
Hipótese: [descrição curta da hipótese testada]
Diagnóstico: [causa raiz identificada na fase Plan]
Ação: [o que foi feito na fase Adapt]
Itens afetados: [checklist items que mudaram]
```

**Por que estruturar o commit:**
- O próprio commit vira parte do **trace** para iterações futuras
- `git log --oneline` mostra a trajetória de evolução
- Permite auditoria: "por que esta mudança foi feita?"

---

## ⚖️ Comparação: Keep/Discard vs GEPA

| Aspecto | Keep/Discard Simples | GEPA Reflective |
|---------|---------------------|-----------------|
| **Após falha** | Descarta e tenta algo novo (random) | Diagnostica causa raiz e corrige direcionado |
| **Convergência** | Lenta — random walk | Rápida — cada iteração aprende |
| **Informação usada** | Score final (escalar) | Trace completo (texto rico) |
| **Custo por iteração** | Baixo (só compara score) | Médio (análise reflexiva ~20% do tempo) |
| **Quando funciona melhor** | Espaço pequeno de soluções | Espaço grande com muitas dimensões |
| **Risco** | Ficar preso em platô | Over-fitting a um diagnóstico errado |
| **Origem teórica** | Karpathy autoresearch (2025) | gepa-ai/gepa ICLR 2026 Oral |

---

## 🚫 Anti-Patterns

### 1. Reflexão sem Trace (No Data)
**Erro:** Tentar diagnosticar "por que falhou" sem ter logs ou diff para analisar.
**Fix:** SEMPRE capturar trace completo na fase Execute. Sem trace = sem reflexão.

### 2. Over-Fitting a Uma Única Falha
**Erro:** Focar obsessivamente em um item do checklist enquanto ignora o resto.
**Fix:** Sempre olhar o score **completo** (todos os itens), não só o que falhou.

### 3. Loop Infinito de Reflexão
**Erro:** Refletir sobre a reflexão sobre a reflexão... meta-otimização sem fim.
**Fix:** Time-box a fase Plan: máximo **20% do tempo total** do experimento. Se em 2 minutos não tem diagnóstico, usar heurística simples e seguir.

### 4. Diagnóstico Alucinado
**Erro:** LLM inventa uma causa raiz que parece plausível mas não está no trace.
**Fix:** Cada afirmação do diagnóstico DEVE ter citação do trace. Sem evidência = `[Inferência]`.

### 5. Ignorar Tipo 3 (Insistir em Crash)
**Erro:** Continuar tentando resolver uma limitação estrutural com mudanças de conteúdo.
**Fix:** Após 2 crashes no mesmo ponto → classificar como Tipo 3, registrar e pular.

---

## ✅ Quality Checklist

Antes de considerar uma implementação GEPA como funcional:

```
□ O trace captura logs, diff, scores por item e tempo de execução?
□ A fase Plan produz diagnóstico com causa raiz e classificação?
□ A fase Adapt referencia o diagnóstico (não é chute aleatório)?
□ Commits seguem o formato estruturado com métricas e delta?
□ Time-box de reflexão está configurado (≤ 20% do tempo total)?
□ Taxonomia de falhas (Tipos 1-3) é aplicada consistentemente?
□ Há mecanismo para detectar e sair de loops infinitos?
□ Diagnósticos são verificáveis contra o trace (sem alucinações)?
```

---

## 📚 Referências

- **gepa-ai/gepa** — ICLR 2026 Oral. Reflective text evolution supera RL para otimização de texto.
- **Karpathy autoresearch** — Loop autônomo base que o GEPA aprimora.
- **Ouroboros** — Motor de auto-aprimoramento recursivo que integra GEPA.

> 📄 Detalhes completos da origem e implementação: `references/gepa-pattern.md`
