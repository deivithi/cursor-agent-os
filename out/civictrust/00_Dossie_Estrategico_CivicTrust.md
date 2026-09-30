# Dossiê Estratégico — CivicTrust Public Action Gateway

**Versão:** 0.1  
**Data:** 22 de setembro de 2026  
**Status:** hipótese estratégica informada por pesquisa pública; requer validação com órgãos, dados reais, assessoria jurídica e testes técnicos.

---

## 1. Conclusão executiva

A pesquisa modifica de forma relevante a ideia original.

O produto não deve ser apresentado como:

- um CAPTCHA moderno;
- um detector genérico de bots;
- um WAF;
- uma fila virtual;
- uma plataforma genérica de identidade;
- um “mandato para agentes” isolado.

Essas categorias já possuem fornecedores fortes, padrões em andamento e, em alguns casos, ofertas direcionadas ao setor público.

### Produto recomendado

> **CivicTrust Public Action Gateway é uma camada governamental de integridade transacional que verifica quem ou o que está executando uma ação pública digital, se existe autoridade válida, se a ação respeita as regras do serviço e da alocação de recursos, se faz parte de abuso coordenado e qual decisão explicável e contestável deve ser aplicada.**

Ele fica entre:

1. os canais de acesso — navegador humano, aplicativo, representante, bot ou agente de IA;
2. as camadas existentes — CDN, WAF, bot management, GOV.BR e identidade local;
3. os sistemas de serviço — agendamento, matrícula, inscrição, benefício, licença, protocolo e cadastro.

### Primeiro produto comercial

> **CivicTrust Exposure Assessment + Shadow Gateway**

Uma implantação de diagnóstico, inicialmente sem bloqueio, que:

- instrumenta um serviço público;
- mede automação, duplicidade, abuso coordenado e concentração de recursos;
- simula políticas;
- constrói a linha de base;
- produz evidência para segurança, negócio, jurídico, privacidade e contratação;
- define se existe caso econômico e operacional para adoção permanente.

A venda inicial não deve pressupor que “há bots”. Ela deve provar:

- se há automação;
- qual é o impacto;
- quais controles atuais falham;
- quanto de atrito os controles adicionam;
- quais decisões seriam seguras;
- qual retorno operacional pode ser mensurado.

---

## 2. O que a pesquisa mudou

### 2.1 Fila justa e agente autorizado não são espaço em branco

A Queue-it já atua em governos, oferece sala de espera virtual, controle de tráfego e mitigação de bots. Em 2026, apresentou um conceito no qual um agente recebe credencial e mandato do usuário para disputar um recurso escasso sob regras equivalentes às dos humanos.

**Implicação:** não podemos construir a tese de exclusividade em “fila justa + agente autorizado”.

### 2.2 O GOV.BR já possui procuração eletrônica

A infraestrutura GOV.BR já prevê representação humana para serviços integrados, com escopo, validade, histórico e claims específicos.

**Implicação:** não devemos chamar nosso artefato de “procuração” nem substituir a representação legal existente.

A proposta correta é uma **Permissão de Ação Pública**, curta, técnica e transacional, emitida após a autoridade principal ter sido validada.

### 2.3 Prova de humanidade está migrando para credenciais e tokens privados

Mozilla, Cloudflare e outros participantes trabalham em propostas como PACT, enquanto Privacy Pass e personhood credentials exploram prova de acesso, escassez ou humanidade com menor correlação entre serviços.

**Implicação:** não devemos inventar criptografia própria de “proof of human”. O produto deve ser adaptável a GOV.BR, passkeys, PACT, Privacy Pass e credenciais verificáveis.

### 2.4 Identidade do agente não resolve autoridade

Web Bot Auth e assinaturas HTTP podem provar a origem de um agente participante, mas não comprovam, sozinhas:

- qual cidadão o autorizou;
- para qual ação;
- com qual limite;
- por quanto tempo;
- com qual responsabilidade;
- se o agente foi comprometido.

**Implicação:** nosso núcleo é normalizar autoridade, intenção, política pública, risco e evidência.

### 2.5 Não há evidência pública suficiente do problema no Brasil

Foram encontrados:

- ampla digitalização de serviços;
- uso de reCAPTCHA no próprio ecossistema GOV.BR;
- portais estaduais e municipais de grande escala;
- casos internacionais claros de captura de agendamentos;
- mercado global maduro de bot management.

Não foi encontrada evidência pública robusta de que secretarias brasileiras já mensurem bots, enxames ou revenda de vagas em escala comparável aos casos internacionais.

