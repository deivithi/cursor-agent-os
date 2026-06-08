# 🎪 Regras de Eventos CIS — Alto Volume de Leads

> O Método CIS (Coaching Integral Sistêmico) gera eventos com **alto volume de leads em curto período**. Regras específicas para garantir qualidade e velocidade.

## Características dos Eventos CIS

| Aspecto | Detalhe |
|---------|---------|
| **Volume** | 500-5.000 leads por evento |
| **Duração** | 1-3 dias |
| **Captação** | QR Code + formulário presencial + landing page |
| **Urgência** | Leads devem ser contactados em < 30min ("lead quente") |
| **Cobrança** | Performance-based (ROI por lead convertido) |

## Regras Específicas CIS

### Pré-Evento (D-7 a D-1)
1. **Verificar infra:** Landing page ativa, QR code correto, form testado
2. **Testar integração:** Web-to-Lead ou API está criando leads corretamente
3. **Preparar vendedores:** Queue com membros, Assignment Rule ativa
4. **Duplicate Rule:** Mudar para modo "Block" (não apenas "Alert")
5. **Capacity planning:** Vendedores suficientes para volume esperado

### Durante Evento (D-Day)
1. **Monitorar em real-time:** Volume/hora vs expectativa
2. **Auditoria a cada 2h:** Duplicados, campos vazios, atribuição
3. **Escalar se:** Volume < 50% do esperado ou duplicados > 10%
4. **SLA de atribuição:** < 30 minutos (leads esfriam rápido)
5. **Backup:** Se form falhar, ter processo manual (planilha → import)

### Pós-Evento (D+1 a D+7)
1. **Auditoria completa:** Sanitização + dedup + completude
2. **Report de performance:** Leads captados vs contactados vs convertidos
3. **Cleanup:** Leads não qualificados → nurturing ou exclusão
4. **Duplicate Rule:** Voltar para modo "Alert"
5. **Lições aprendidas:** O que funcionou, o que falhou, gotchas novos

## Métricas de Referência CIS

| Fase | Métrica | Target | Alerta |
|------|---------|--------|--------|
| Captação | Leads/hora | 50-200 | < 20 |
| Qualidade | Completude campos | > 95% | < 85% |
| Qualidade | Taxa duplicados | < 5% | > 10% |
| Velocidade | Tempo atribuição | < 30min | > 2h |
| Conversão | Lead → Opp (30d) | > 5% | < 2% |

## Queries de Monitoramento Real-Time

```soql
-- Volume por hora (executar a cada 30min)
SELECT HOUR_IN_DAY(CreatedDate) hr, COUNT(Id) cnt
FROM Lead
WHERE CreatedDate = TODAY AND CIS_Event__c = '[NOME]'
GROUP BY HOUR_IN_DAY(CreatedDate)
ORDER BY HOUR_IN_DAY(CreatedDate)

-- Duplicados do dia
SELECT Email, COUNT(Id) cnt
FROM Lead
WHERE CreatedDate = TODAY AND CIS_Event__c = '[NOME]' AND Email != null
GROUP BY Email
HAVING COUNT(Id) > 1

-- Não atribuídos
SELECT COUNT(Id)
FROM Lead
WHERE CreatedDate = TODAY AND CIS_Event__c = '[NOME]' AND Owner.Type = 'Queue'
```
