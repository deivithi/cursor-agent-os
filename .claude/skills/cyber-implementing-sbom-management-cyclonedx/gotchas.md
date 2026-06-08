# ⚠️ Gotchas — SBOM Management (CycloneDX)

---

## 1. npm audit reporta vulnerabilidades em devDependencies sem risco real

- **Sintoma:** `npm audit` mostra 50+ vulnerabilidades "high", gerando alarme. Mas todas são em devDependencies que não vão para produção
- **Causa raiz:** `npm audit` não distingue entre dependências de produção e desenvolvimento por default
- **Solução:** Usar `npm audit --omit=dev` para analisar apenas dependências de produção. Priorizar apenas essas
- **Prevenção:** No CI, rodar `npm audit --omit=dev --audit-level=high` como gate
- **Descoberto em:** 2026-03-18

---

## 2. SBOM gerado não inclui dependências transitivas de edge functions

- **Sintoma:** Vulnerabilidade em dependência transitiva (dep de dep) não aparece no SBOM
- **Causa raiz:** Gerador de SBOM rodou apenas no `package.json` root, não no diretório de edge functions do Supabase que tem `package.json` próprio
- **Solução:** Gerar SBOM para CADA `package.json` do monorepo: root, backend, edge functions
- **Prevenção:** Script de CI que encontra todos os `package.json` e gera SBOM consolidado
- **Descoberto em:** 2026-03-18

---

## 3. Dependência removida do package.json continua no node_modules

- **Sintoma:** Scanner de vulnerabilidade detecta pacote vulnerável que supostamente já foi removido
- **Causa raiz:** `npm uninstall` remove do `package.json` e `node_modules`, mas se `npm install` foi rodado sem `--clean`, o pacote órfão pode persistir
- **Solução:** `rm -rf node_modules && npm ci` (instalação limpa a partir do lock file)
- **Prevenção:** Usar `npm ci` (não `npm install`) em CI/CD. `ci` sempre instala do zero
- **Descoberto em:** 2026-03-18

---
