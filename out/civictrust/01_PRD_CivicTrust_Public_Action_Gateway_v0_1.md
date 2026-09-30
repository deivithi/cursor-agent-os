# PRD — CivicTrust Public Action Gateway

**Versão:** 0.1  
**Data:** 22 de setembro de 2026  
**Owner proposto:** Produto CivicTrust  
**Status:** Draft para discovery e design partner  
**Tipo:** B2G SaaS / GovTech / Security & Trust Infrastructure

---

## 1. Visão

Permitir que serviços públicos digitais aceitem ações legítimas de cidadãos, representantes e agentes autorizados, enquanto identificam abuso coordenado e aplicam controles proporcionais, acessíveis, explicáveis e contestáveis.

---

## 2. Definição do produto

> CivicTrust Public Action Gateway é um gateway e control plane de integridade transacional para serviços públicos digitais.

Para cada ação, o sistema responde:

1. Quem ou o que está agindo?
2. Qual autoridade sustenta a ação?
3. A ação está dentro do escopo autorizado?
4. A interação faz parte de abuso coordenado?
5. Qual política do serviço se aplica?
6. Qual decisão proporcional deve ser executada?
7. Que evidência deve ser preservada?
8. Como a decisão pode ser revista?

---

## 3. Problema

Serviços públicos digitais combinam, de forma fragmentada:

- identidade;
- segurança de borda;
- formulários;
- regras de elegibilidade;
- alocação de vagas;
- logs;
- atendimento;
- ouvidoria.

Essa fragmentação dificulta diferenciar:

- cidadão legítimo;
- representante autorizado;
- agente autorizado;
- automação desconhecida;
- fraude distribuída;
- uso excessivo legítimo;
- campanha coordenada.

O resultado pode incluir:

- captura desigual de recursos;
- duplicidade;
- sobrecarga;
- desafio excessivo para cidadãos;
- decisões opacas;
- investigação lenta;
- falta de prova;
- dificuldade de contestação;
- dependência de regras ad hoc.

---

## 4. Por que agora

- Agentes de IA passam a navegar e executar tarefas em sites.
- Padrões de identidade de agente estão surgindo.
- CAPTCHAs estão perdendo efetividade relativa e criam barreiras.
- A categoria de mercado está migrando para confiança de agentes.
- Governos já oferecem serviços digitais em grande escala.
- Serviços com capacidade escassa possuem incentivo econômico para automação e intermediação.
- Requisitos de proteção de dados, transparência e acessibilidade elevam o padrão necessário.

---

## 5. Hipótese de wedge

### Serviço inicial

Agendamento, inscrição ou matrícula com capacidade escassa.

### Oferta inicial

**CivicTrust Exposure Assessment**

- shadow mode;
- baseline;
- clusterização;
- simulação;
- relatório;
- recomendação;
- plano de implantação.

---

## 6. Personas

### P1 — Gestor do serviço

**Objetivo:** distribuir o recurso conforme as regras, sem reconstruir o sistema.

**Dores:**

- reclamações;
- lotação instantânea;
- duplicidade;
- baixa visibilidade;
- dependência de TI;
- incapacidade de provar abuso.

### P2 — Analista SOC/CERT

**Objetivo:** detectar, investigar e conter campanhas.

**Dores:**

- sinais dispersos;
- ausência de contexto de negócio;
- logs incompletos;
- falso positivo;
- falta de outcome.

### P3 — Jurídico/DPO

**Objetivo:** assegurar tratamento proporcional e defensável.

**Dores:**

- score opaco;
- coleta excessiva;
- falta de base legal;
- ausência de revisão;
- contratos de terceiros.

### P4 — Cidadão

**Objetivo:** concluir o serviço com baixo atrito e tratamento justo.

**Dores:**

- CAPTCHA;
- lentidão;
- bloqueio;
- pouca explicação;
- nenhum recurso;
- baixa acessibilidade.

### P5 — Operador de agente autorizado

**Objetivo:** executar uma ação permitida em nome do usuário.

**Dores:**

- regras não documentadas;
- bloqueio indiscriminado;
- ausência de protocolo;
- autorização ampla;
- falta de recibo.

### P6 — Administrador da plataforma

**Objetivo:** configurar, observar e operar múltiplos serviços.

**Dores:**

- políticas em código;
- mudanças sem simulação;
- integrações específicas;
- auditoria fragmentada.

---

## 7. Jobs to be Done

