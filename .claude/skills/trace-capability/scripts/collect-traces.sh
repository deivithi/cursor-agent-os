#!/bin/bash
# collect-traces.sh — Coleta e particiona traces de uma skill para análise contrastiva
# Uso: bash collect-traces.sh <skill-name>
# Output: JSON para stdout com pass_traces, fail_traces, ledger_rows
# IMUTÁVEL — listado em ouroboros/firewall.md

set -euo pipefail

SKILL_NAME="${1:?Uso: collect-traces.sh <skill-name>}"
# Resolve workspace root (onde fica ouroboros/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../../../" && pwd)"
TRACES_DIR="${WORKSPACE_ROOT}/ouroboros/evals/traces/${SKILL_NAME}"
LEDGER_FILE="${WORKSPACE_ROOT}/ouroboros/ledger/skills-ledger.tsv"

# Verificar se diretório de traces existe
if [ ! -d "${TRACES_DIR}" ]; then
    echo "{\"error\": \"no_traces_dir\", \"skill\": \"${SKILL_NAME}\", \"path\": \"${TRACES_DIR}\", \"pass_traces\": [], \"fail_traces\": [], \"ledger_rows\": []}"
    exit 0
fi

# Contar traces
TOTAL=$(find "${TRACES_DIR}" -name "trace_*.json" 2>/dev/null | wc -l)
if [ "${TOTAL}" -eq 0 ]; then
    echo "{\"error\": \"no_traces\", \"skill\": \"${SKILL_NAME}\", \"total\": 0, \"pass_traces\": [], \"fail_traces\": [], \"ledger_rows\": []}"
    exit 0
fi

# Particionar traces em PASS e FAIL
PASS_TRACES="["
FAIL_TRACES="["
FIRST_PASS=true
FIRST_FAIL=true

for trace_file in "${TRACES_DIR}"/trace_*.json; do
    [ -f "${trace_file}" ] || continue

    # Extrair label e score (buscar human_label ou score)
    label=$(grep -o '"human_label"[[:space:]]*:[[:space:]]*"[^"]*"' "${trace_file}" 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"' || echo "")
    score=$(grep -o '"score"[[:space:]]*:[[:space:]]*[0-9.]*' "${trace_file}" 2>/dev/null | head -1 | grep -o '[0-9.]*$' || echo "0")

    # Classificar: PASS se label="PASS" ou score >= 0.8; FAIL caso contrário
    is_pass=false
    if [ "${label}" = "PASS" ]; then
        is_pass=true
    elif [ -z "${label}" ] && [ "$(echo "${score} >= 0.8" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
        is_pass=true
    fi

    filename=$(basename "${trace_file}")

    if [ "${is_pass}" = true ]; then
        if [ "${FIRST_PASS}" = true ]; then
            FIRST_PASS=false
        else
            PASS_TRACES="${PASS_TRACES},"
        fi
        PASS_TRACES="${PASS_TRACES}\"${filename}\""
    else
        if [ "${FIRST_FAIL}" = true ]; then
            FIRST_FAIL=false
        else
            FAIL_TRACES="${FAIL_TRACES},"
        fi
        FAIL_TRACES="${FAIL_TRACES}\"${filename}\""
    fi
done

PASS_TRACES="${PASS_TRACES}]"
FAIL_TRACES="${FAIL_TRACES}]"

# Extrair linhas do ledger para esta skill
LEDGER_ROWS="[]"
if [ -f "${LEDGER_FILE}" ]; then
    rows=$(grep -i "${SKILL_NAME}" "${LEDGER_FILE}" 2>/dev/null | tail -20 || echo "")
    if [ -n "${rows}" ]; then
        LEDGER_ROWS="["
        first=true
        while IFS= read -r row; do
            [ -z "${row}" ] && continue
            escaped=$(echo "${row}" | sed 's/"/\\"/g; s/\t/\\t/g')
            if [ "${first}" = true ]; then
                first=false
            else
                LEDGER_ROWS="${LEDGER_ROWS},"
            fi
            LEDGER_ROWS="${LEDGER_ROWS}\"${escaped}\""
        done <<< "${rows}"
        LEDGER_ROWS="${LEDGER_ROWS}]"
    fi
fi

# Contar partições
pass_count=$(echo "${PASS_TRACES}" | grep -o '"' | wc -l)
pass_count=$((pass_count / 2))
fail_count=$(echo "${FAIL_TRACES}" | grep -o '"' | wc -l)
fail_count=$((fail_count / 2))

# Output JSON
cat <<EOF
{
  "skill": "${SKILL_NAME}",
  "traces_dir": "${TRACES_DIR}",
  "total_traces": ${TOTAL},
  "pass_count": ${pass_count},
  "fail_count": ${fail_count},
  "sufficient_for_contrastive": $([ ${pass_count} -ge 3 ] && [ ${fail_count} -ge 2 ] && echo "true" || echo "false"),
  "pass_traces": ${PASS_TRACES},
  "fail_traces": ${FAIL_TRACES},
  "ledger_rows": ${LEDGER_ROWS}
}
EOF
