# Batch — Processamento CSV/XLSX com Subagentes Paralelos

Processando: **$ARGUMENTS**

## Protocolo

### 1. Ler e Analisar Arquivo
```bash
# Via DuckDB (suporta CSV, XLSX, Parquet, JSON)
duckdb -c "SELECT * FROM read_csv_auto('arquivo.csv') LIMIT 5"
duckdb -c "SELECT COUNT(*) as total FROM read_csv_auto('arquivo.csv')"
```

### 2. Diamond Gate (Aprovação)
Mostrar ao usuário:
- Preview das primeiras 5 linhas
- Total de linhas a processar
- Prompt que será aplicado a cada linha
- Estimativa de tempo

**Perguntar:** "Processar {N} linhas com este prompt? [sim/não]"

### 3. Processar em Batches
- Dividir em batches de 10 linhas (configurável)
- Para cada batch, spawnar subagente `worker`
- Coletar resultados incrementalmente
- Salvar progresso em `.claude/data/batch/progress-{id}.json`

### 4. Consolidar e Entregar
- Agregar resultados de todos os batches
- Salvar output como CSV/JSON
- Notificar conclusão via notify.sh

## Exemplos

```
/batch leads.csv --prompt "Validar email e telefone de cada lead"
/batch comissoes.xlsx --prompt "Calcular comissão baseado nas regras Febracis"
/batch products.csv --prompt "Gerar descrição SEO para cada produto"
```

## Integração com DuckDB
Usa `/duckdb-skills:read-file` para leitura. Suporta:
- CSV, TSV (auto-detect delimiter)
- XLSX (primeira sheet)
- Parquet, JSON, Avro

## Resume em Caso de Falha
Se o processamento falhar no meio:
- Progress file salva qual batch parou
- `/batch --resume {id}` continua de onde parou
