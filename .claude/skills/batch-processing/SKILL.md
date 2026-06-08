---
name: batch-processing
description: >
  Processamento batch de arquivos CSV/XLSX com subagentes paralelos tipados.
  Lê dados via DuckDB, divide em batches, processa com workers, consolida resultados.
domain: data-processing
subdomain: batch
version: 1.0.0
author: deivithi
tags: [batch, csv, xlsx, parallel, subagents, duckdb]
---

# Batch Processing — Processamento Paralelo de Dados

## 📁 File Structure
- `SKILL.md` — Você está aqui
- `references/duckdb-patterns.md` — Queries DuckDB comuns

## 🔗 Related Skills
- `minimax-xlsx` — Para formatação profissional do output
- `lead-audit` — Processamento batch de leads
- `commission-audit` — Processamento batch de comissões

## Conceito

Processar grandes volumes de dados (CSV, XLSX) dividindo em batches e usando subagentes paralelos para executar um prompt em cada registro.

## Workflow

1. **Ingest:** DuckDB lê o arquivo (qualquer formato tabular)
2. **Preview:** Mostra amostra + contagem total
3. **Gate:** Aprovação do usuário (Diamond Gate)
4. **Split:** Divide em batches de N linhas
5. **Process:** Subagentes `worker` processam cada batch
6. **Collect:** Resultados consolidados
7. **Output:** CSV/JSON/XLSX com resultados
8. **Notify:** Telegram/email quando termina
