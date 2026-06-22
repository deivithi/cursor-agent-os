# Catálogo Completo de Sinais — AI Forensic Analyzer v2

> **52 sinais em 7 categorias + 10 sinais de conteúdo humano**
> Cada sinal possui: ID, descrição, categoria, peso, confiança típica e exemplo

---

## CATEGORIA 1: ESTATÍSTICO (S01-S07)

Sinais baseados em propriedades quantitativas do texto: distribuições, diversidade, previsibilidade.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S01 | **Burstiness baixo** — Frases de comprimento uniforme, pouca variação no tamanho das sentenças | Alto | Alta | Todas as frases entre 15-22 palavras |
| S02 | **Perplexity artificialmente baixa** — Previsibilidade token-a-token acima do normal para texto humano | Alto | Média | Palavras seguintes são sempre as mais prováveis estatisticamente |
| S03 | **TTR baixo** — Type-Token Ratio anormalmente baixo (pouca diversidade lexical para o tamanho do texto) | Médio | Média | Palavras-chave repetidas em vez de sinônimos variados |
| S04 | **Distribuição gaussiana de sentenças** — Comprimentos de frase formam curva normal muito perfeita | Médio | Alta | Histograma de comprimentos parece sintético |
| S05 | **Repetição de n-gramas** — Bigramas ou trigramas idênticos aparecendo múltiplas vezes | Alto | Alta | "é importante notar que" aparece 3x |
| S06 | **Parágrafos uniformes** — Todos os parágrafos têm aproximadamente o mesmo número de sentenças | Médio | Alta | 5 parágrafos, cada um com exatamente 3-4 frases |
| S07 | **Baixa variação de pontuação** — Ausência de exclamações, interrogações, travessões, reticências | Baixo | Média | Só pontos finais e vírgulas |

---

## CATEGORIA 2: LINGUÍSTICO (S08-S14)

Sinais baseados em padrões sintáticos, escolhas lexicais e estruturas gramaticais.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S08 | **Conectivos LLM-típicos** — Uso excessivo de "No entanto", "Além disso", "É importante notar que", "Em conclusão" | Alto | Alta | "Além disso" aparece em 3 parágrafos consecutivos |
| S09 | **Baixa diversidade sintática** — Predominância de estrutura SVO (Sujeito-Verbo-Objeto) simples | Alto | Média | 80%+ das frases seguem o mesmo padrão sintático |
| S10 | **Ausência de subordinação complexa** — Poucas orações subordinadas, relativas ou reduzidas | Médio | Média | Texto parece uma sequência de afirmações simples |
| S11 | **Adjetivação genérica** — Uso de adjetivos previsíveis: "importante", "fundamental", "essencial", "significativo", "crucial" | Alto | Alta | "É fundamental que as empresas adotem uma abordagem..." |
| S12 | **Advérbios em posições fixas** — "extremamente", "profundamente", "consideravelmente" sempre antes de adjetivos | Baixo | Média | "extremamente importante", "profundamente significativo" |
| S13 | **Transições padronizadas** — Fórmulas de transição idênticas entre todos os parágrafos | Alto | Alta | "Além disso" → "Por outro lado" → "Em conclusão" |
| S14 | **Voz passiva analítica** — "é importante que", "deve ser considerado", "pode ser observado" | Médio | Alta | Construções passivas impessoais em excesso |

---

## CATEGORIA 3: ESTILOMÉTRICO (S15-S21)

Sinais baseados em estilo de escrita, voz autoral e escolhas estilísticas.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S15 | **Ausência de voz pessoal** — Sem 1ª pessoa, sem opiniões marcadas, sem tom pessoal | Alto | Alta | Texto inteiramente em 3ª pessoa impessoal |
| S16 | **Tom uniforme** — Sem variação emocional do início ao fim (monótono) | Médio | Alta | Mesmo nível de formalidade e entusiasmo em todo o texto |
| S17 | **Ausência de coloquialismos** — Sem expressões idiomáticas, gírias ou linguagem informal natural | Médio | Média | "Em face do exposto" em vez de "no fim das contas" |
| S18 | **Ausência de erros/hesitações** — Texto "limpo demais", sem revisões, correções ou marcas de processo | Baixo | Média | Zero erros de digitação em texto longo |
| S19 | **Adjetivação tripla** — Grupos de três adjetivos: "rápido, eficiente e inovador" | Médio | Alta | "estratégica, ética e sustentável" |
| S20 | **Metáforas genéricas** — "ponte entre", "chave para o sucesso", "luz no fim do túnel" | Médio | Alta | Metáforas que qualquer LLM conhece |
| S21 | **Nominalizações excessivas** — Verbos transformados em substantivos: "implementação" em vez de "implementar" | Baixo | Média | "a realização da análise" em vez de "analisar" |

