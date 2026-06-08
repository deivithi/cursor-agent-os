#!/bin/bash
# Init Plugin Data — Inicializa diretório de dados persistentes por skill
# Chamado pelo SessionStart para garantir que .claude/data/ existe com subpastas

DATA_DIR="$CLAUDE_PROJECT_DIR/.claude/data"

# Criar diretório principal
mkdir -p "$DATA_DIR" 2>/dev/null

# Skills que precisam de dados persistentes
SKILLS_WITH_DATA=(
    "lead-audit"
    "commission-audit"
    "skill-usage"
)

for SKILL in "${SKILLS_WITH_DATA[@]}"; do
    mkdir -p "$DATA_DIR/$SKILL" 2>/dev/null
done

# Arquivar sinais da sessão anterior antes de limpar
# Preserva para que session-start-context.sh possa ler os sinais recentes
SIGNALS_FILE="$DATA_DIR/session-signals.jsonl"
SIGNALS_PREV="$DATA_DIR/session-signals-prev.jsonl"
if [ -f "$SIGNALS_FILE" ] && [ -s "$SIGNALS_FILE" ]; then
    cp "$SIGNALS_FILE" "$SIGNALS_PREV"
fi
# Limpar sinais — novo ciclo de sessão
rm -f "$SIGNALS_FILE" 2>/dev/null

# Exportar variável para uso nas skills
export CLAUDE_PLUGIN_DATA="$DATA_DIR"

# Informar ao contexto
echo "$DATA_DIR"

exit 0
