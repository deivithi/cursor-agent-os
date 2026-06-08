# 🌲 Decision Tree — Onde subir o banco?

> **Regra mestra:** Em **95%+ dos casos** a resposta é **schema novo** (ou reusar existente) em `febracis-dre`. Projeto novo = exceção rara.

---

## Árvore completa

```
┌─────────────────────────────────────────────────────────────┐
│ Q0: É banco Supabase mesmo, ou outra coisa?                 │
│                                                             │
│ • Storage de arquivos? → Supabase Storage (bucket no       │
│   mesmo projeto)                                            │
│ • Cache/queue? → Supabase Queues (pgmq) ou Redis externo   │
│ • Vetores/embeddings? → pgvector no schema destino         │
│ • Realtime broadcast? → Supabase Realtime (sem tabelas)    │
│ • Banco relacional/CRUD → SEGUIR P/ Q1                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ Q1: Esse módulo já tem schema mapeado no catálogo?          │
│                                                             │
│ • SIM → ✅ Reusar schema existente                          │
│   └─ Passar p/ "Template new-table-with-rls.sql"           │
│                                                             │
│ • NÃO → Seguir p/ Q2                                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ Q2: É um novo DOMÍNIO de negócio dentro da Febracis?        │
│                                                             │
│ Exemplos de domínios: crm, financeiro, educacao, ia, dre,  │
│ gbrain, agents, vendas, marketing, operacoes, suporte      │
│                                                             │
│ • SIM → ✅ CREATE SCHEMA novo em febracis-dre              │
│   └─ Passar p/ "Template new-schema.sql"                   │
│                                                             │
│ • NÃO (é apenas mais tabelas de domínio existente)          │
│   → Reusar schema do domínio (voltar a Q1)                 │
│                                                             │
│ • TALVEZ (produto separado?) → Seguir p/ Q3                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ Q3: É produto TOTALMENTE separado? (teste dos 5 critérios) │
│                                                             │
│ Marcar critérios VERDADEIROS:                               │
│ [ ] Billing isolado obrigatório (cliente externo paga)      │
│ [ ] Compliance isolado (LGPD scope diferente)               │
│ [ ] Volume projetado > 10 GB ou > 100M rows                 │
│ [ ] Time externo c/ acesso restrito (fora da org deivithi) │
│ [ ] SaaS vendido independentemente (não ferramenta interna) │
│                                                             │
│ • ≥ 2 critérios marcados → 🚨 PROJETO NOVO                  │
│   └─ EXIGIR confirmação EXPLÍCITA do usuário                │
│   └─ EXIGIR justificativa escrita                           │
│   └─ Avisar custo: $25/mês/projeto mínimo                   │
│                                                             │
│ • < 2 critérios → ✅ Schema novo em febracis-dre            │
│   └─ Voltar a Q2                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Árvore paralela: Qual AMBIENTE usar?

```
┌─────────────────────────────────────────────────────────────┐
│ A0: A mudança vai tocar dados de produção?                  │
│                                                             │
│ • NÃO (só adicionar tabela nova) → Direto em prod via      │
│   migration aplicada em horário de baixo tráfego            │
│                                                             │
│ • SIM (alterar coluna, renomear tabela, reescrever dados)  │
│   → Seguir p/ A1                                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ A1: Tamanho do escopo?                                      │
│                                                             │
│ • PR pequeno (1-2 tabelas, 1-2 colunas)                     │
│   → Dev local (supabase CLI, docker)                        │
│                                                             │
│ • PR multi-tabela OU migration complexa OU dados seed       │
│   → Branch temporária (feature/<nome>)                      │
│                                                             │
│ • Release candidate (várias features juntas)                │
│   → Merge p/ staging, validar, depois prod                  │
│                                                             │
│ ⚠️ Branching requer Pro tier — febracis-dre ainda não tem.  │
│    Fallback: dev local + apply_migration em staging via     │
│    flag (staging_at_prod_separation_pending).               │
└─────────────────────────────────────────────────────────────┘
```

---

## Tabela rápida — decisão em 1 linha

| Cenário | Destino | Ambiente |
|---------|---------|----------|
| Nova tabela em domínio existente | Schema existente | Dev local → prod |
| Novo domínio de negócio Febracis | Novo schema em `febracis-dre` | Dev local → prod |
| Refactor pesado em tabela viva | Schema existente | Branch temp → staging → prod |
| Produto SaaS externo (cliente paga) | **Projeto novo** (confirmação!) | Projeto próprio c/ branching |
| Experimento/POC descartável | Novo schema c/ prefixo `_lab_` | Dev local, deletar no fim |
| Feature IA c/ embeddings | Schema `ia` c/ pgvector | Dev local → prod |

---

## Red flags — PARAR e perguntar

- Usuário pede "criar projeto novo" sem justificar → intercept c/ decision tree
- Usuário quer colocar tabela em schema `auth`/`storage`/`realtime` → BLOQUEAR (reservado)
- Tabela c/ `password`/`token`/`secret` → EXIGIR vault ou `vault.secrets`
- Schema c/ > 50 tabelas projetadas → discutir split em sub-domínios
- Schema sem owner identificado → NÃO criar até ter dono
