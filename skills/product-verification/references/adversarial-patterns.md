# ⚔️ Adversarial Test Patterns

> Catálogo de patterns para **quebrar** features, não apenas verificá-las.
> Todos os exemplos usam browser-use CLI. Adaptar índices após `state`.

---

## 1. Forms

### 1.1 Submissão Vazia
```bash
# Não preencher nada, clicar submit
browser-use state
browser-use click <submit-index>
browser-use eval "document.querySelectorAll('[aria-invalid=\"true\"], .error, .invalid').length"
# Esperado: > 0 (validação ativou)
```

### 1.2 Input Overflow (500+ chars)
```bash
LONG_INPUT=$(python3 -c "print('A' * 500)")
browser-use input <field-index> "$LONG_INPUT"
browser-use screenshot ./screenshots/overflow.png
# Verificar: layout não quebrou, input truncado ou aceito sem crash
browser-use eval "document.querySelector('input').value.length"
```

### 1.3 XSS Payload
```bash
browser-use input <field-index> '<script>alert(1)</script>'
browser-use click <submit-index>
browser-use eval "document.querySelector('script:last-of-type')?.textContent || 'SAFE'"
# Esperado: "SAFE" — payload não foi inserido como script
```

> ⚠️ **Gotcha #8:** Aspas no payload podem conflitar com shell. Usar aspas simples no outer e escapar inner.

### 1.4 Double-Submit Rápido
```bash
# Via eval para simular click simultâneo (CLI sequencial tem ~50ms gap)
browser-use eval "const btn = document.querySelector('button[type=submit]'); btn.click(); btn.click();"
# Verificar: apenas 1 registro criado, botão desabilitado após primeiro click
```

> ⚠️ **Gotcha #10:** Não testar race conditions via comandos CLI sequenciais — usar eval.

### 1.5 Caracteres Especiais
```bash
browser-use input <field-index> "João D'Ávila <test> & \"quotes\" ñ 你好"
browser-use click <submit-index>
browser-use state
# Verificar: texto preservado, sem HTML entities quebrados
```

### 1.6 Required Fields Faltando
```bash
# Preencher apenas 1 campo, submeter
browser-use input <first-field> "teste"
browser-use click <submit-index>
browser-use eval "document.querySelectorAll(':invalid').length"
# Esperado: > 0 (campos required não preenchidos bloqueiam)
```

---

## 2. Modals e Dialogs

### 2.1 Fechar com Escape
```bash
browser-use click <open-modal-trigger>
browser-use state  # confirmar modal aberto
browser-use keys "Escape"
browser-use eval "document.querySelector('[role=dialog]')?.offsetParent !== null || false"
# Esperado: false (modal fechou)
```

### 2.2 Focus Trap
```bash
browser-use click <open-modal-trigger>
# Tab deve circular dentro do modal
browser-use keys "Tab"
browser-use keys "Tab"
browser-use keys "Tab"
browser-use eval "document.activeElement?.closest('[role=dialog]') !== null"
# Esperado: true (foco ainda dentro do modal)
```

### 2.3 Click Outside
```bash
browser-use click <open-modal-trigger>
browser-use eval "document.querySelector('[data-overlay], .backdrop')?.click()"
browser-use eval "document.querySelector('[role=dialog]')?.offsetParent !== null || false"
# Esperado: false (modal fechou ao clicar fora)
```

---

## 3. Navigation

### 3.1 URL Inválida (404)
```bash
browser-use open "http://localhost:3000/rota-inexistente-xyz"
browser-use eval "document.title"
# Esperado: conter "404" ou "Not Found"
browser-use eval "document.querySelector('a[href=\"/\"]') !== null"
# Esperado: true (link para voltar ao home)
```

### 3.2 Back/Forward
```bash
browser-use open "http://localhost:3000/page-a"
browser-use open "http://localhost:3000/page-b"
browser-use back
browser-use eval "window.location.pathname"
# Esperado: "/page-a"
```

