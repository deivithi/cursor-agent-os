#!/bin/bash
# Scaffold API Route — Gera rota API no padrão Aria
# Uso: bash scaffold-api-route.sh <nome-da-rota> [diretorio]

set -euo pipefail

ROUTE_NAME="${1:?Uso: scaffold-api-route.sh <nome-da-rota> [diretorio]}"
TARGET_DIR="${2:-./src/routes}"
TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S')

# Normalizar nome (kebab-case)
ROUTE_FILE="$TARGET_DIR/$ROUTE_NAME.ts"
# PascalCase para tipos
PASCAL_NAME=$(echo "$ROUTE_NAME" | sed -E 's/(^|-)(\w)/\U\2/g')

mkdir -p "$TARGET_DIR"

if [ -f "$ROUTE_FILE" ]; then
    echo "❌ Arquivo já existe: $ROUTE_FILE"
    echo "   Use outro nome ou remova o existente"
    exit 1
fi

cat > "$ROUTE_FILE" << TEMPLATE
/**
 * Route: $ROUTE_NAME
 * Scaffolded: $TIMESTAMP
 * Pattern: Aria API Route Standard
 */

import { z } from 'zod';

// ─── Input Validation ────────────────────────────────────────
const ${PASCAL_NAME}Schema = z.object({
  // TODO: Definir campos do request
  // id: z.string().uuid(),
  // name: z.string().min(1).max(100),
});

type ${PASCAL_NAME}Input = z.infer<typeof ${PASCAL_NAME}Schema>;

// ─── Response Type ───────────────────────────────────────────
interface ${PASCAL_NAME}Response {
  success: boolean;
  data?: unknown;
  error?: string;
}

// ─── Handler ─────────────────────────────────────────────────
export async function handle${PASCAL_NAME}(req: Request): Promise<Response> {
  try {
    // Validar input
    const body = await req.json();
    const input = ${PASCAL_NAME}Schema.parse(body);

    // TODO: Implementar lógica

    const response: ${PASCAL_NAME}Response = {
      success: true,
      data: input,
    };

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    if (error instanceof z.ZodError) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Validation failed',
        details: error.errors,
      }), { status: 400, headers: { 'Content-Type': 'application/json' } });
    }

    console.error('[${ROUTE_NAME}]', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error',
    }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
}
TEMPLATE

echo "✅ Rota scaffolded: $ROUTE_FILE"
echo "   Handler: handle${PASCAL_NAME}"
echo "   Schema: ${PASCAL_NAME}Schema"
echo ""
echo "📋 Próximos passos:"
echo "   1. Definir campos no schema Zod"
echo "   2. Implementar lógica no handler"
echo "   3. Registrar rota no router principal"
echo "   4. Adicionar testes"
