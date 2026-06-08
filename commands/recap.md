# Recap — Captura de Observações da Sessão

Analise esta sessão e capture as observações importantes para memória persistente.

## O que Capturar

Revise todo o trabalho realizado nesta sessão e extraia:

### 1. Decisões Tomadas
- Escolhas arquiteturais
- Trade-offs aceitos
- Padrões adotados ou rejeitados

### 2. Descobertas
- Bugs encontrados e suas causas
- Padrões no código identificados
- Limitações descobertas
- Informações técnicas relevantes

### 3. Estado Atual
- O que foi completado
- O que ficou pendente
- Bloqueios identificados

### 4. Lições Aprendidas
- O que funcionou bem
- O que não funcionou e por quê
- Correções aplicadas

### 5. Próximos Passos
- Ações pendentes
- Prioridades sugeridas

## Como Salvar

Para cada observação relevante que deve persistir entre sessões:

1. **Verifique se já existe** uma memória relacionada em `C:\Users\PC\.claude\projects\C--Users-PC-OneDrive-Documents-VS-CODE\memory\`
2. Se existir → **atualize** o arquivo existente
3. Se não existir → **crie** novo arquivo com frontmatter:

```markdown
---
name: nome-descritivo
description: descrição curta para busca futura
type: project|feedback|user|reference
---

[conteúdo]
```

4. **Atualize o MEMORY.md** index se criou arquivo novo

## Regras

- Não salve informação que pode ser derivada do código ou git
- Não salve dados sensíveis (tokens, senhas, credenciais)
- Priorize: decisões > descobertas > estado
- Seja conciso — memória é para consulta rápida, não documentação
- Use datas absolutas (nunca "ontem", "semana que vem")
- Se nada relevante para memória → declare: "Nada a ser memorizado nesta sessão."

## Atualizar tasks/lessons.md

Se houve correções ou aprendizados técnicos, adicione em `tasks/lessons.md`:

```markdown
### [YYYY-MM-DD] — Título da lição
**Contexto:** situação
**Causa:** raiz do problema
**Regra:** como evitar no futuro
```

## Episode Detection (HyperMem)

Antes de salvar observações genéricas, **segmentar a sessão em episódios temáticos**:

### Como Segmentar

Revisar o histórico da sessão e identificar transições de tópico avaliando 3 sinais:
1. **Completude semântica** — o assunto anterior foi concluído antes de mudar?
2. **Gap temporal** — houve pausa significativa entre blocos de trabalho?
3. **Sinais linguísticos** — transição explícita ("agora vamos para", "outro tema", mudança de projeto/skill)

### Para Cada Episódio Identificado

1. **Criar página no GBrain** via `put_page()`:
```yaml
---
type: episode
title: "[Título descritivo do segmento]"
tags: [tag1, tag2]
session_date: YYYY-MM-DD
topic_slug: topics/[slug-do-topico]
---
[Resumo narrativo: o que aconteceu, decisões, descobertas, estado final]
---
## Facts
- [Fato atômico extraído 1]
- [Fato atômico extraído 2]
## Timeline
- YYYY-MM-DD HH:MM BRT: [evento principal]
```

2. **Topic Aggregation** — buscar `query(episode.title)` com type=topic:
   - Se 0 matches → criar novo topic via `put_page(topics/[slug])`
   - Se match existente → atualizar topic via `put_page()` + `add_timeline_entry()`

3. **Knowledge Graph** — criar entidades e relações:
   - `create_entities([{name: "YYYY-MM-DD-epN", entityType: "episode"}])`
   - `create_relations([{from: "YYYY-MM-DD-epN", to: "[topic]", relationType: "belongs_to_topic"}])`

### Quando NÃO Segmentar

- Sessões curtas (< 3 turnos) → tratar como episódio único
- Sessões monotópico → 1 episódio, sem fragmentar artificialmente
- Se nada relevante para memória → pular episode detection

---

## Output

Apresente um resumo formatado:

```markdown
## Recap da Sessão [data]

### Episódios Detectados
1. **[Ep1: Título]** — [resumo 1 linha] → topic: [slug]
2. **[Ep2: Título]** — [resumo 1 linha] → topic: [slug]

### Realizações
- [x] item 1
- [x] item 2

### Decisões
- decisão 1 (motivo)

### Memórias Salvas
- [arquivo] — descrição

### GBrain Updates
- episodes/YYYY-MM-DD-ep1 — [criado/atualizado]
- topics/[slug] — [criado/atualizado]

### Pendências
- [ ] item pendente

### Lições
- lição aprendida
```
