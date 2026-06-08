# 🛡️ Cybersecurity Skills (572 skills ativas — Secure Development Fortress v3)

**Repositório:** `.claude/cybersecurity-skills/` (fonte: mukul975/Anthropic-Cybersecurity-Skills)
**Índice filtrado:** `.claude/cybersecurity-skills/index-filtered.json`
**Comando explícito:** `/cyber <descrição do que precisa>`

## ⚡ Ativação Automática

Quando o usuário mencionar qualquer tema de cybersecurity (segurança, vulnerabilidade, auditoria de segurança, OWASP, MITRE, phishing, IAM, zero trust, hardening, SOC, SIEM, incident response, threat hunting, LGPD, criptografia, secure coding, SBOM, supply chain, Salesforce security, etc.), o assistente **DEVE automaticamente**:

1. Consultar o índice em `.claude/cybersecurity-skills/index-filtered.json` para encontrar skills relevantes
2. Ler o `SKILL.md` da skill mais adequada em `.claude/cybersecurity-skills/skills/{skill-name}/SKILL.md`
3. Seguir o workflow descrito na skill, adaptando ao contexto

## 📂 Categorias Ativas

26 subcategorias, 572 skills. Consultar `index-filtered.json` para categorias e palavras-chave completas.

## 🏗️ Skills Customizadas (criadas para o perfil Deivithi)

| Skill | Foco | Palavras-chave |
|-------|------|----------------|
| `implementing-lgpd-data-protection-compliance` | 🇧🇷 LGPD completa | LGPD, ANPD, RIPD, encarregado, consentimento, Salesforce Privacy Center |
| `implementing-secure-coding-practices-owasp` | 🔐 Código seguro | OWASP SCP, CWE/SANS Top 25, Node.js, Python, Java, Go |
| `implementing-sbom-management-cyclonedx` | 📦 Supply chain | SBOM, CycloneDX, SPDX, Grype, OSV-Scanner, Dependency-Track |
| `designing-secure-api-architecture` | 🌐 API segura | OAuth 2.1, OIDC, mTLS, GraphQL security, OWASP API Top 10 |
| `hardening-salesforce-platform-security` | ☁️ Salesforce | FLS, sharing rules, Shield, Apex security, Experience Cloud, Marketing Cloud |

## 🚫 Categorias Removidas (não instaladas)

Malware Analysis, Digital Forensics, Red Teaming, Mobile Security, OT/ICS Security — removidas por serem ofensivas ou não aplicáveis ao perfil PO Salesforce.
