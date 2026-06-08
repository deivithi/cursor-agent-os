#!/usr/bin/env bash
# validate-schema-name.sh
# Valida nome de schema Postgres p/ uso na factory Supabase.
#
# Uso:  bash validate-schema-name.sh <nome>
# Exit: 0 = válido, 1 = inválido

set -euo pipefail

NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "ERRO: nome não fornecido" >&2
  echo "Uso: bash $0 <nome_schema>" >&2
  exit 1
fi

# 1. Formato: snake_case, 3-30 chars, começa c/ letra
if ! [[ "$NAME" =~ ^[a-z][a-z0-9_]{2,29}$ ]]; then
  echo "ERRO: '$NAME' inválido." >&2
  echo "Regra: snake_case, 3-30 chars, começa c/ letra minúscula, só [a-z0-9_]." >&2
  exit 1
fi

# 2. Reservados Supabase / Postgres
RESERVED=(
  "public"
  "auth"
  "storage"
  "realtime"
  "graphql"
  "graphql_public"
  "extensions"
  "vault"
  "pgsodium"
  "pgsodium_masks"
  "supabase_migrations"
  "supabase_functions"
  "net"
  "pgbouncer"
  "pg_catalog"
  "information_schema"
  "pg_temp"
  "pg_toast"
)

for reserved in "${RESERVED[@]}"; do
  if [[ "$NAME" == "$reserved" ]] || [[ "$NAME" == "$reserved"_* ]]; then
    echo "ERRO: '$NAME' colide c/ schema reservado ('$reserved')." >&2
    echo "Escolha outro nome — ver schemas-catalog.md > Schemas reservados." >&2
    exit 1
  fi
done

# 3. Prefixos suspeitos
if [[ "$NAME" == pg_* ]]; then
  echo "ERRO: prefixo 'pg_' é reservado pelo Postgres." >&2
  exit 1
fi

if [[ "$NAME" == _temp_* ]] || [[ "$NAME" == _lab_* ]]; then
  echo "AVISO: prefixo '_temp_'/'_lab_' indica schema descartável." >&2
  echo "Esses schemas NÃO devem ir p/ produção. Confirme antes de usar." >&2
  # Não bloqueia — só avisa
fi

# 4. Check catálogo local (se existir)
CATALOG=".claude/skills/supabase-factory/references/schemas-catalog.md"
if [[ -f "$CATALOG" ]]; then
  if grep -q "^### \`$NAME\`" "$CATALOG"; then
    echo "ERRO: schema '$NAME' já registrado no catálogo." >&2
    echo "Veja $CATALOG — considere reusar schema existente." >&2
    exit 1
  fi
fi

echo "OK: '$NAME' válido p/ uso."
exit 0