---

## CATEGORIA 4: ESTRUTURAL (S22-S27)

Sinais baseados na macroestrutura do texto: organização, headings, formato.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S22 | **Template de introdução** — Contexto amplo → tema → objetivo (padrão essay clássico) | Alto | Alta | "No mundo atual... Neste contexto... Este artigo..." |
| S23 | **Conclusão formulaica** — "Em conclusão" / "Em suma" / "Por fim" + resumo genérico | Alto | Alta | Último parágrafo é um resumo do que já foi dito |
| S24 | **Estrutura 5-parágrafos** — Introdução, 3 argumentos, conclusão (redação ENEM / essay) | Alto | Alta | Exatamente 5 parágrafos simétricos |
| S25 | **Headings genéricos** — "Introdução", "Benefícios", "Desafios", "Conclusão" | Médio | Alta | Títulos de seção que poderiam estar em qualquer artigo |
| S26 | **Bullet points simétricos** — Listas com itens de comprimento uniforme e paralelismo sintático | Médio | Alta | Cada bullet tem exatamente 1-2 linhas com mesma estrutura |
| S27 | **Frase-tópico explícita** — Todo parágrafo começa com frase que anuncia o tema do parágrafo | Alto | Alta | "Outro aspecto importante é..." no início de cada parágrafo |

---

## CATEGORIA 5: ARTEFATOS DE LLM (S28-S35)

Sinais específicos de texto gerado por modelos de linguagem.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S28 | **Alucinações factuais** — Dados, datas, nomes ou referências incorretas ou inventadas | MUITO ALTO | Alta | Citação de estudo que não existe |
| S29 | **Placeholders genéricos** — "diversos estudos mostram", "especialistas afirmam", "pesquisas indicam" | Alto | Alta | Referências vagas sem fonte específica |
| S30 | **Auto-referências** — Texto comenta sobre si mesmo ou sobre seu próprio processo de escrita | Médio | Média | "Como mencionado anteriormente neste texto..." |
| S31 | **Citações vagas** — "Como disse Einstein..." sem citação específica verificável | Alto | Alta | Atribuição de citação genérica a figura famosa |
| S32 | **Frases de preenchimento** — "no mundo atual", "cada vez mais", "sem precedentes", "na era digital" | Alto | Alta | Clichês de abertura que não adicionam informação |
| S33 | **Enumerações artificiais** — "Primeiro... Segundo... Terceiro..." quando desnecessário | Médio | Alta | Enumeração forçada de argumentos |
| S34 | **Falsa neutralidade** — "Por um lado... por outro lado..." sem conclusão real | Médio | Alta | Equilíbrio artificial que não chega a lugar nenhum |
| S35 | **Disclaimers internos** — "É importante ressaltar que...", "Vale lembrar que...", "Cabe destacar que..." | Baixo | Média | Advertências desnecessárias dentro do texto |

---

## CATEGORIA 6: SEMÂNTICO (S36-S42)

Sinais baseados no significado, profundidade e originalidade do conteúdo.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S36 | **Generalidade extrema** — Texto se aplica a qualquer contexto, zero especificidade | Alto | Alta | "A tecnologia está transformando o mundo dos negócios" |
| S37 | **Ausência de exemplos concretos** — Sem dados numéricos, casos específicos, nomes, lugares | Alto | Alta | Fala de "empresas" mas não cita nenhuma |
| S38 | **Ausência de experiência pessoal** — Sem anedotas, casos vividos ou perspectivas únicas | Médio | Alta | Conteúdo puramente teórico/enciclopédico |
| S39 | **Circularidade argumentativa** — Diz a mesma coisa de 3 formas diferentes sem avançar | Alto | Alta | Parágrafos 2, 3 e 4 dizem essencialmente o mesmo |
| S40 | **Profundidade rasa** — Não vai além do senso comum; conhecimento que qualquer um teria | Alto | Média | Afirmações que não requerem expertise |
| S41 | **Ausência de controvérsia** — Posições muito seguras, moderadas, sem tomar partido | Médio | Alta | "Ambos os lados têm méritos" sem se posicionar |
| S42 | **Conhecimento enciclopédico** — Informação correta mas genérica, sem insight original | Alto | Alta | Parece verbete de Wikipédia |

