# Do — Executor Orquestrado com Subagentes

Execute a tarefa com máxima qualidade: **$ARGUMENTS**

## Princípio Core

> Você é um **ORQUESTRADOR**. Use subagentes (Agent tool) para executar o trabalho pesado.
> Mantenha o contexto principal limpo. Uma tarefa por subagente.

## Protocolo de Execução

### 0. TaskEnvelope (execução multi-passo)

Para tarefas com **≥3 passos** ou múltiplos artefatos:

- Preencha o JSON descrito em [`.claude/references/task-envelope.md`](../references/task-envelope.md) **ou**
- Confirme que `tasks/todo.md` já contém itens **checkáveis** que cobrem `acceptance_criteria` equivalentes (um critério → um item ou subitem verificável).

Toda execução multi-passo deve deixar **rastro** em `tasks/todo.md` (estado por item: pendente / feito) até concluir ou handoff explícito.

### 1. Verificação Pré-Execução

Antes de executar qualquer coisa:

- Verifique se existe um plano em `tasks/todo.md` — se sim, siga-o
- Se não há plano e a tarefa tem 3+ passos, crie um primeiro (use /make-plan)
- Leia os arquivos de memória relevantes para contexto
- Confirme que entendeu o objetivo
- Aplique [`.claude/references/performance-context-policy.md`](../references/performance-context-policy.md) (paralelizar independentes, não inundar o chat com logs completos)

### 2. Orquestração com Subagentes

Para cada fase ou tarefa independente:

```
Subagente de Pesquisa → Subagente de Implementação → Subagente de Verificação
```

**Regras de subagentes:**
- 1 objetivo claro por subagente
- Contexto suficiente no prompt (não assuma que o subagente sabe)
- Paralelize subagentes independentes
- Aguarde resultado antes de avançar para fase dependente

### 3. Implementação (com Diamond Gates para fluxos críticos)

Para cada passo:

1. **Execute** — Implemente a mudança
2. **Verifique** — Teste/valide que funciona
3. **Registre** — Atualize `tasks/todo.md` marcando como concluído

#### ◆ Diamond Gates — Aprovação Obrigatória do Usuário

Em fluxos com **impacto irreversível, financeiro, externo ou de compliance**, inserir Diamond Gates entre etapas críticas:

```
Após completar etapa crítica → PARAR e apresentar:
  1. Resumo do que foi feito
  2. Artefatos produzidos
  3. Riscos identificados
  4. ◆ "Aprovado para prosseguir para [próxima etapa]?"
```

**Quando usar Diamond Gates (OBRIGATÓRIO):**
- Deploy em produção (Salesforce, APIs, infra, Vercel/Render/Cloudflare em ambiente real)
- Modificação de regras financeiras (comissões, pricing, pagamentos)
- **Email em massa** ou sequências para listas (mesmo BCC); **qualquer envio** para clientes externos sem revisão humana
- **Calendário:** convites que comprometem terceiros ou reuniões com dados sensíveis em descrição
- Integrações **Salesforce / CRM** que alteram dados de leads, oportunidades ou permissões em org partilhada
- Ações visíveis a terceiros (emails, notificações, posts, comentários públicos em PR/Issues corporativas)
- Alteração de fluxos de automação ativos (n8n, Flow, webhooks produtivos)
- Tratamento de dados pessoais (LGPD): export, merge, delete, ou cópia para fora do perímetro aprovado
- **MCP / CLI com conta real** (Gmail, Drive, Stripe, etc.) quando a ação não for estritamente read-only acordada
- Qualquer ação difícil de reverter ou com impacto financeiro/regulatório

**Quando NÃO usar (seguir direto):**
- Mudanças locais reversíveis (código, documentação)
- Exploração e pesquisa (read-only)
- Tarefas em sandbox/ambiente de teste

> O agente **NÃO pode auto-aprovar** Diamond Gates — somente o humano aprova.
> Se o usuário negar → voltar à etapa, corrigir, apresentar novamente.

### 4. Verificação Pós-Execução

Após completar TODAS as fases:

```
[ ] Código compila/builda sem erros?
[ ] Testes passam (se aplicável)?
[ ] Lógica é coerente de ponta a ponta?
[ ] Não há referências quebradas?
[ ] Nenhum arquivo sensível foi exposto?
[ ] A entrega atende 100% dos requisitos?
```

### 5. Relatório

Apresente:

```markdown
## Execução Completa

### O que foi feito
- [lista de mudanças com arquivo:linha]

### Arquivos modificados
- [lista]

### Verificações realizadas
- [o que foi testado e resultado]

### Próximos passos (se houver)
- [ações pendentes]
```

## Anti-patterns (PROIBIDO)

- Executar sem entender o objetivo
- Modificar arquivos sem ler primeiro
- Pular verificação
- Entregar algo quebrado
- Fazer mais do que foi pedido

## Atualização de Lições

Se algo inesperado acontecer durante a execução, registre em `tasks/lessons.md`:

```markdown
### [Data] — Lição aprendida
**Contexto:** o que aconteceu
**Causa:** por que aconteceu
**Regra:** como evitar no futuro
```