**Implicação:** o primeiro marco do projeto é descobrir e quantificar a dor local, não construir uma plataforma completa por antecipação.

---

## 3. Tese de mercado revisada

### 3.1 Categoria externa

O mercado está convergindo de **bot management** para **bot and agent trust management**:

- procedência do agente;
- vinculação a uma conta ou operador;
- políticas diferenciadas;
- autenticação criptográfica;
- risco por transação;
- governança de agentes;
- pesquisa contínua de ameaças.

### 3.2 Categoria que devemos ocupar

> **Public Digital Transaction Integrity**

Em português:

> **Integridade de Transações Públicas Digitais**

A categoria é mais estreita e defensável do que “antibot”.

Ela combina:

- segurança de borda;
- identidade;
- delegação;
- regras do serviço público;
- distribuição justa de recursos;
- evidência administrativa;
- revisão e contestação;
- acessibilidade;
- soberania de dados.

### 3.3 Problema que compramos

Órgãos públicos normalmente possuem peças separadas:

- CDN/WAF;
- CAPTCHA;
- identidade GOV.BR ou local;
- sistema de agendamento;
- logs;
- SIEM;
- regras em código;
- atendimento e ouvidoria.

Mesmo quando essas peças existem, podem faltar:

- visão única do ator;
- correlação entre sessões;
- prova de autoridade transacional;
- política uniforme por ação;
- análise de campanhas;
- decisão explicável;
- simulação antes do bloqueio;
- vínculo entre decisão e resultado;
- processo técnico de revisão.

---

## 4. Mapa de mercado

| Categoria | Exemplos observados | Força principal | Lacuna relativa à tese CivicTrust |
|---|---|---|---|
| Bot/Agent Trust na borda | Cloudflare, Akamai, DataDome, HUMAN, Google, Imperva, Arkose | Detecção, mitigação, reputação, sinais de rede e dispositivo | Não demonstram, em materiais públicos revisados, uma camada governamental brasileira completa de autoridade, política do serviço, evidência e recurso |
| Tráfego e fila justa | Queue-it | Picos, waiting room, distribuição de acesso, mitigação de bots, governo | Está muito próxima do caso de recurso escasso; precisamos complementar, não copiar |
| Agent IAM e confiança | Microsoft, Okta/Auth0, DigiCert, Experian | Identidade, escopo, credencial, governança de agentes | Mais orientados a empresa, workforce ou comércio |
| Identidade pública | GOV.BR, Login.gov, carteiras de identidade digital | Autenticação e atributos do cidadão | Não substitui detecção de campanhas, regras de alocação e integridade da transação |
| Credenciais privadas | PACT, Privacy Pass, personhood credentials | Baixo atrito, menor rastreabilidade entre sites | Protocolos/abordagens ainda precisam de orquestração e política local |
| CivicTrust proposto | Gateway de ação pública | Autoridade + política + abuso coordenado + evidência + recurso | Hipótese a validar; não comprovadamente exclusiva |

### Posição recomendada

O CivicTrust deve **integrar** sinais de fornecedores já existentes.

Não deve tentar, no MVP, superar empresas globais em:

- fingerprint de navegador;
- reputação global de IP;
- DDoS;
- CDN;
- salas de espera em hiperescala;
- prova de identidade documental.

---

## 5. Consenso técnico emergente

A revisão de padrões, papers e ofertas aponta seis princípios.

### Princípio 1 — Procedência não é confiança

Saber que uma chamada veio de um agente conhecido não demonstra que sua ação é legítima.

### Princípio 2 — Autoridade deve ser restrita à ação

Credenciais amplas são inadequadas para agentes. Autoridade deve ser:

- explícita;
- de curta duração;
- limitada ao serviço;
- limitada à ação;
- vinculada ao payload ou parâmetros;
- revogável;
- auditável.

### Princípio 3 — Humanidade não precisa equivaler a identidade civil completa

É possível utilizar:

- passkeys;
- tokens privados;
- credenciais de pessoa;
- limites por emissor;
- provas de elegibilidade;
- step-up proporcional.

O objetivo deve ser coletar o mínimo necessário.

### Princípio 4 — Agentes legítimos também podem ser comprometidos

Prompt injection, ferramentas externas, credenciais vazadas e instruções maliciosas podem induzir um agente válido a executar uma ação indevida.

### Princípio 5 — No setor público, a decisão precisa ser revisável

Bloquear acesso a um serviço público pode afetar direitos e interesses. Portanto, decisões relevantes exigem:

- razão compreensível;
- versão da política;
- evidência;
- alternativa de atendimento;
- revisão humana;
- recurso ou contestação.

### Princípio 6 — Detecção é operação contínua

Modelos e regras envelhecem. O produto precisa de:

- threat lab;
- simulação;
- shadow mode;
- champion/challenger;
- monitoramento de drift;
- resposta rápida a falso positivo;
- feedback do resultado final.

---

## 6. Fundamentos técnicos recomendados

### Adotar ou integrar

| Necessidade | Padrão/infraestrutura preferencial |
|---|---|
| Identidade do cidadão | OIDC/OAuth do GOV.BR ou IdP local |
| Nível de autenticação | Claims e contexto de autenticação |
| Consentimento reforçado | WebAuthn/passkeys |
| Identidade de agente | HTTP Message Signatures e Web Bot Auth quando disponíveis |
| Autorização detalhada | OAuth Rich Authorization Requests |
| Credenciais portáveis | W3C Verifiable Credentials + OpenID4VC |
| Propagação de contexto | Token Exchange e Transaction Tokens |
| Tokens privados/antiabuso | Privacy Pass e futura compatibilidade PACT |
| Observabilidade | OpenTelemetry e exportação SIEM |
| Evidência inviolável | WORM, assinatura e encadeamento por hash/Merkle |

### Não inventar

- algoritmo criptográfico próprio;
- padrão proprietário de identidade;
- biometria centralizada;
- “proof of human” fechada;
- blockchain como requisito;
- score único opaco;
- CAPTCHA próprio.

---

## 7. Realidade regulatória brasileira

### 7.1 Lei de Governo Digital

O desenho deve favorecer:

- digitalização;
- interoperabilidade;
- acessibilidade;
- uso proporcional de mecanismos de segurança;
- simplificação;
- monitoramento de desempenho;
- transparência;
- proteção de dados;
- alternativa de atendimento.

### 7.2 LGPD

O produto precisará demonstrar:

- finalidade;
- adequação;
- necessidade;
- transparência;
- segurança;
- prevenção;
- não discriminação;
- responsabilização;
- revisão de decisões automatizadas que afetem interesses;
- documentação do tratamento público.

### 7.3 eMAG

CAPTCHAs e desafios podem criar barreiras. A verificação deve ser:

- adaptativa;
- compatível com tecnologia assistiva;
- navegável por teclado;
- com linguagem clara;
- com canal alternativo;
- testada em aparelhos modestos e redes lentas.

### 7.4 Procuração eletrônica GOV.BR

A autoridade legal deve vir de uma fonte aceita pelo serviço:

- próprio cidadão;
- representante humano válido;
- conta organizacional;
- credencial verificável;
- regra administrativa específica.

A **Permissão de Ação Pública** não cria autoridade jurídica. Ela limita e transporta tecnicamente uma autoridade já validada.

### 7.5 Contratação

O CPSI é um caminho relevante porque permite:

- descrever o problema;
- testar soluções concorrentes;
- definir métricas;
- conviver com risco tecnológico;
- contratar solução posterior em condições previstas pela lei.

Não é o único caminho. Também podem existir:

- contratação por integrador;
- prova de conceito;
- laboratório de inovação;
- encomenda tecnológica;
- contratação comum de software;
- parceria acadêmica.

A estratégia precisa ser definida caso a caso.

---

## 8. Casos internacionais que validam a dor

### 8.1 Agendamentos de prova de direção no Reino Unido

A autoridade britânica reportou uso de bots e intermediários para capturar horários e revendê-los. Controles foram reforçados ao longo do tempo, sem eliminar imediatamente o problema.

**Aprendizado:** o alvo não é apenas disponibilidade do site; é integridade da alocação.

### 8.2 Agendamentos consulares

Alertas oficiais já foram emitidos contra intermediários e automações que prometem antecipar horários.

**Aprendizado:** recursos escassos criam mercado secundário e incentivo para automação.

### 8.3 Serviços públicos com pico

Casos da Queue-it mostram governos utilizando fila virtual para grandes ondas de acesso.

**Aprendizado:** picos legítimos e abuso automatizado são problemas diferentes; podem precisar de produtos complementares.

---

## 9. Produto recomendado em detalhe

### 9.1 Nome provisório

**CivicTrust Public Action Gateway**

O nome CivicTrust é apenas provisório. Pesquisa profissional de marca, domínio, razão social e conflito internacional ainda é obrigatória.