---

## CATEGORIA 7: MULTIMODAL (S43-S47)

Sinais baseados em propriedades técnicas de imagens, áudio e outros formatos.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S43 | **Metadados inconsistentes** — EXIF/XMP contradiz origem declarada da imagem | MUITO ALTO | Alta | "Criado com iPhone" mas metadados mostram software de geração |
| S44 | **ELA anômalo** — Error Level Analysis com padrões de GAN/diffusion model | Alto | Média | Bordas de objetos com níveis de erro artificiais |
| S45 | **Ruído artificialmente uniforme** — Padrão de noise típico de AI upscaling ou geração | Alto | Média | Ausência de ruído de sensor fotográfico real |
| S46 | **Compressão inconsistente** — Artefatos de compressão diferentes entre regiões (composição) | Alto | Média | Fundo tem compressão diferente do objeto principal |
| S47 | **Marca d'água digital** — SynthID detectado ou C2PA ausente quando esperado | MUITO ALTO | Alta | Metadados de proveniência faltando |

---

## CATEGORIA 8: CÓDIGO (S48-S52)

Sinais específicos de código-fonte gerado por IA.

| ID | Sinal | Peso | Confiança | Exemplo |
|----|-------|------|-----------|---------|
| S48 | **Comentários didáticos** — Comentários excessivamente explicativos e genéricos | Alto | Alta | `# First, we import the necessary libraries` |
| S49 | **Variáveis genéricas** — Nomes previsíveis: `data`, `result`, `temp`, `item`, `value` | Médio | Média | Ausência de nomes específicos do domínio |
| S50 | **Estrutura linear** — Funções excessivamente lineares, sem otimizações ou edge cases | Médio | Média | Código "de livro-texto" sem adaptações práticas |
| S51 | **Ausência de edge-case handling** — Sem tratamento de erros específico ao contexto real | Médio | Média | Happy path apenas, sem `try/except` contextual |
| S52 | **Padrões de design genéricos** — Uso de patterns "de livro" sem adaptação ao problema real | Alto | Alta | Singleton onde não faz sentido, Factory sem necessidade |

---

## SINAIS A FAVOR DE CONTEÚDO HUMANO (H01-H10)

Evidências de que o conteúdo foi produzido por um humano.

| ID | Sinal | Peso | Exemplo |
|----|-------|------|---------|
| H01 | **Voz pessoal marcante** — 1ª pessoa, opiniões fortes, tom autoral distinto | Alto | "Na minha experiência como..." |
| H02 | **Erros naturais** — Typos, hesitações, correções mid-sentence características de digitação humana | Alto | "na verdade, quer dizer, deixando mais claro..." |
| H03 | **Referências culturais específicas** — Citações contextualizadas, memes, eventos atuais com data | Alto | Referência a evento específico de 2024 |
| H04 | **Exemplos concretos** — Dados numéricos, nomes, lugares, casos específicos e verificáveis | Alto | "Na empresa X, em março de 2025, observamos..." |
| H05 | **Estrutura não-linear** — Fora do template essay; organização criativa ou idiossincrática | Alto | Texto começa com conclusão ou anedota |
| H06 | **Gírias e regionalismos** — Uso autêntico de linguagem de nicho, gíria local ou jargão profissional real | Alto | "Aí o cara meteu o louco e..." |
| H07 | **Metáforas originais** — Imagens mentais inesperadas e criativas, não-clichê | Alto | Metáfora que você nunca leu antes |
| H08 | **Progressão com reviravoltas** — Mudanças de tom, opinião ou direção no meio do texto | Médio | Começa defendendo A, termina questionando A |
| H09 | **Inconsistências naturais** — Variações estilísticas que parecem humanas, não forçadas | Médio | Parágrafo formal seguido de parágrafo casual |
| H10 | **Dados verificáveis** — Informações factuais corretas com fontes específicas e rastreáveis | Alto | "Segundo o relatório anual da empresa X (2025, p. 42)..." |