1. Quando um serviço abre vagas, quero evitar captura coordenada sem bloquear cidadãos legítimos.
2. Quando uma interação é suspeita, quero aplicar verificação proporcional.
3. Quando um agente atua, quero saber quem o autorizou e para quê.
4. Quando uma decisão é contestada, quero reconstruir sua evidência.
5. Quando altero uma política, quero simular impacto antes da produção.
6. Quando ocorre uma campanha, quero enxergar relações entre sessões.
7. Quando um cidadão usa tecnologia assistiva ou conexão limitada, quero oferecer um fluxo viável.
8. Quando o órgão troca de WAF, quero preservar política e evidência.

---

## 8. Objetivos

### O1 — Visibilidade

Instrumentar serviços sem substituí-los.

### O2 — Integridade

Aplicar política por serviço, ação, autoridade e recurso.

### O3 — Baixo atrito

Evitar desafios para tráfego legítimo sempre que possível.

### O4 — Evidência

Registrar razões, versões e resultados.

### O5 — Contestabilidade

Permitir revisão de decisões relevantes.

### O6 — Interoperabilidade

Integrar GOV.BR, WAF, bot management, SIEM e sistemas legados.

### O7 — Preparação para agentes

Suportar identidade e autorização transacional de agentes.

---

## 9. Não objetivos

O produto v1 não será:

- CDN;
- WAF completo;
- mitigação volumétrica de DDoS;
- IdP;
- substituto do GOV.BR;
- proofing documental;
- fila virtual de hiperescala;
- CAPTCHA;
- sistema de concessão de benefícios;
- sistema de atendimento;
- biometria centralizada;
- blockchain;
- modelo fundacional;
- mecanismo que promete 100% de detecção.

---

## 10. Princípios do produto

1. **Observe antes de bloquear.**
2. **Autoridade antes de score.**
3. **Política antes de modelo.**
4. **Menor dado necessário.**
5. **Nenhuma negativa crítica exclusivamente por modelo.**
6. **Acessibilidade como requisito funcional.**
7. **Toda política é versionada.**
8. **Toda decisão relevante é explicável.**
9. **Toda ação de agente é limitada.**
10. **Configuração, não fork.**

---

## 11. Escopo funcional

### Épico E1 — Conectores e Shadow Mode

#### FR-001 — Avaliação de interação

O gateway deve receber uma requisição ou evento e gerar um `decision_id`.

#### FR-002 — Modo sombra

O sistema deve executar decisões simuladas sem alterar a transação.

#### FR-003 — Integração não invasiva

Deve suportar:

- reverse proxy;
- sidecar;
- SDK;
- API Gateway;
- webhook;
- batch de logs.

#### FR-004 — Catálogo de serviços

Cada serviço deve possuir:

- owner;
- criticidade;
- ações;
- recursos;
- bases de autoridade;
- política;
- retenção;
- fail mode.

---

### Épico E2 — Inteligência de ator e campanha

#### FR-005 — Normalização de sinais

Ingerir sinais de:

- HTTP;
- rede;
- dispositivo;
- sessão;
- WAF;
- bot manager;
- identidade;
- agente;
- histórico;
- outcome.

#### FR-006 — Classificação do ator

Categorias mínimas:

- `HUMAN_ANONYMOUS`;
- `HUMAN_AUTHENTICATED`;
- `HUMAN_REPRESENTATIVE`;
- `AGENT_IDENTIFIED`;
- `AGENT_AUTHORIZED`;
- `AUTOMATION_UNKNOWN`;
- `CAMPAIGN_COORDINATED`;
- `INCONCLUSIVE`.

#### FR-007 — Grafo de campanha

Relacionar eventos por:

- infraestrutura;
- sessão;
- dispositivo;
- conta;
- credencial;
- payload;
- cadência;
- sequência;
- recurso;
- resultado.

#### FR-008 — Investigação

Permitir abrir um caso a partir de uma decisão, ator ou cluster.

---

### Épico E3 — Autoridade

#### FR-009 — Adaptador GOV.BR

Ler claims autorizados de identidade e contexto de autenticação.

#### FR-010 — Representação

Interpretar representação humana aceita pelo serviço.

#### FR-011 — Identidade de agente

Validar assinatura e identidade do agente quando houver protocolo compatível.

#### FR-012 — Normalizador de autoridade

Produzir resultado:

