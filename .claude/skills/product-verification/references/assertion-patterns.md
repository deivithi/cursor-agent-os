# ✅ Assertion Patterns

> Como escrever assertions robustas para verificação de produtos.

## Princípio

> **Não confie em verificação visual. Asserte estado programaticamente em cada step.**

## Pattern 1: HTTP Status Assert

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
[ "$HTTP_CODE" = "200" ] || { echo "❌ HTTP $HTTP_CODE"; exit 1; }
echo "✅ HTTP 200"
```

## Pattern 2: Element Exists Assert

```bash
SNAP=$(agent-browser snapshot 2>/dev/null)
echo "$SNAP" | grep -q "texto esperado" || { echo "❌ Elemento não encontrado"; exit 1; }
echo "✅ Elemento presente"
```

## Pattern 3: JSON API Assert

```bash
RESPONSE=$(curl -s "$API_URL")
STATUS=$(echo "$RESPONSE" | jq -r '.status')
[ "$STATUS" = "healthy" ] || { echo "❌ API unhealthy: $STATUS"; exit 1; }
echo "✅ API healthy"
```

## Pattern 4: Form Submit Assert

```bash
# Após submeter form via agent-browser
agent-browser snapshot -i > /tmp/post-submit.txt
grep -q "sucesso\|obrigado\|thank" /tmp/post-submit.txt || {
    echo "❌ Mensagem de sucesso não encontrada"
    exit 1
}
echo "✅ Form submitido com sucesso"
```

## Pattern 5: Timing Assert

```bash
START=$(date +%s%N)
curl -s "$URL" > /dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))  # ms

[ "$DURATION" -lt 3000 ] || { echo "❌ Lento: ${DURATION}ms"; exit 1; }
echo "✅ Response em ${DURATION}ms"
```

## Checklist de Assertions por Tipo

### Smoke Test
- [ ] HTTP 200
- [ ] Tempo < 3s
- [ ] Título da página correto
- [ ] Sem erros JS visíveis

### E2E Flow
- [ ] Cada step navega corretamente
- [ ] Dados inseridos persistem entre steps
- [ ] Mensagem de sucesso aparece no final
- [ ] Dados chegaram ao backend (verificar via API)

### Visual Regression
- [ ] Screenshots before/after capturados
- [ ] Diferenças visuais são intencionais
- [ ] Layout não quebrou em viewport diferente

---

## Pattern 6: Step Markers Protocol

> Formato estruturado para reportar resultados de testes. Usado pelo `scripts/generate-report.sh`.

### Formato
```
STEP_PASS|<step-id>|<evidência>
STEP_FAIL|<step-id>|<esperado → atual>|<screenshot-path>
STEP_SKIP|<step-id>|<motivo>
```

### Exemplos
```bash
# PASS — evidência concreta obrigatória
echo "STEP_PASS|T01|document.title === 'Dashboard'" >> results.txt

# FAIL — incluir screenshot
browser-use screenshot ./screenshots/T02.png
echo "STEP_FAIL|T02|botão 'Salvar' visível → botão não encontrado|./screenshots/T02.png" >> results.txt

# SKIP — budget esgotado ou pré-condição faltando
echo "STEP_SKIP|T03|Budget de steps esgotado" >> results.txt
```

### Helper Bash
```bash
# Emitir PASS
step_pass() { echo "STEP_PASS|$1|$2" >> "${RESULTS_FILE:-results.txt}"; }

# Emitir FAIL com screenshot
step_fail() {
  local id="$1" info="$2" screenshot="./screenshots/${1}.png"
  browser-use screenshot "$screenshot" 2>/dev/null
  echo "STEP_FAIL|${id}|${info}|${screenshot}" >> "${RESULTS_FILE:-results.txt}"
}

# Emitir SKIP
step_skip() { echo "STEP_SKIP|$1|${2:-Budget esgotado}" >> "${RESULTS_FILE:-results.txt}"; }
```

### Gerar Relatório HTML
```bash
./scripts/generate-report.sh results.txt --title "Smoke Test Aria" --url "http://localhost:3000" --branch "main"
# Output: .context/ui-test-reports/report-YYYYMMDD-HHMM.html
```

---

## Hierarquia de Rigor de Verificação

| Nível | Método | Força | Quando usar |
|-------|--------|-------|-------------|
| 1 | `browser-use eval "..."` | 🟢 Mais forte | Qualquer propriedade acessível via JS (título, contadores, form values, erros) |
| 2 | Element match via `--json state` | 🟡 Forte | Verificar presença/texto de elementos na accessibility tree |
| 3 | Before/after comparison | 🟠 Médio | state antes → ação → state depois → comparar mudanças |
| 4 | Screenshot visual | 🔴 Mais fraco | Apenas para propriedades que a tree não captura (cor, spacing, layout exato) |

**Regra:** Nunca reportar STEP_PASS com nível 4 se nível 1-3 é possível. Screenshot é evidência complementar, não primária.