### 3.3 Links Quebrados
```bash
browser-use eval "Array.from(document.querySelectorAll('a[href]')).map(a => a.href)"
# Para cada link, verificar HTTP status via curl:
# curl -s -o /dev/null -w "%{http_code}" "<link>"
```

---

## 4. Responsive

### 4.1 Viewport Mobile (375px)
```bash
browser-use eval "window.innerWidth"
# Se não for possível resize via CLI, verificar CSS responsividade:
browser-use eval "getComputedStyle(document.body).overflow !== 'hidden' && document.body.scrollWidth <= window.innerWidth"
# Esperado: true (sem scroll horizontal)
```

> ⚠️ **Gotcha #9:** `window.resizeTo()` não funciona em headless. Para testar viewports, configurar na abertura do browser ou verificar media queries via eval.

### 4.2 Touch Targets
```bash
browser-use eval "Array.from(document.querySelectorAll('button, a, input')).filter(el => { const r = el.getBoundingClientRect(); return r.width < 44 || r.height < 44; }).length"
# Esperado: 0 (todos os alvos ≥ 44x44px)
```

### 4.3 Text Overflow
```bash
browser-use eval "Array.from(document.querySelectorAll('*')).filter(el => el.scrollWidth > el.clientWidth).length"
# Esperado: 0 (nenhum texto cortado)
```

---

## 5. Accessibility

### 5.1 Keyboard Navigation (Tab)
```bash
browser-use keys "Tab"
browser-use eval "document.activeElement?.tagName + '#' + document.activeElement?.id"
browser-use keys "Tab"
browser-use eval "document.activeElement?.tagName + '#' + document.activeElement?.id"
# Verificar: foco progride logicamente pelos elementos interativos
```

### 5.2 ARIA Labels
```bash
browser-use eval "document.querySelectorAll('button:not([aria-label]):not([aria-labelledby])').length + document.querySelectorAll('img:not([alt])').length"
# Esperado: 0 (todos os botões e imagens têm labels)
```

### 5.3 Axe-Core Audit (via eval)
```bash
browser-use eval "
(async () => {
  const script = document.createElement('script');
  script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.10.2/axe.min.js';
  document.head.appendChild(script);
  await new Promise(r => script.onload = r);
  const results = await axe.run();
  return { violations: results.violations.length, critical: results.violations.filter(v => v.impact === 'critical').length };
})()
"
# Esperado: violations = 0, critical = 0
```

---

## 6. Performance

### 6.1 Tempo de Carregamento
```bash
browser-use eval "JSON.stringify(performance.getEntriesByType('navigation')[0]?.domContentLoadedEventEnd)"
# Se > 3000ms: STEP_FAIL
```

### 6.2 Console Errors
```bash
browser-use eval "window.__consoleErrors?.length || 0"
# Esperado: 0
# Nota: requer listener instalado no início:
# browser-use eval "window.__consoleErrors=[]; const _e=console.error; console.error=(...a)=>{window.__consoleErrors.push(a.join(' ')); _e(...a)}"
```

### 6.3 Recursos Pesados
```bash
browser-use eval "performance.getEntriesByType('resource').filter(r => r.transferSize > 1_000_000).map(r => r.name)"
# Esperado: [] (nenhum recurso > 1MB)
```

---

## Checklist Rápido por Tipo de Componente

| Componente | Patterns obrigatórios |
|-----------|----------------------|
| Form | 1.1, 1.2, 1.3, 1.4, 1.6, 5.1 |
| Modal | 2.1, 2.2, 2.3, 5.1 |
| Página | 3.1, 4.1, 4.2, 6.1, 6.2 |
| Lista/Tabela | 1.2 (busca), 4.3 (overflow), 5.2 |
| Dashboard | 3.2 (nav), 4.1 (responsive), 6.1 (perf) |
