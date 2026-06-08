# /brain — LLM Wiki (Second Brain)

Operação solicitada: **$ARGUMENTS**

---

## Setup Inicial (sempre)

Antes de qualquer operação:
1. Leia `C:\Users\PC\Documents\Obsidian Vault\brain-schema.md` **completo**
2. Leia `C:\Users\PC\Documents\Obsidian Vault\wiki\index.md` para mapear o estado atual da wiki

---

## Subcomandos

### `/brain ingest <arquivo|url>`

Ingere uma nova fonte na wiki. Este é o coração do sistema.

**Fluxo:**

1. **Ler a fonte**
   - Se URL: usar `mcp__markitdown__convert_to_markdown` ou `WebFetch` para obter o conteúdo
   - Se arquivo local em `raw/`: ler diretamente com `Read`
   - Se texto bruto: usar o texto fornecido como argumento

2. **Discutir com o usuário**
   - Apresentar 3-5 takeaways principais
   - Perguntar: "O que você quer que eu enfatize nesta fonte?"
   - Aguardar resposta antes de continuar

3. **Criar página de source**
   - Caminho: `wiki/sources/<autor-topico-curto>.md`
   - Usar frontmatter tipo `source` do brain-schema.md
   - Incluir: summary (3-5 parágrafos), citações-chave, seção "## Connections" com links para entidades/conceitos relacionados

4. **Atualizar/criar entidades** (`wiki/entities/`)
   - Para cada pessoa, empresa, produto ou projeto mencionado relevante
   - Se página já existe: adicionar nova seção com informações desta fonte
   - Se não existe: criar nova página com frontmatter tipo `entity`

5. **Atualizar/criar conceitos** (`wiki/concepts/`)
   - Para cada ideia, framework, método ou padrão importante
   - Cruzar com glossário do brain-schema.md para detectar relevância para projetos do usuário

6. **Atualizar `wiki/index.md`**
   - Adicionar nova linha na tabela Sources
   - Adicionar linhas nas tabelas de Entities/Concepts para páginas novas
   - Atualizar contadores de Stats

7. **Appendar em `wiki/log.md`**
   ```
   ## [YYYY-MM-DD HH:MM BRT] ingest | <Título da Fonte>

   **Autor:** <autor>
   **URL:** <url ou "arquivo local">
   **Páginas criadas:** <lista>
   **Páginas atualizadas:** <lista>
   ```

8. **Reportar ao usuário**
   - N páginas criadas, N páginas atualizadas
   - Conexões descobertas com projetos existentes (Aria, FIO-IA, etc.)

---

### `/brain query <pergunta>`

Consulta o conhecimento acumulado na wiki.

**Fluxo:**

1. **Ler `wiki/index.md`** — mapear páginas relevantes para a pergunta
2. **Ler páginas relevantes** — sources + entities + concepts relacionados
3. **Sintetizar resposta** com citações no formato `[[página]]`
4. **Perguntar:** "Quer que eu arquive esta análise na wiki como página de synthesis?"
5. **Se sim:**
   - Criar `wiki/synthesis/<slug>.md` com frontmatter tipo `synthesis`
   - Atualizar `wiki/index.md` (tabela Synthesis)
   - Appendar em `wiki/log.md`:
     ```
     ## [YYYY-MM-DD HH:MM BRT] query | <Pergunta resumida>
     **Arquivado como:** [[<slug>]]
     ```

> Respostas arquivadas como synthesis alimentam futuras queries — compound forever.

---

### `/brain lint`

Health check completo da wiki.

**Fluxo:**

1. Listar todos os arquivos `.md` em `wiki/` com `Glob`
2. Para cada página, verificar:
   - **Orphans:** nenhuma outra página linka para ela → `grep` por `[[nome-do-arquivo]]` no vault
   - **Links quebrados:** extrair todos os `[[links]]` e verificar se o arquivo existe
   - **Conceitos sem página:** buscar termos recorrentes que não têm página em `concepts/`
3. Ler `wiki/index.md` e verificar:
   - **Inconsistências:** páginas listadas no index que não existem em disco
   - **Páginas não indexadas:** arquivos em disco que não aparecem no index
4. **Sugerir** novas fontes a buscar para preencher lacunas de cobertura
5. **Gerar relatório** no formato definido no brain-schema.md
6. **Appendar em `wiki/log.md`:**
   ```
   ## [YYYY-MM-DD HH:MM BRT] lint | Health check

   **Resultado:** [OK | ATENÇÃO | CRÍTICO]
   **Orphans:** N | **Links quebrados:** N | **Inconsistências:** N
   ```

---

### `/brain status`

Visão geral rápida da wiki.

**Fluxo:**

1. Contar arquivos `.md` por pasta (sources, entities, concepts, synthesis)
2. Listar arquivos em `raw/` não ainda ingeridos na wiki (comparar com log.md)
3. Mostrar últimas 5 entradas do `wiki/log.md`
4. Reportar:

```markdown
## Wiki Status — YYYY-MM-DD HH:MM BRT

### 📊 Páginas
| Tipo | Quantidade |
|------|-----------|
| Sources | N |
| Entities | N |
| Concepts | N |
| Synthesis | N |
| **Total** | **N** |

### 📥 raw/ pendente de ingest
- arquivo1.md
- arquivo2.pdf
*(ou: "Nenhum arquivo pendente")*

### 📋 Últimas operações
[últimas 5 linhas de log.md com prefixo ##]
```

---

## Caminhos Importantes

| Item | Caminho |
|------|---------|
| Schema | `C:\Users\PC\Documents\Obsidian Vault\brain-schema.md` |
| Wiki index | `C:\Users\PC\Documents\Obsidian Vault\wiki\index.md` |
| Wiki log | `C:\Users\PC\Documents\Obsidian Vault\wiki\log.md` |
| Sources | `C:\Users\PC\Documents\Obsidian Vault\wiki\sources\` |
| Entities | `C:\Users\PC\Documents\Obsidian Vault\wiki\entities\` |
| Concepts | `C:\Users\PC\Documents\Obsidian Vault\wiki\concepts\` |
| Synthesis | `C:\Users\PC\Documents\Obsidian Vault\wiki\synthesis\` |
| Raw sources | `C:\Users\PC\Documents\Obsidian Vault\raw\` |
| Raw assets | `C:\Users\PC\Documents\Obsidian Vault\raw\assets\` |

---

## Regras

- **Sempre** ler `brain-schema.md` antes de qualquer operação
- **Nunca** modificar arquivos em `raw/`
- **Nunca** deletar páginas da wiki (usar `status: deprecated` no frontmatter)
- **Sempre** atualizar `index.md` e appendar `log.md` após qualquer mudança
- **Sempre** usar links internos `[[slug]]` ao referenciar outras páginas
- **Datas em BRT** — `YYYY-MM-DD HH:MM BRT`