### 9.2 Componentes

#### 1. Shadow Gateway

Observa requisições e eventos sem alterar a experiência.

#### 2. Signal Fabric

Normaliza sinais de:

- WAF;
- bot manager;
- rede;
- dispositivo;
- sessão;
- identidade;
- assinaturas de agentes;
- credenciais;
- histórico;
- resultado do sistema.

#### 3. Actor & Authority Resolver

Distingue:

- cidadão autenticado;
- cidadão provável;
- representante humano;
- agente autenticado;
- agente autorizado;
- automação desconhecida;
- campanha coordenada.

#### 4. Campaign Graph

Agrupa atividade por relações e padrões, sem depender apenas de IP.

#### 5. Public Service Policy Engine

Executa regras por:

- serviço;
- ação;
- recurso;
- criticidade;
- elegibilidade;
- limite;
- horário;
- autoridade;
- risco;
- canal;
- versão.

#### 6. Public Action Permit

Token curto e vinculado a uma ação.

#### 7. Enforcement Orchestrator

Pode:

- permitir;
- observar;
- limitar;
- direcionar para fila externa;
- solicitar step-up;
- emitir permissão;
- colocar em quarentena;
- solicitar revisão;
- negar.

#### 8. Evidence & Appeal

Registra:

- fatos;
- sinais utilizados;
- motivo;
- política;
- modelo;
- versão;
- decisão;
- operador;
- resultado;
- contestação;
- revisão.

#### 9. Policy Simulator

Reproduz tráfego histórico contra regras novas antes de produção.

#### 10. Threat Lab

Testa automação, agentes, replay, prompt injection, bypass e falsos positivos.

---

## 10. Permissão de Ação Pública

### Definição

> Artefato técnico, de curta duração, emitido após validação de autoridade, que permite a um ator executar uma ação pública específica dentro de limites verificáveis.

### Propriedades

- uso único ou contador explícito;
- curta duração;
- destino específico;
- serviço específico;
- ação específica;
- recurso específico;
- hash do payload;
- limite de tentativas;
- vínculo ao emissor e receptor;
- proteção contra replay;
- revogação;
- trilha de evidência;
- versão da política;
- contexto de autenticação.

### Exemplo

Um cidadão autoriza um agente a:

- consultar horários;
- reservar um único horário;
- em determinada unidade;
- durante sete dias;
- sem cancelar marcações;
- sem alterar dados cadastrais.

A permissão não autoriza:

- trocar endereço;
- cancelar marcação;
- reservar múltiplos horários;
- usar outro serviço;
- enviar dados diferentes dos aprovados.

---

## 11. Fronteira do MVP

### Construir

1. gateway em modo sombra;
2. esquema de eventos;
3. policy engine;
4. evidence log;
5. conectores para identidade e WAF;
6. classificação inicial por regras e sinais externos;
7. agrupamento de campanhas;
8. simulador;
9. fluxo de revisão;
10. primeira versão da Permissão de Ação Pública.

### Comprar, integrar ou postergar

1. CDN e DDoS;
2. reputação global de IP;
3. fingerprint avançado;
4. proofing documental;
5. SMS/telefone;
6. fila virtual de hiperescala;
7. CAPTCHA;
8. SIEM;
9. atendimento/omnichannel;
10. modelos fundacionais.

---

## 12. Vertical inicial

### Hipótese preferencial

**Agendamento, inscrição ou matrícula com capacidade escassa.**

Exemplos:

- emissão de documentos;
- habilitação;
- cursos gratuitos;
- matrículas;
- concursos e seleções;
- licenças;
- programas habitacionais;
- agendas administrativas.

### Critérios de seleção

O serviço precisa ter:

- volume;
- escassez real;
- janela de abertura;
- reclamações;
- suspeita de automação ou concentração;
- logs disponíveis;
- resultado verificável;
- patrocinador;
- possibilidade de proxy/API/SDK;
- canal de recurso.

### O que evitar primeiro

- saúde crítica;
- concessão automática de benefício;
- decisões que eliminem direito sem revisão;
- sistemas sem logs;
- órgãos sem patrocinador;
- projetos que exijam substituir o portal inteiro.

---

## 13. Descoberta necessária

### 13.1 Entrevistas

Meta recomendada:

- 6 a 8 órgãos;
- 30 a 40 entrevistas;
- pelo menos cinco perfis por órgão quando possível.

Perfis:

- dono do serviço;
- CIO ou tecnologia;
- segurança;
- encarregado de dados;
- jurídico;
- ouvidoria;
- acessibilidade;
- compras;
- integrador atual.

