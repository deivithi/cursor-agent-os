# 📚 Caverna — Glossário Febracis (Vocabulário Preservado)

> Termos que NUNCA devem ser abreviados, traduzidos ou comprimidos.
> Mesmo em modo Ultra, estes ficam literais.

## Febracis (Empresa)

| Termo | Contexto | ❌ NUNCA |
|-------|----------|---------|
| **Febracis** | Empresa do usuário | Nunca "Feb.", "FBR" |
| **Método CIS** | Metodologia principal | Nunca "MCis", "método" isolado |
| **Paulo Vieira** | Fundador | Literal |
| **DRE** | Demonstração de Resultado do Exercício | Pode usar DRE (já é sigla) |

## Eventos e Educação

| Termo | Definição |
|-------|-----------|
| **evento CIS** | Eventos presenciais Febracis |
| **Salão de Ouro** | Evento específico |
| **lead** | OK usar em inglês (consagrado em CRM) |
| **pipeline** | OK usar em inglês |
| **funil** | Equivalente a pipeline (sinônimo BR) |

## Salesforce (Stack Principal)

| Termo | Uso |
|-------|-----|
| **Salesforce** | Nunca "SF", "Sales." |
| **Sales Cloud** | Literal |
| **Service Cloud** | Literal |
| **Experience Cloud** | Literal |
| **Marketing Cloud** | Literal |
| **Process Builder** | Literal (legado) |
| **Flow** | OK (contexto claro em SF) |
| **Apex** | Literal |
| **Lightning** | Literal |
| **Trailhead** | Literal |
| **Org** | OK (Salesforce org) |
| **Sandbox** | OK |
| **Object** | OK quando contexto SF |
| **Record** | OK |

## Projetos Próprios

| Projeto | Contexto |
|---------|----------|
| **Pulso Finance** | App finanças pessoais — nunca "Pulso" só, nunca "Finance" só |
| **Aria** | SaaS PME — ok abreviar se contexto claro |
| **FIO-IA** | Gerador threads X — literal (é nome próprio) |
| **Espaçonave** | Projeto interno 5 fases — literal |
| **Landing de Eventos** | Lead capture — ok abreviar "landing" |
| **Obsidian Agent** | Agent 24/7 no vault — literal |
| **GBrain** | Knowledge base — literal |
| **Graphify** | Knowledge graph AST — literal |

## Stack Técnica (Preservar EN)

| Categoria | Termos |
|-----------|--------|
| **Frontend** | React, TypeScript, Vite, Tailwind, Next.js, Livewire, FluxUI, Filament |
| **Backend** | Supabase, Vercel, Cloudflare, Laravel, Django |
| **Database** | Postgres, Supabase, Prisma, Drizzle, PlanetScale |
| **Auth** | Supabase Auth, JWT, OAuth2, RLS (Row Level Security) |
| **Automation** | n8n, Make, Zapier |
| **Observability** | Sentry, Vercel Analytics |
| **AI/ML** | Claude API, Anthropic SDK, OpenAI, HuggingFace |
| **Plataformas** | GitHub, Cursor, Warp, VS Code |

## Termos de Processo (Preservar)

| Termo | Contexto |
|-------|----------|
| **CLAUDE.md** | Arquivo de regras globais do workspace |
| **skill** | .claude/skills/*/SKILL.md |
| **hook** | .claude/hooks/*.js ou settings.local.json |
| **command** | .claude/commands/*.md |
| **rule** | .claude/rules/*.md |
| **MEMORY.md** | Índice de memórias persistentes |
| **foresight** | Memória preditiva com data absoluta |
| **OMC** | oh-my-claudecode plugin |
| **MCP** | Model Context Protocol |
| **Plan Mode** | Modo de planejamento do Claude Code |

## Termos Regulatórios / Compliance

| Sigla | Significado |
|-------|-------------|
| **LGPD** | Lei Geral de Proteção de Dados |
| **SOC 2** | Service Organization Control |
| **ISO 27001** | Padrão de segurança da informação |
| **HIPAA** | Health Insurance Portability |
| **PCI-DSS** | Payment Card Industry Data Security |
| **Classificado** | Proteção China (Xinchuang) |

## Acrônimos Preservados (siglas válidas em PT-BR)

| Sigla | Expansão (não usar expandida em Ultra) |
|-------|--------------------------------------|
| **API** | Application Programming Interface |
| **SDK** | Software Development Kit |
| **CLI** | Command Line Interface |
| **IDE** | Integrated Development Environment |
| **CRM** | Customer Relationship Management |
| **ERP** | Enterprise Resource Planning |
| **SLA** | Service Level Agreement |
| **KPI** | Key Performance Indicator |
| **ROI** | Return on Investment |
| **MVP** | Minimum Viable Product |
| **POC** | Proof of Concept |
| **BI** | Business Intelligence |
| **OKR** | Objectives and Key Results |
| **SSO** | Single Sign-On |
| **CORS** | Cross-Origin Resource Sharing |
| **CDN** | Content Delivery Network |

## Vocabulário a COMPRIMIR (em Ultra)

Estes NÃO são preservados — podem abreviar:

| Original PT-BR | Ultra |
|---------------|-------|
| autenticação | aut |
| autorização | autz |
| configuração | config |
| requisição | req |
| resposta | res |
| função | fn |
| implementação | impl |
| banco de dados | BD |
| aplicação | app |
| repositório | repo |
| produção | prod |
| desenvolvimento | dev |
| ambiente | env |
| variável | var |
| parâmetro | param |
| argumento | arg |
| documentação | docs |

## Como o hook valida

`caverna-compress.js` (quando executado) roda regex:
```regex
# Falha se encontrar "fbr", "sf", "mcis", "paulo v\." etc.
/\b(fbr|sf|mcis|paulo\s+v\.|pulso\b)(?!\s+(finance))/i
```

Em caso de violação: restaura do backup, reporta `GLOSSARIO.md:<linha>` violado.
