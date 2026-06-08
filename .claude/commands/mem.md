# Mem — Busca e Gestão de Memória

Operação solicitada: **$ARGUMENTS**

## Operações Disponíveis

### Busca (padrão se nenhum comando especificado)
Se $ARGUMENTS contém uma pergunta ou tema, busque nas memórias:

1. Leia o índice: `C:\Users\PC\.claude\projects\C--Users-PC-OneDrive-Documents-VS-CODE\memory\MEMORY.md`
2. Identifique quais arquivos de memória podem ser relevantes pela descrição no índice
3. Leia os arquivos relevantes
4. Apresente os resultados organizados por relevância

### Comandos Específicos

| Comando | Ação |
|---------|------|
| `/mem` (sem args) | Mostra índice completo com resumo de cada memória |
| `/mem buscar [tema]` | Busca semântica no conteúdo das memórias |
| `/mem deep [tema]` | **Busca hierárquica** (HyperMem): Topic → Episode → Fact via GBrain |
| `/mem listar` | Lista todos os arquivos de memória com tipo e data |
| `/mem ler [arquivo]` | Lê conteúdo completo de uma memória específica |
| `/mem criar [tipo] [nome]` | Cria nova memória interativamente |
| `/mem atualizar [arquivo]` | Atualiza uma memória existente |
| `/mem remover [arquivo]` | Remove memória (com confirmação) |
| `/mem status` | Mostra estatísticas do sistema de memória |

### Busca Hierárquica (`/mem deep [tema]`) — HyperMem

Retrieval coarse-to-fine em 3 estágios via GBrain:

```
Stage 1: query(tema, type=topic)           → top-5 tópicos relevantes
Stage 2: traverse_graph(topic.slug)         → episódios linkados (via timeline/backlinks)
Stage 3: get_page(episode.slug)             → fatos atômicos extraídos
```

**Output:**
```markdown
## Busca Hierárquica: [tema]

### Tópicos Encontrados
1. **[topic.title]** (N episódios) — [compiled truth resumida]

### Episódios Relevantes
1. **[episode.title]** ([data]) — [resumo]
   - Fact: [fato 1]
   - Fact: [fato 2]

### Fatos Consolidados
- [lista de fatos únicos, deduplicados entre episódios]

### Fontes
- GBrain: topics/[slug], episodes/[slug]
- Flat: [arquivo de memória relacionado, se existir]
```

**Fallback:** Se GBrain não tem topics/episodes → cair para busca flat padrão com aviso: "Nenhum tópico/episódio encontrado. Mostrando busca flat."

---

### Formato de Saída para Busca

```markdown
## Resultados para: [tema buscado]

### Matches Diretos
1. **[nome]** (tipo: X) — [trecho relevante]
   📄 arquivo: [caminho]

### Matches Parciais
1. **[nome]** (tipo: X) — [por que pode ser relevante]

### Não Encontrado
Se nenhuma memória relevante: "Nenhuma memória encontrada para [tema]. Deseja que eu crie uma?"
```

### Formato para Status

```markdown
## Status do Sistema de Memória

| Tipo | Quantidade | Arquivos |
|------|-----------|----------|
| user | N | [lista] |
| feedback | N | [lista] |
| project | N | [lista] |
| reference | N | [lista] |

**Total:** N memórias
**Última atualização:** [data do arquivo mais recente]
**Índice (MEMORY.md):** [N linhas, saúde OK/DESATUALIZADO]
```

## Caminho da Memória

Todos os arquivos estão em:
`C:\Users\PC\.claude\projects\C--Users-PC-OneDrive-Documents-VS-CODE\memory\`

## Regras

- Nunca delete memórias sem confirmação explícita
- Ao criar memória, sempre atualize MEMORY.md
- Ao remover memória, sempre atualize MEMORY.md
- Mantenha frontmatter YAML consistente
- Tipos válidos: user, feedback, project, reference