### Perguntas centrais

1. Qual recurso é escasso?
2. Como a elegibilidade é definida?
3. Há dado ou apenas percepção de bot?
4. Existe revenda, duplicidade ou bloqueio de agenda?
5. Quais controles atuais existem?
6. Qual o custo de um falso positivo?
7. Qual o custo de um falso negativo?
8. Há atendimento alternativo?
9. Quem pode representar o cidadão?
10. Quais logs e resultados podem ser compartilhados?
11. Quem aprova uma política?
12. Qual caminho de contratação é viável?

### 13.2 Baseline técnico

Medir por 30 a 45 dias:

- requisições;
- sessões;
- picos;
- taxas;
- origens;
- fingerprints disponíveis;
- duplicidades;
- cadastros relacionados;
- cancelamentos;
- reservas não utilizadas;
- concentração por pessoa/conta;
- comportamento sequencial;
- scores dos controles existentes;
- reclamações;
- resultados finais.

### 13.3 Benchmark ofensivo

Laboratório mínimo:

- Playwright;
- Puppeteer;
- navegadores com agentes;
- proxies residenciais;
- fingerprint spoofing;
- CAPTCHA solvers;
- human-in-the-loop;
- replay;
- roubo de token;
- prompt injection;
- bypass por API;
- dispositivos móveis;
- baixo volume distribuído.

### 13.4 Jurídico e privacidade

Produzir parecer sobre:

- papel de controlador e operador;
- base legal;
- tratamento de sinais;
- retenção;
- compartilhamento;
- decisões automatizadas;
- contestação;
- uso de identidade;
- representação;
- validade da Permissão de Ação Pública;
- propriedade intelectual;
- contratação;
- responsabilização por falha.

### 13.5 Patentes e marca

Não foi concluída pesquisa profissional.

Contratar:

- busca de anterioridade;
- freedom to operate;
- análise de patentes;
- busca de marca no INPI;
- busca internacional;
- estratégia de segredo industrial;
- proteção do protocolo e da implementação.

---

## 14. Critérios de avanço

### Go

Avançar para produto quando:

- três órgãos confirmarem o mesmo problema com evidências;
- um órgão aceitar piloto pago;
- houver logs e outcome labels;
- a integração não exigir reconstrução;
- o custo do abuso puder ser mensurado;
- existir fluxo de recurso;
- o falso positivo aceitável estiver definido;
- a solução demonstrar valor além do WAF e da fila.

### Pivot

- Se o problema for apenas pico: integrar Queue-it ou similar.
- Se o problema for apenas login: integrar GOV.BR/IdP.
- Se o problema for apenas DDoS: não construir este produto.
- Se não houver labels: começar por analytics e investigação.
- Se cada cliente exigir código exclusivo: criar conectores ou trabalhar via integrador.
- Se não houver base jurídica para enforcement: permanecer em observação e apoio à decisão.

### Stop

Interromper a tese quando:

- órgãos não compartilham telemetria;
- o abuso não é material;
- controles existentes já resolvem;
- não há patrocinador;
- não há caminho de contratação;
- a solução aumenta exclusão;
- a margem depende de serviço manual permanente.

---

## 15. Modelo comercial

### Oferta 1 — Exposure Assessment

- duração: quatro a seis semanas;
- gateway em modo sombra;
- análise de risco;
- mapa de campanhas;
- simulação;
- relatório executivo;
- plano de controle;
- matriz jurídica e de privacidade inicial.

### Oferta 2 — Platform License

- licença anual;
- cobrança por serviço protegido e faixa de transações;
- ambiente compartilhado ou dedicado;
- conectores;
- política;
- evidência;
- suporte.

### Oferta 3 — Threat Lab & Assurance

- red team periódico;
- testes de bypass;
- validação de acessibilidade;
- revisão de política;
- resposta a incidentes;
- SLA premium.

### Evitar

Cobrança por “bot bloqueado”, pois cria incentivo ruim e dificulta auditoria.

---

## 16. Escalabilidade e margem

### Margem potencialmente favorável

- policy engine comum;
- conectores reutilizáveis;
- esquema de eventos comum;
- dashboard multi-tenant;
- pacotes por vertical;
- processamento de borda;
- análise pesada somente para suspeitas;
- integração com fornecedores em vez de reconstrução.

### Destruidores de margem

