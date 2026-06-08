# 🔒 FLS & Sharing Rules Checklist — Salesforce Hardening

## OWD (Org-Wide Defaults)
- [ ] Lead: **Private** (vendedores só veem seus leads)
- [ ] Contact: **Controlled by Parent** (segue Account)
- [ ] Account: **Private** (por equipe/região)
- [ ] Opportunity: **Private**
- [ ] Case: **Private** ou **Read** (depende do modelo de suporte)

## FLS — Campos Sensíveis
- [ ] CPF: Read-only para perfis não-admin
- [ ] Telefone pessoal: Restrito por perfil
- [ ] Email pessoal: Restrito por perfil
- [ ] Dados financeiros: Somente perfis autorizados
- [ ] Consentimento LGPD: Read-only (apenas processo atualiza)

## Sharing Rules
- [ ] Critérios baseados em Role Hierarchy (não "All Internal Users")
- [ ] Sharing Rules de exceção documentadas e revisadas trimestralmente
- [ ] Nenhuma sharing rule com "Read/Write" desnecessário

## Permission Sets
- [ ] Perfis base com mínimo privilégio
- [ ] Permission Sets para acessos adicionais (não adicionar ao Profile)
- [ ] PS Groups para combinar permission sets por função

## Login & Session
- [ ] IP Ranges configurados por Profile
- [ ] Login Hours restringidos (horário comercial)
- [ ] Session Timeout: 30-60min
- [ ] MFA habilitado para todos os usuários
- [ ] Login Forensics ativado (se Shield disponível)

## Auditoria
- [ ] Setup Audit Trail revisado mensalmente
- [ ] Field Audit Trail para campos críticos (se Shield)
- [ ] Login History revisado para acessos anômalos
- [ ] SOQL de auditoria: `SELECT LoginTime, SourceIp, UserId FROM LoginHistory WHERE LoginTime = LAST_N_DAYS:7`