- `VALID`;
- `INSUFFICIENT`;
- `EXPIRED`;
- `REVOKED`;
- `SCOPE_MISMATCH`;
- `UNVERIFIED`.

---

### Épico E4 — Policy Engine

#### FR-013 — Política por ação

A política deve considerar:

- tenant;
- serviço;
- ação;
- recurso;
- autoridade;
- criticidade;
- limite;
- risco;
- canal;
- horário;
- campanha;
- histórico.

#### FR-014 — Decisões

Disposições mínimas:

- `ALLOW`;
- `ALLOW_MONITORED`;
- `THROTTLE`;
- `EXTERNAL_QUEUE`;
- `STEP_UP`;
- `ISSUE_PERMIT`;
- `QUARANTINE`;
- `MANUAL_REVIEW`;
- `DENY`.

#### FR-015 — Reason codes

Toda decisão deve possuir reason codes estáveis.

#### FR-016 — Versionamento

Políticas devem possuir:

- draft;
- review;
- approval;
- effective date;
- rollback;
- changelog.

#### FR-017 — Maker-checker

Mudanças de produção devem exigir dois papéis distintos.

---

### Épico E5 — Verificação adaptativa

#### FR-018 — Step-up

Suportar:

- reautenticação;
- passkey;
- confirmação no dispositivo;
- prova de atributo;
- canal alternativo;
- revisão manual.

#### FR-019 — Acessibilidade

O step-up deve:

- funcionar por teclado;
- oferecer texto claro;
- ter alternativa não visual;
- respeitar leitor de tela;
- funcionar em conexão limitada;
- permitir retomada.

#### FR-020 — Motivo do step-up

O usuário deve receber explicação suficiente, sem revelar controles que facilitem fraude.

---

### Épico E6 — Permissão de Ação Pública

#### FR-021 — Emissão

Emitir permissão após autoridade e política válidas.

#### FR-022 — Escopo

A permissão deve conter:

- emissor;
- sujeito;
- ator/agente;
- serviço;
- ação;
- recurso;
- constraints;
- payload digest;
- validade;
- contador;
- nonce;
- contexto de autenticação;
- versão da política.

#### FR-023 — Verificação

O receptor deve verificar:

- assinatura;
- audiência;
- expiração;
- escopo;
- payload;
- sender binding;
- uso anterior;
- revogação.

#### FR-024 — Revogação

Deve ser possível revogar antes da expiração.

#### FR-025 — Recibo

O cidadão deve receber um recibo legível da ação autorizada.

---

### Épico E7 — Evidência, revisão e recurso

#### FR-026 — Evidence pack

Cada decisão deve registrar:

- dados observados;
- sinais utilizados;
- razões;
- política;
- modelo;
- versão;
- obrigação;
- execução;
- outcome.

#### FR-027 — Cadeia de custódia

Eventos devem ser assinados ou encadeados de forma verificável.

#### FR-028 — Revisão humana

Casos elegíveis devem ser encaminhados a fila com contexto suficiente.

#### FR-029 — Contestação

O cidadão deve possuir identificador para acompanhar revisão.

#### FR-030 — Retificação

Quando uma decisão for revertida:

- o outcome deve ser atualizado;
- a política/modelo deve receber feedback;
- o cidadão deve ser notificado conforme o serviço.

---

### Épico E8 — Simulação e governança

#### FR-031 — Replay histórico

Executar uma política sobre eventos passados.

#### FR-032 — Comparação

Comparar:

- política atual;
- candidata;
- decisão;
- atrito;
- impacto estimado;
- grupos afetados;
- volume operacional.

#### FR-033 — Aprovação

A publicação deve mostrar:

- mudança;
- justificativa;
- simulação;
- risco;
- rollback;
- aprovadores.

---

### Épico E9 — Outcome feedback

#### FR-034 — Ingestão de resultado

Receber:

- conclusão;
- cancelamento;
- no-show;
- duplicidade;
- fraude confirmada;
- recurso deferido;
- erro;
- venda/revenda identificada, quando aplicável.

#### FR-035 — Qualidade de label

Distinguir:

- confirmado;
- presumido;
- contestado;
- desconhecido.

---

## 12. Fluxos principais

### Fluxo A — Cidadão legítimo

1. Requisição chega.
2. Sinais são normalizados.
3. Autoridade é suficiente.
4. Não há campanha suspeita.
5. Política retorna `ALLOW`.
6. Evidência mínima é registrada.
7. Serviço conclui.
8. Outcome retorna.