- ambiente on-premises não padronizado;
- customização por órgão;
- operação manual 24x7;
- suporte sem limites;
- integração legada única;
- armazenamento de todos os sinais brutos por longos períodos;
- dependência de LLM por requisição;
- requisitos de certificação absorvidos sem preço.

### Regra de produto

> Configuração por cliente, não fork por cliente.

---

## 17. Roadmap de 180 dias

### Dias 0–30

- entrevistas;
- seleção de vertical;
- parecer jurídico inicial;
- modelo de eventos;
- arquitetura;
- concorrentes e demos;
- primeiro design partner.

### Dias 31–60

- reverse proxy/SDK;
- ingestão;
- log de evidência;
- policy engine;
- dashboard;
- shadow mode;
- integração inicial com WAF/IdP.

### Dias 61–90

- piloto observacional;
- grafo;
- simulador;
- baseline;
- relatório;
- go/no-go.

### Dias 91–140

- throttling;
- quarentena;
- step-up acessível;
- revisão;
- exportação SIEM;
- feedback de resultado.

### Dias 141–180

- Permissão de Ação Pública;
- agente assinado;
- payload binding;
- replay protection;
- red team;
- avaliação de expansão.

---

## 18. Principais riscos

| Risco | Mitigação |
|---|---|
| Problema brasileiro menor do que a tese | Diagnóstico pago e modo sombra |
| Queue-it ou grandes fornecedores entrarem no espaço | Especialização em autoridade pública, evidência, recurso e integração brasileira |
| Falso positivo excluir cidadão | Step-up, revisão, canal alternativo e limites para decisão automática |
| Dependência de dados pessoais | Minimização, pseudonimização, separação de PII e retenção curta |
| Órgão exigir on-premises | Data plane soberano e control plane desacoplado |
| Vendas longas | CPSI, integradores, laboratórios e design partners |
| Produto virar consultoria | DSL, conectores e pacotes por vertical |
| Agente legítimo comprometido | Permissão curta, payload-bound, confirmação e monitoramento |
| Regras discriminatórias | atributos proibidos, testes de impacto e governança |
| Evidência fraca | esquema assinado, versionamento e cadeia de custódia |

---

## 19. Hipóteses críticas ainda não verificadas

1. Secretarias brasileiras sofrem abuso automatizado material.
2. O abuso causa perda operacional ou social mensurável.
3. Os órgãos conseguem compartilhar logs suficientes.
4. Há orçamento e patrocinador.
5. O órgão aceitará uma camada intermediária.
6. A integração GOV.BR estará disponível ao projeto.
7. A Permissão de Ação Pública terá encaixe jurídico e operacional.
8. Existe margem após requisitos de infraestrutura dedicada.
9. O mercado aceitará uma nova categoria.
10. A marca CivicTrust está disponível.

---

## 20. Registro de fontes-chave consultadas

### Padrões e protocolos

- IETF Web Bot Auth Working Group.
- RFC 9421 — HTTP Message Signatures.
- RFC 9396 — OAuth Rich Authorization Requests.
- RFC 8693 — OAuth Token Exchange.
- Transaction Tokens Internet-Draft.
- W3C WebAuthn Level 3.
- W3C Verifiable Credentials Data Model 2.0.
- OpenID for Verifiable Presentations 1.0.
- OpenID for Verifiable Credential Issuance 1.0.
- Privacy Pass Architecture e issuance protocols.
- NIST Digital Identity Guidelines.
- NIST AI Agent Standards Initiative.

### Pesquisa

- Personhood Credentials.
- AgentDojo.
- Intent-Governed Tool Authorization for AI Agents.
- Digital Identity Delegation / Trust Gateway.
- pesquisas sobre ataques modernos a reCAPTCHA.
- estudos sobre confiança em sistemas automatizados públicos.
- PACT — Mozilla e comunidade Anti-Fraud.

### Mercado

- Forrester — Bot and Agent Trust Management.
- Cloudflare.
- Google reCAPTCHA Enterprise e Web Bot Auth.
- Akamai.
- DataDome.
- HUMAN Security.
- Imperva.
- Arkose Labs.
- Queue-it.
- Microsoft Entra.
- Okta/Auth0.
- DigiCert.
- Experian.

### Brasil

- Lei nº 14.129/2021 — Governo Digital.
- Lei nº 13.709/2018 — LGPD.
- Lei Complementar nº 182/2021 — Marco Legal das Startups/CPSI.
- eMAG.
- documentação GOV.BR de login único.
- documentação GOV.BR de procuração eletrônica.
- TCU, AGU, CNJ e observatórios de CPSI.
