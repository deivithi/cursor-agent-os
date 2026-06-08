# 🔄 Matriz de Comparação — Frameworks de Agentes IA

> Use esta referência para escolher o framework certo para cada projeto.

---

## Comparação Detalhada

| Aspecto | **AgentScope** | **CrewAI** | **LangGraph** | **AutoGen** | **Google ADK** |
|---------|---------------|-----------|--------------|------------|---------------|
| **Organização** | Alibaba/Ant Group | CrewAI Inc | LangChain Inc | Microsoft | Google |
| **Licença** | Apache 2.0 | MIT | MIT | Apache 2.0 | Apache 2.0 |
| **Stars** | 18.4K | 25K+ | 15K+ | 40K+ | 10K+ |
| **Linguagem** | Python + Java | Python | Python | Python + .NET | Python |
| **Python mínimo** | 3.10 | 3.10 | 3.9 | 3.9 | 3.10 |
| **Paradigma** | ReAct (Reason+Act) | Crews + Roles | Graphs + Nodes | Event-driven | Agent ↔ Tool |
| **Multi-Agent** | MsgHub (flexível) | Crews (roles) | Graph nodes | Conversations | Sub-agents |
| **Observabilidade** | OpenTelemetry nativo | Básica | LangSmith | Básica | Cloud Trace |
| **MCP nativo** | ✅ Sim | ❌ Não | ⚠️ Via integração | ❌ Não | ✅ Sim |
| **A2A protocol** | ✅ Sim | ❌ Não | ❌ Não | ❌ Não | ✅ Sim |
| **Voice agents** | ✅ Sim | ❌ Não | ❌ Não | ❌ Não | ⚠️ Parcial |
| **Skills (SKILL.md)** | ✅ Nativo | ❌ Não | ❌ Não | ❌ Não | ✅ Nativo |
| **Deploy K8s** | ✅ Runtime nativo | ⚠️ Manual | ⚠️ LangServe | ⚠️ Manual | ✅ Cloud Run |
| **Studio/UI** | ✅ Studio visual | ⚠️ Enterprise | ✅ LangSmith | ✅ AutoGen Studio | ⚠️ Console |
| **Curva aprendizado** | Média | Baixa | Alta | Média | Média |

---

## Quando Usar Cada Um

### ✅ Use **AgentScope** quando:
- Precisa de observabilidade production-grade (OpenTelemetry)
- Quer MCP nativo sem wrappers
- Deploy em escala é requisito (K8s, serverless)
- Agentes com skills (SKILL.md) — conhecimento estruturado
- Multi-agent com orquestração flexível (MsgHub)
- Voice agents são requisito

### ✅ Use **CrewAI** quando:
- Prototipagem rápida (menor curva de aprendizado)
- Equipe pensa em "roles" e "crews" (metáfora natural)
- Não precisa de deploy complexo
- Time pequeno, iteração rápida

### ✅ Use **LangGraph** quando:
- Workflows complexos com branching e loops
- Já usa LangChain e quer aproveitar ecossistema
- Precisa de controle granular sobre o fluxo (graph-based)
- State machines são o modelo mental da equipe

### ✅ Use **AutoGen** quando:
- Cenários de debate/discussão entre agentes
- Conversas multi-agente com feedback iterativo
- Já usa ecossistema Microsoft
- No-code via AutoGen Studio é prioridade

### ✅ Use **Google ADK** quando:
- Deploy em Google Cloud é obrigatório
- Quer integração nativa com Vertex AI
- Projeto greenfield com stack Google

---

## Matriz de Decisão Rápida

```
Preciso de...
├── Protótipo rápido → CrewAI
├── Produção + observabilidade → AgentScope
├── Workflows complexos (graphs) → LangGraph
├── Debate multi-agente → AutoGen
├── Google Cloud nativo → Google ADK
├── MCP + A2A protocols → AgentScope ou Google ADK
├── Voice agents → AgentScope
├── SKILL.md nativo → AgentScope ou Google ADK
└── Menor curva de aprendizado → CrewAI
```
