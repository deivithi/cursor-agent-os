# 📋 LGPD Compliance Checklist — Febracis

## Bases Legais (Art. 7)
- [ ] Consentimento coletado e armazenado com timestamp
- [ ] Legítimo interesse documentado com LIA (Legitimate Interest Assessment)
- [ ] Base legal definida por finalidade de tratamento

## Direitos do Titular (Art. 18)
- [ ] Processo de acesso a dados implementado (resposta em 15 dias)
- [ ] Processo de exclusão implementado (ALL data stores)
- [ ] Processo de portabilidade documentado
- [ ] Processo de correção disponível
- [ ] Canal de atendimento ao titular definido (encarregado)

## Segurança (Art. 46)
- [ ] Dados pessoais criptografados em trânsito (TLS 1.2+)
- [ ] Dados pessoais criptografados em repouso
- [ ] Controle de acesso por perfil (Salesforce FLS/Sharing Rules)
- [ ] Logs de acesso a dados pessoais habilitados
- [ ] Plano de resposta a incidentes documentado

## Salesforce Específico
- [ ] Shield Event Monitoring ativo (se disponível)
- [ ] Field-Level Security para campos sensíveis (CPF, telefone, email)
- [ ] Sharing Rules restritivas para dados pessoais
- [ ] Data Mask em sandboxes
- [ ] Privacy Center configurado (se disponível)

## Eventos CIS (Alto Volume)
- [ ] Consentimento coletado no momento do cadastro (formulário)
- [ ] Finalidade específica informada ("contato comercial sobre curso X")
- [ ] Dados retidos apenas pelo tempo necessário
- [ ] Processo de cleanup pós-evento (leads não convertidos)

## RIPD (Relatório de Impacto)
- [ ] Mapeamento de dados pessoais atualizado
- [ ] Fluxos de tratamento documentados
- [ ] Riscos identificados e mitigados
- [ ] Última atualização: ____/____/____
