#!/usr/bin/env bash
# generate-report.sh — Gera relatório HTML a partir de Step Markers
#
# Uso:
#   ./generate-report.sh <results-file> [--title "Título"] [--url "URL"] [--branch "branch"]
#
# Input: arquivo com linhas no formato:
#   STEP_PASS|T01|evidência
#   STEP_FAIL|T02|esperado → atual|./screenshots/T02.png
#   STEP_SKIP|T03|motivo
#
# Output: .context/ui-test-reports/report-YYYYMMDD-HHMM.html

set -euo pipefail

RESULTS_FILE="${1:?Uso: $0 <results-file> [--title T] [--url U] [--branch B]}"
TITLE="Relatório de Verificação"
URL="—"
BRANCH="—"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../references" && pwd)"
REPORT_DIR=".context/ui-test-reports"

# Parse args
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2;;
    --url) URL="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    *) shift;;
  esac
done

mkdir -p "$REPORT_DIR"

# Contadores
PASS_COUNT=0; FAIL_COUNT=0; SKIP_COUNT=0
FAILURES_HTML=""; PASSES_HTML=""; SKIPS_HTML=""

while IFS='|' read -r TYPE ID INFO EXTRA; do
  case "$TYPE" in
    STEP_PASS)
      PASS_COUNT=$((PASS_COUNT + 1))
      PASSES_HTML+="<details><summary><span class=\"indicator pass\"></span> ${ID} — PASS</summary><div class=\"card-body\"><p class=\"evidence\">${INFO}</p></div></details>"
      ;;
    STEP_FAIL)
      FAIL_COUNT=$((FAIL_COUNT + 1))
      IMG_HTML=""
      if [[ -n "${EXTRA:-}" && -f "${EXTRA}" ]]; then
        B64=$(base64 -w0 "$EXTRA" 2>/dev/null || base64 -i "$EXTRA" 2>/dev/null || echo "")
        if [[ -n "$B64" ]]; then
          IMG_HTML="<img src=\"data:image/png;base64,${B64}\" alt=\"Screenshot ${ID}\">"
        fi
      fi
      FAILURES_HTML+="<details open><summary><span class=\"indicator fail\"></span> ${ID} — FAIL</summary><div class=\"card-body\"><p><span class=\"actual\">${INFO}</span></p>${IMG_HTML}</div></details>"
      ;;
    STEP_SKIP)
      SKIP_COUNT=$((SKIP_COUNT + 1))
      SKIPS_HTML+="<details><summary><span class=\"indicator skip\"></span> ${ID} — SKIP</summary><div class=\"card-body\"><p class=\"evidence\">${INFO:-Budget esgotado}</p></div></details>"
      ;;
  esac
done < "$RESULTS_FILE"

TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
if [[ $TOTAL -gt 0 ]]; then
  PASS_RATE=$(( (PASS_COUNT * 100) / TOTAL ))
else
  PASS_RATE=0
fi

if [[ $PASS_RATE -ge 90 ]]; then
  RATE_CLASS="good"
elif [[ $PASS_RATE -ge 70 ]]; then
  RATE_CLASS="warn"
else
  RATE_CLASS="bad"
fi

DATE=$(TZ="America/Sao_Paulo" date "+%d/%m/%Y %H:%M BRT" 2>/dev/null || date "+%d/%m/%Y %H:%M")

# Sections
FAIL_SECTION=""
if [[ $FAIL_COUNT -gt 0 ]]; then
  FAIL_SECTION="<h2>❌ Failures (${FAIL_COUNT})</h2>${FAILURES_HTML}"
fi

PASS_SECTION=""
if [[ $PASS_COUNT -gt 0 ]]; then
  PASS_SECTION="<h2>✅ Passes (${PASS_COUNT})</h2>${PASSES_HTML}"
fi

SKIP_SECTION=""
if [[ $SKIP_COUNT -gt 0 ]]; then
  SKIP_SECTION="<h2>⏭️ Skipped (${SKIP_COUNT})</h2>${SKIPS_HTML}"
fi

# Gerar HTML a partir do template
REPORT_FILE="${REPORT_DIR}/report-$(date +%Y%m%d-%H%M).html"

sed \
  -e "s|{{TITLE}}|${TITLE}|g" \
  -e "s|{{DATE}}|${DATE}|g" \
  -e "s|{{URL}}|${URL}|g" \
  -e "s|{{BRANCH}}|${BRANCH}|g" \
  -e "s|{{TOTAL}}|${TOTAL}|g" \
  -e "s|{{PASS_COUNT}}|${PASS_COUNT}|g" \
  -e "s|{{FAIL_COUNT}}|${FAIL_COUNT}|g" \
  -e "s|{{SKIP_COUNT}}|${SKIP_COUNT}|g" \
  -e "s|{{PASS_RATE}}|${PASS_RATE}|g" \
  -e "s|{{RATE_CLASS}}|${RATE_CLASS}|g" \
  "${TEMPLATE_DIR}/report-template.html" \
  | sed \
    -e "s|{{FAILURES_SECTION}}|${FAIL_SECTION}|" \
    -e "s|{{PASSES_SECTION}}|${PASS_SECTION}|" \
    -e "s|{{SKIPS_SECTION}}|${SKIP_SECTION}|" \
  > "$REPORT_FILE"

echo "✅ Relatório gerado: ${REPORT_FILE}"
echo "   Total: ${TOTAL} | Pass: ${PASS_COUNT} | Fail: ${FAIL_COUNT} | Skip: ${SKIP_COUNT} | Rate: ${PASS_RATE}%"
