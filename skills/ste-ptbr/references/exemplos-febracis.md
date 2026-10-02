# STE-PT — Exemplos no contexto Febracis

Cada exemplo tem o texto original (não STE) e a reescrita. As reescritas passam no
linter no nível 100 (teste: `test_exemplos_febracis_passam_no_nivel_100`).
O texto original fica dentro de citação (`>`), que o linter ignora.

## 1. Runbook — sanitização de leads do Método CIS

> Original: É de suma importância que o analista realize previamente a sanitização dos leads oriundos do evento, assegurando que os mesmos não possuam duplicidade, e posteriormente efetue a importação através do Data Loader.

1. Exporte os leads do evento do Método CIS.
2. Sanitize os campos de e-mail e telefone.
3. Rode a detecção de duplicados.
4. Se um lead estiver duplicado, mantenha o registro mais antigo.
5. Importe os leads com o Data Loader.

⚠️ ATENÇÃO: Confirme o total antes da importação. Um total errado gera comissão errada.

## 2. Mensagem de erro de Validation Rule

> Original: O campo Telefone deverá ser preenchido corretamente a fim de que o lead possa ser convertido.

Preencha o campo Telefone. O lead não converte sem telefone.

## 3. Passo Gherkin (salesforce-bdd-spec-architect)

> Original: Dado que o lead foi devidamente qualificado pelo vendedor e/ou pelo SDR

Dado um lead com status Qualificado.

Quando o vendedor converte o lead.

Então o Salesforce cria uma Oportunidade.

## 4. Comunicado para vendedores (valores fictícios)

> Original: Vale ressaltar que, no cenário atual, estaremos disponibilizando uma solução robusta visando otimizar a jornada dos leads.

A partir de [DATA], o Salesforce distribui os leads do Método CIS a cada 15 minutos.

Você recebe o lead no app. Ligue para o lead em até 1 hora.

## 5. Deploy em produção

> Original: Favor subir para produção após a homologação ser realizada pelo PO.

1. Peça a homologação ao PO.
2. Espere o aceite do PO.
3. Faça o deploy em produção.

⛔ BLOQUEIO: Não faça o deploy sem o aceite do PO. O deploy muda o fluxo de leads de todos os vendedores.
