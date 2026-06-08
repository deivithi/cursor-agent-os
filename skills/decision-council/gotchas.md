# ⚠️ Gotchas — Decision Council

## G1: Self-Preference Bias (mono-modelo)

**Problema:** Todas as perspectivas rodam no mesmo modelo (Claude). O paper arxiv:2404.13076 mostra que LLMs têm viés a favor dos próprios outputs.

**Mitigação:** Persona Effect (arxiv:2410.21819) reduz mode collapse em 2-3x. Não elimina 100% do viés, mas o custo-benefício vs multi-model é muito superior.

**Quando escalar:** Se a decisão tem impacto > $10K ou é irreversível, considerar segunda opinião humana ou em outro modelo (ChatGPT, Gemini) — fora do ecossistema.

## G2: Falsa convergência

**Problema:** 5 dimensões concordam com confiança 0.95, mas todas compartilham o mesmo blind spot.

**Mitigação:** Verificar se há dimensão ausente que deveria estar na análise. Se o usuário mencionar algo que nenhuma dimensão cobriu → adicionar dimensão ad-hoc.

## G3: Paralysis by Analysis

**Problema:** Council com confiança < 0.50 pode gerar indecisão no usuário.

**Mitigação:** Quando confiança é baixa, o veredicto deve ser explícito: "A decisão depende de [fator X] que precisa de validação externa." Não deixar o usuário sem direção.

## G4: Dimensões demais = ruído

**Problema:** Mais de 5 dimensões diluem a análise e aumentam custo sem ganho proporcional.

**Mitigação:** Hard limit de 5 dimensões. Se domínio sugere mais, priorizar as mais impactantes para o contexto específico.

## G5: Council para decisões triviais

**Problema:** Usar Council para "qual nome de variável?" é desperdício de tokens.

**Mitigação:** Trigger phrases são manuais. Se detectar decisão trivial (< 2 opções, impacto mínimo), sugerir resposta direta em vez de ativar Council.

## G6: Conflito com skills existentes

**Problema:** Usuário diz "stress test" referindo-se a teste de carga (performance testing), não deliberação.

**Mitigação:** Verificar contexto. Se o input menciona código, endpoints, ou métricas de performance → NÃO ativar Council, direcionar para testing skills. Council só ativa para DECISÕES, não para TESTES.
