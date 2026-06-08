# security-audit — Gotchas & Problemas Conhecidos

## 1. Semgrep tem muitos false positives em código React
**Problema:** Rules como `react-dangerouslysetinnerhtml` disparam em usos legítimos (sanitized HTML).
**Solução:** SEMPRE aplicar fp-check (Fase 3.3). Documentar false positives para tuning futuro.

## 2. Context Building demora mas é obrigatório
**Problema:** Tentação de pular Fase 1 e ir direto para hunting. Resulta em findings superficiais.
**Solução:** Fase 1 é NOT OPTIONAL. Sem contexto, não se encontra bugs de lógica de negócio (os mais perigosos).

## 3. Semgrep no Windows pode ter problemas de PATH
**Problema:** `semgrep` instalado via pip pode não estar no PATH no Windows.
**Solução:** Usar `python -m semgrep` ou instalar em venv com PATH configurado.

## 4. npm audit reporta muitas vulnerabilidades em devDependencies
**Problema:** `npm audit` inclui devDeps que nunca vão para produção. Gera ruído.
**Solução:** Usar `npm audit --omit=dev` para focar apenas em dependências de produção.

## 5. Severity inflation: tudo parece Critical
**Problema:** Sem experiência, todo finding parece severo. Infla o report e perde credibilidade.
**Solução:** Usar CVSS scoring real. Perguntar: "Um atacante REAL conseguiria exploitar isto no nosso contexto?" Se não: downgrade.

## 6. Audit scope creep
**Problema:** Começar auditando auth e acabar reescrevendo metade do código.
**Solução:** Definir escopo ANTES de começar. Audit = encontrar e reportar. Fix = tarefa separada.

## 7. Trail of Bits skills requerem Claude Code com plugin marketplace
**Problema:** As skills do ToB são plugins que requerem `/plugin marketplace add trailofbits/skills`.
**Solução:** Nosso security-audit EXTRAI os patterns sem depender do plugin. Se quiser a experiência completa, instalar via marketplace.