### Fluxo B — Interação suspeita

1. Cluster coordenado é identificado.
2. Política retorna `STEP_UP` ou `QUARANTINE`.
3. Cidadão recebe alternativa acessível.
4. Verificação é concluída.
5. Ação prossegue ou é revisada.
6. Resultado real alimenta o sistema.

### Fluxo C — Agente autorizado

1. Agente se identifica.
2. Cidadão autentica.
3. Escopo é apresentado.
4. Cidadão confirma.
5. Permissão é emitida.
6. Agente executa uma ação vinculada.
7. Serviço verifica token e payload.
8. Recibo e evidência são gerados.

### Fluxo D — Recurso

1. Usuário informa identificador.
2. Sistema recupera decision pack.
3. Analista revisa política e fatos.
4. Decisão é mantida ou revertida.
5. Outcome e feedback são registrados.

---

## 13. UX e telas

1. Command Center.
2. Catálogo de serviços.
3. Live Decisions.
4. Campaign Graph.
5. Investigation Workspace.
6. Policy Studio.
7. Simulator.
8. Authority & Agent Registry.
9. Action Permits.
10. Evidence & Appeals.
11. Integrations.
12. Data Governance.
13. Threat Lab.

### Requisito de UX

Nunca exibir apenas um número de risco. Exibir:

- conclusão;
- razões;
- evidência;
- incerteza;
- política;
- impacto;
- próximo passo.

---

## 14. Métricas

### North Star

> Percentual de transações de serviço escasso concluídas por atores autorizados, com evidência completa e sem atrito evitável.

### Segurança e integridade

- taxa de campanhas identificadas;
- abuso confirmado;
- duplicidade;
- concentração;
- replay;
- permissões inválidas;
- tempo de detecção;
- tempo de contenção.

### Experiência

- conclusão legítima;
- challenge rate;
- abandono;
- tempo adicional;
- acessibilidade;
- step-up bem-sucedido;
- retomada.

### Qualidade da decisão

- falso positivo;
- falso negativo;
- inconclusivos;
- recurso;
- taxa de reversão;
- precisão por razão;
- cobertura de labels.

### Operação

- p95/p99 de latência;
- disponibilidade;
- falhas de conector;
- tempo de investigação;
- políticas simuladas;
- rollbacks.

### Negócio

- serviços protegidos;
- transações;
- expansão por órgão;
- receita anual;
- custo por milhão de avaliações;
- horas de serviço por cliente;
- margem por deployment.

---

## 15. SLOs iniciais — hipóteses

Estes valores precisam de validação técnica:

- disponibilidade do data plane: 99,95%;
- p95 da decisão local/cacheada: menor que 100 ms;
- p95 de avaliação completa: menor que 300 ms;
- evidência disponível: até 5 segundos;
- RPO de configuração: até 5 minutos;
- RTO do control plane: até 1 hora;
- zero reutilização aceita de permissão one-time;
- 100% das negativas críticas com reason code e referência de revisão.

---

## 16. Critérios de aceite do MVP

1. Integrar um serviço sem alterar seu core.
2. Operar 30 dias em shadow mode.
3. Processar e correlacionar eventos.
4. Simular ao menos três políticas.
5. Explicar 100% das decisões simuladas.
6. Exportar evidence pack.
7. Receber outcomes.
8. Medir falso positivo em amostra rotulada.
9. Demonstrar step-up acessível.
10. Emitir e verificar Permissão de Ação Pública em ambiente controlado.
11. Impedir replay.
12. Realizar rollback de política.

---

## 17. Dependências

- patrocinador do órgão;
- acesso a logs;
- DPO/jurídico;
- integrador;
- identidade;
- WAF/API gateway;
- ambiente de homologação;
- labels de outcome;
- canal de recurso;
- threat lab.

---

## 18. Questões abertas

1. Qual vertical apresenta melhor relação dor/risco?
2. Qual claim GOV.BR estará disponível?
3. Como validar representação em cada esfera?
4. Qual formato final da permissão?
5. Qual política de retenção?
6. Quais sinais podem ser compartilhados entre órgãos?
7. Qual modelo de implantação será exigido?
8. Queue-it será concorrente, parceiro ou integração?
9. Quais decisões podem ser automatizadas?
10. Qual é o budget de falso positivo?
11. Qual nome comercial estará disponível?
12. Qual caminho de contratação prevalecerá?
