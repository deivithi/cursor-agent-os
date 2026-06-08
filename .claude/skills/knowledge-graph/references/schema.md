# Schema Completo — Knowledge Graph

## Entity Types

### person
- **Observations típicas:** cargo, empresa, expertise, preferências de trabalho
- **Relações outgoing:** owns, works_at, manages
- **Relações incoming:** —
- **Convenção nome:** PascalCase (Deivithi)

### project
- **Observations típicas:** status (active/paused/done), stack, URL de deploy, data início
- **Relações outgoing:** uses, depends_on, deployed_on
- **Relações incoming:** owns, automates, blocks
- **Convenção nome:** PascalCase (Aria, FIO-IA)

### skill
- **Observations típicas:** version, domain, status (active/draft/deprecated)
- **Relações outgoing:** implements, complements, part_of
- **Relações incoming:** part_of, complements
- **Convenção nome:** kebab-case (web-research, code-review)

### tool
- **Observations típicas:** version, tipo (MCP/CLI/SaaS), status de conexão
- **Relações outgoing:** integrates_with
- **Relações incoming:** uses, integrates_with
- **Convenção nome:** lowercase (n8n, supabase, vercel)

### organization
- **Observations típicas:** tipo (empresa/equipe), domínio, relação (empregador/cliente)
- **Relações outgoing:** —
- **Relações incoming:** works_at
- **Convenção nome:** PascalCase (Febracis, Anthropic)

### concept
- **Observations típicas:** definição curta, fonte/referência, aplicação
- **Relações outgoing:** —
- **Relações incoming:** implements
- **Convenção nome:** PascalCase (IntegridadeConceitual, OuroborosLoop)

### workflow
- **Observations típicas:** n8n workflow ID, status (active/inactive), trigger type
- **Relações outgoing:** automates, uses
- **Relações incoming:** —
- **Convenção nome:** PascalCase (PRReviewBot, ErrorAlerting)

### platform
- **Observations típicas:** tipo (CRM/cloud/hosting), tier (free/pro/enterprise)
- **Relações outgoing:** —
- **Relações incoming:** deployed_on, integrates_with
- **Convenção nome:** PascalCase (Salesforce, GoogleWorkspace)

---

## Relation Types (Completo)

| Relation | Semântica | Direcionalidade |
|----------|-----------|-----------------|
| `owns` | Proprietário/responsável | person → project |
| `uses` | Utiliza como ferramenta | project/workflow → tool |
| `depends_on` | Precisa para funcionar | project → project/tool |
| `integrates_with` | Conecta-se com | tool → tool/platform |
| `implements` | Realiza/materializa | skill → concept |
| `part_of` | Sub-componente de | skill → skill |
| `works_at` | Empregado/alocado em | person → organization |
| `deployed_on` | Hospedado/rodando em | project → platform |
| `automates` | Automatiza processo de | workflow → project/skill |
| `blocks` | Impede progresso de | project → project |
| `complements` | Trabalha bem junto com | skill → skill |
| `manages` | Gerencia/administra | person → platform |

### topic (HyperMem)
- **Observations típicas:** resumo agregado, quantidade de episódios, última atualização
- **Relações outgoing:** —
- **Relações incoming:** belongs_to_topic
- **Convenção nome:** kebab-case (auditoria-leads, deploy-vercel)

### episode (HyperMem)
- **Observations típicas:** data da sessão, período, fatos extraídos count
- **Relações outgoing:** belongs_to_topic
- **Relações incoming:** contains
- **Convenção nome:** YYYY-MM-DD-epN (2026-04-11-ep1)

### group (HyperMem — Hyperedge)
- **Observations típicas:** tipo de agrupamento, peso médio, membros count
- **Relações outgoing:** contains (N-ário)
- **Relações incoming:** —
- **Convenção nome:** group-[tema] (group-auditoria-leads)
- **Nota:** Simula hyperedges N-árias. Uma entidade `group` + múltiplas relações `contains` = agrupamento N-ário. Observation `"weight: 0.85"` para importância.

---

## Relation Types (Completo)

| Relation | Semântica | Direcionalidade |
|----------|-----------|-----------------|
| `owns` | Proprietário/responsável | person → project |
| `uses` | Utiliza como ferramenta | project/workflow → tool |
| `depends_on` | Precisa para funcionar | project → project/tool |
| `integrates_with` | Conecta-se com | tool → tool/platform |
| `implements` | Realiza/materializa | skill → concept |
| `part_of` | Sub-componente de | skill → skill |
| `works_at` | Empregado/alocado em | person → organization |
| `deployed_on` | Hospedado/rodando em | project → platform |
| `automates` | Automatiza processo de | workflow → project/skill |
| `blocks` | Impede progresso de | project → project |
| `complements` | Trabalha bem junto com | skill → skill |
| `manages` | Gerencia/administra | person → platform |
| `belongs_to_topic` | Episódio pertence a tópico | episode → topic |
| `contains` | Grupo/hyperedge contém membro | group → episode/fact/any |

---

## Referências
- Memory MCP: https://github.com/modelcontextprotocol/servers/tree/main/src/memory
- LightRAG: https://github.com/HKUDS/LightRAG
- Mem0: https://github.com/mem0ai/mem0
- Graphiti (FalkorDB): https://github.com/getzep/graphiti
- HyperMem (ACL 2026): https://arxiv.org/abs/2604.08256
