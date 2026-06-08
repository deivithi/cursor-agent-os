# DuckDB Patterns para Batch Processing

## Ler Arquivos

```sql
-- CSV auto-detect
SELECT * FROM read_csv_auto('file.csv') LIMIT 5;

-- XLSX
SELECT * FROM st_read('file.xlsx') LIMIT 5;

-- Contar linhas
SELECT COUNT(*) as total FROM read_csv_auto('file.csv');

-- Schema
DESCRIBE SELECT * FROM read_csv_auto('file.csv');
```

## Dividir em Batches

```sql
-- Batch de 10 linhas (batch 0)
SELECT * FROM read_csv_auto('file.csv') LIMIT 10 OFFSET 0;

-- Batch de 10 linhas (batch 1)
SELECT * FROM read_csv_auto('file.csv') LIMIT 10 OFFSET 10;
```

## Filtrar e Validar

```sql
-- Linhas com email vazio
SELECT * FROM read_csv_auto('file.csv') WHERE email IS NULL OR email = '';

-- Duplicados por campo
SELECT email, COUNT(*) as n FROM read_csv_auto('file.csv') GROUP BY email HAVING n > 1;

-- Exportar resultado
COPY (SELECT * FROM ...) TO 'output.csv' (HEADER, DELIMITER ',');
```
