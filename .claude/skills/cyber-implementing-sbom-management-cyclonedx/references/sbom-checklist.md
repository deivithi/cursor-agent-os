# 📦 SBOM Management Checklist

## Geração de SBOM
- [ ] CycloneDX ou SPDX como formato padrão
- [ ] SBOM gerado para cada `package.json` no monorepo
- [ ] Inclui dependências transitivas (`--include-dev=false` para prod)
- [ ] Gerado automaticamente no CI (não manual)
- [ ] Versionado junto com o release

## Análise de Vulnerabilidades
- [ ] `npm audit --omit=dev` no CI como gate
- [ ] Grype ou OSV-Scanner para scan de SBOM
- [ ] Apenas vulnerabilidades de produção são bloqueantes
- [ ] SLA definido: Critical=24h, High=7d, Medium=30d

## Dependency Management
- [ ] `npm ci` (não `npm install`) em CI
- [ ] `package-lock.json` commitado e atualizado
- [ ] Renovate/Dependabot para updates automáticos
- [ ] Major updates revisadas manualmente

## Monitoramento Contínuo
- [ ] Scan semanal automatizado (mesmo sem mudança de código)
- [ ] Alertas para novas CVEs em dependências atuais
- [ ] Dashboard de status de vulnerabilidades
