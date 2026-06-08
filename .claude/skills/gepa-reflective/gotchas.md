# ⚠️ Gotchas — GEPA Reflective Evolution

---

## 1. Qualidade da reflexão depende da completude do trace

- **Sintoma:** Diagnósticos vagos tipo "algo deu errado" ou "precisa melhorar" sem causa específica
- **Causa raiz:** A fase Execute não capturou logs intermediários, apenas o score final. Sem trace rico, a fase Plan não tem matéria-prima para diagnóstico causal
- **Solução:** Garantir que o trace inclua: stdout/stderr completo, git diff da mudança, scores **por item** (não só total), timestamps e qualquer warning intermediário
- **Prevenção:** Antes de rodar o experimento, validar que o mecanismo de logging está ativo. Criar template de trace com campos obrigatórios
- **Descoberto em:** 2026-03-22

---

## 2. LLM pode alucinar diagnóstico — verificar contra dados reais

- **Sintoma:** Diagnóstico parece plausível e bem escrito, mas a causa raiz apontada não existe no trace. O LLM "inventou" uma explicação coerente que não corresponde à realidade
- **Causa raiz:** LLMs são treinados para gerar texto plausível, não necessariamente verdadeiro. Sem grounding explícito, o modelo preenche lacunas com inferências que parecem lógicas
- **Solução:** Cada afirmação no diagnóstico DEVE citar a linha específica do trace que a sustenta. Sem citação = rotular como `[Inferência]`. Na dúvida, re-executar o experimento com logging mais detalhado
- **Prevenção:** Adicionar no prompt de reflexão: "Cite a evidência do trace para cada afirmação. Se não houver evidência, marque como [Inferência]"
- **Descoberto em:** 2026-03-22

---

## 3. Time budget — reflexão deve ser < 20% do tempo do experimento

- **Sintoma:** O agente gasta mais tempo analisando por que falhou do que tentando a próxima solução. O loop fica lento e o throughput de iterações cai drasticamente
- **Causa raiz:** A fase Plan não tem time-box definido. O LLM pode gerar análises extensas e detalhadas que, embora interessantes, não justificam o custo de tempo
- **Solução:** Definir time-box explícito: se o experimento levou 10 minutos, a reflexão tem no máximo 2 minutos. Se não chegou a um diagnóstico no tempo, usar heurística simples (ex: classificar como Tipo 1 e mudar abordagem)
- **Prevenção:** Configurar timer na fase Plan. Após timeout, forçar saída com diagnóstico parcial ou heurístico
- **Descoberto em:** 2026-03-22

---

## 4. Armadilha da meta-otimização — otimizar o otimizador infinitamente

- **Sintoma:** Em vez de otimizar a skill-alvo, o agente começa a otimizar o próprio processo GEPA. Reflexões sobre reflexões, ajustes no formato do diagnóstico, refinamento da taxonomia de falhas — tudo isso sem melhorar o score real
- **Causa raiz:** O GEPA é recursivo por natureza: ele pode se aplicar a si mesmo. Sem guarda explícita, o agente pode entrar num loop de auto-referência
- **Solução:** Regra hard-coded: o objeto de otimização é **sempre** a skill-alvo, nunca o processo GEPA em si. Se o agente começar a sugerir mudanças no próprio protocolo GEPA, interromper e redirecionar para a skill
- **Prevenção:** No prompt do agente, incluir: "Você está otimizando [skill X]. O processo GEPA é fixo e não deve ser modificado durante a execução"
- **Descoberto em:** 2026-03-22

---

## 5. Diagnóstico correto mas correção impossível no escopo atual

- **Sintoma:** A fase Plan identifica corretamente a causa raiz (ex: "o eval script não suporta frontmatter com campos custom"), mas a correção exigiria mudar o eval script, que está fora do escopo do agente
- **Causa raiz:** Nem toda causa raiz está dentro do blast radius permitido. O agente tem controle sobre a skill, não sobre a infraestrutura de avaliação
- **Solução:** Classificar como Tipo 3 (limitação estrutural). Registrar a limitação no gotchas.md da skill-alvo e pivotar para outro ângulo de melhoria
- **Prevenção:** Na fase Plan, após identificar causa raiz, verificar: "Isto está dentro do meu blast radius?" Se não → Tipo 3 imediato, sem tentar workaround
- **Descoberto em:** 2026-03-22

---
