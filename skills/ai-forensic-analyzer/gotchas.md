# ⚠️ Gotchas — AI Forensic Analyzer v2

> Problemas conhecidos encontrados durante o uso desta skill. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## G01: Textos curtos produzem falsos positivos em massa

- **Sintoma:** Textos de 1-3 frases (< 100 palavras) recebem veredito "IA" com confiança injustificada.
- **Causa raiz:** Sinais estatísticos (burstiness, TTR) precisam de volume mínimo de dados. Com poucas sentenças, a variância é zero ou artefatual.
- **Solução:** A skill reduz automaticamente a confiança para no máximo "Baixa" em textos < 100 palavras. Se isso não estiver acontecendo, verifique se `tamanho_total_palavras` está sendo injetado nas métricas de pré-processamento.
- **Prevenção:** SEMPRE execute `text_stats.py` antes e injete as métricas no prompt. O system prompt (Regra 5) força "Incerto" sem sinais fortes.
- **Descoberto em:** 2026-06-18 (design review)

---

## G02: Viés contra não-nativos de inglês (61.3% FP)

- **Sintoma:** Textos em inglês escritos por autores não-nativos são sistematicamente classificados como IA.
- **Causa raiz:** Vocabulário limitado, estruturas sintáticas simples e uso de conectivos formais (aprendidos em aula) são idênticos aos padrões que a skill busca como sinais de IA.
- **Solução:** A skill inclui `bias_warnings` no output quando detecta possíveis fatores de risco. Se o contexto do autor for conhecido como não-nativo, preencha o campo "Contexto adicional" no user prompt com esta informação.
- **Prevenção:** Para conteúdos em inglês com potencial autor não-nativo, reduza manualmente a confiança em 1 nível e NUNCA use o resultado como prova única.
- **Descoberto em:** 2026-06-18 (Liang et al., Stanford 2023)

---

## G03: Conteúdo técnico/científico confundido com IA

- **Sintoma:** Artigos acadêmicos, documentação técnica e white papers recebem veredito "IA" com alta confiança.
- **Causa raiz:** Textos técnicos são naturalmente formais, estruturados e com vocabulário controlado — exatamente os padrões que os sinais S08-S14 (linguísticos) e S22-S27 (estruturais) buscam.
- **Solução:** Use o campo "Contexto adicional" para indicar que o texto é técnico/científico. O system prompt (Diretrizes Anti-Viés) instrui a não confundir formalidade com IA, mas isso é um lembrete — o modelo ainda pode errar.
- **Prevenção:** Para textos técnicos, dê mais peso aos sinais semânticos (S36-S42: originalidade, profundidade) e artefatos LLM (S28-S35: alucinações) do que aos estruturais.
- **Descoberto em:** 2026-06-18 (design review)

---

## G04: Paráfrase derruba a detecção (91% → 28%)

- **Sintoma:** Texto originalmente gerado por IA, depois parafraseado (via QuillBot, Undetectable.ai ou outro LLM), é classificado como "Humano".
- **Causa raiz:** A paráfrase remove os padrões de superfície (conectivos, estrutura de sentença) que a skill detecta. O texto mantém o conteúdo de IA mas com "roupagem" humana.
- **Solução:** Ative o modo `deep` (analisa sinais de anti-evasão). Procure por: erros artificiais, variação forçada de conectivos, inconsistência de registro. Se `sinais_anti_evasao` não estiver vazio, TRATE o veredito "Humano" com ceticismo.
- **Prevenção:** A análise de anti-evasão é um sinal, não uma prova. Se houver suspeita forte de paráfrase, o veredito deve ser "Incerto".
- **Descoberto em:** 2026-06-18 (Taloni et al., Eye Journal 2023)

---

## G05: Mistura IA + edição humana é quase indetectável

- **Sintoma:** Texto gerado por IA e depois editado por humano (prática comum) produz scores ambíguos e vereditos inconsistentes.
- **Causa raiz:** A edição humana introduz alguns sinais humanos (voz pessoal, erros, especificidade) enquanto mantém a base estrutural da IA. Os scores se anulam.
- **Solução:** O campo `contra_evidencias` no output captura exatamente isso — pares de evidências que se contradizem. Se houver múltiplas contra-evidências, o veredito apropriado é "Misto" ou "Incerto".
- **Prevenção:** Aceite que este é o caso mais difícil. A skill não foi projetada para resolver isso — foi projetada para ser HONESTA sobre a incerteza.
- **Descoberto em:** 2026-06-18 (design review)

---

## G06: Imagens com compressão pesada produzem ELA falso positivo

- **Sintoma:** Fotos reais (ex: JPEG de WhatsApp) são flagradas como "possível IA" na ELA.
- **Causa raiz:** Compressão JPEG agressiva (qualidade < 70) achata as diferenças de erro entre regiões, fazendo a imagem inteira parecer "uniforme" como uma imagem sintética.
- **Solução:** Verifique os metadados primeiro. Uma imagem com EXIF de câmera real + ELA anômalo provavelmente é real com compressão pesada, não IA. O sinal S43 (metadados) tem peso MUITO ALTO e deve dominar sobre S44 (ELA).
- **Prevenção:** Para imagens de origem desconhecida com compressão visível, reduza o peso do ELA em 50%.
- **Descoberto em:** 2026-06-18 (design review)

---

## G07: Pillow não instalado → image_forensics.py retorna só metadados básicos

- **Sintoma:** `image_forensics.py` produz output com `"available": false` e warning de instalação.
- **Causa raiz:** O script depende de Pillow + numpy para EXIF, ELA e noise analysis.
- **Solução:** Instale as dependências: `pip install Pillow numpy`
- **Prevenção:** Verifique a instalação antes de processar imagens: `python -c "from PIL import Image; print('OK')"`
- **Descoberto em:** 2026-06-18 (design)

---

## G08: Código boilerplate parece IA

- **Sintoma:** Código altamente padronizado (ex: CRUD, configuração de framework, testes unitários genéricos) é classificado como IA.
- **Causa raiz:** Código boilerplate é, por definição, repetitivo e previsível — exatamente o que os sinais S48-S52 detectam. Mas também é como humanos escrevem código padronizado.
- **Solução:** Para código, o sinal mais forte de IA é S28 (alucinações factuais em comentários) e S48 (comentários excessivamente didáticos). Se o código for funcionalmente correto mas genérico, provavelmente é boilerplate humano, não IA.
- **Prevenção:** Use o campo "Contexto adicional" para indicar se é código boilerplate/CRUD ou algoritmo original.
- **Descoberto em:** 2026-06-18 (design review)

---

## G09: Poesia e creative writing geram falsos positivos

- **Sintoma:** Textos criativos (poesia, ficção, prosa literária) são incorretamente classificados como IA.
- **Causa raiz:** A skill foi calibrada para texto expositivo/argumentativo. Textos criativos têm padrões estatísticos diferentes que podem acionar sinais falsamente.
- **Solução:** A skill reduz automaticamente a confiança em 1 nível para conteúdo criativo (Diretrizes Anti-Viés). Para poesia, trate o resultado como "Triagem apenas".
- **Prevenção:** SEMPRE indique no "Contexto adicional" se o texto é criativo/literário.
- **Descoberto em:** 2026-06-18 (design review)

---

## G10: Conteúdo traduzido

- **Sintoma:** Texto traduzido de outro idioma (especialmente via tradução automática) é classificado como IA.
- **Causa raiz:** Tradução automática introduz padrões similares aos de LLMs: vocabulário simplificado, estruturas regulares, perda de nuance.
- **Solução:** A skill inclui `bias_warnings` com `tipo: translated_content`. Se souber que o texto é tradução, indique no "Contexto adicional".
- **Prevenção:** Para texto traduzido, reduza confiança em 1 nível e dê mais peso a sinais semânticos (conteúdo) do que linguísticos (forma).
- **Descoberto em:** 2026-06-18 (design review)

---

## G11: Batch analyzer sem workers suficientes

- **Sintoma:** `batch_analyzer.py` trava ou fica extremamente lento com diretórios grandes.
- **Causa raiz:** Cada arquivo dispara `text_stats.py` ou `image_forensics.py` como subprocesso. Com muitos arquivos e poucos workers, a fila congestiona.
- **Solução:** Aumente `--workers`: para SSDs, 8-16 workers; para HDDs, 4-8. Evite processar mais de 100 arquivos de uma vez sem `--output`.
- **Prevenção:** Divida diretórios grandes em lotes menores usando `--type` para filtrar.
- **Descoberto em:** 2026-06-18 (design)

---

## G12: Encoding errors em arquivos não-UTF-8

- **Sintoma:** `text_stats.py` ou `batch_analyzer.py` falham com `UnicodeDecodeError` em alguns arquivos.
- **Causa raiz:** Arquivos em Latin-1, Windows-1252 ou outras codificações.
- **Solução:** O script usa `errors="replace"`, mas se falhar mesmo assim, converta o arquivo para UTF-8 antes: `iconv -f ISO-8859-1 -t UTF-8 arquivo.txt > arquivo_utf8.txt`
- **Prevenção:** Verifique a codificação antes: `file -bi arquivo.txt` (Linux) ou `python -c "import chardet; print(chardet.detect(open('arquivo.txt','rb').read()))"`
- **Descoberto em:** 2026-06-18 (design)

---

## G13: Modelo LLM ignorando o JSON schema

- **Sintoma:** O LLM retorna texto fora do JSON, quebra o schema com campos faltantes ou adiciona texto antes/depois do JSON.
- **Causa raiz:** Modelos menores ou menos capazes podem ignorar a instrução "Responda EXCLUSIVAMENTE com JSON". Temperature > 0.3 aumenta o risco.
- **Solução:** Use temperature ≤ 0.2. Adicione `response_format: { "type": "json_object" }` via API quando disponível. Se persistir, faça parse manual do output com regex para extrair o JSON.
- **Prevenção:** Teste o modelo alvo com um texto curto antes de processamento em lote.
- **Descoberto em:** 2026-06-18 (design)

---

## G14: GPU/TPU artifacts em ELA

- **Sintoma:** Imagens geradas por IA muito recentes (modelos de 2025-2026) não são detectadas pela ELA.
- **Causa raiz:** Modelos mais novos (Flux, Stable Diffusion 3.5, Midjourney v7) produzem imagens com padrões de compressão mais naturais. A ELA é uma técnica de 2007 — modelos modernos evoluíram.
- **Solução:** Confie mais em metadados (S43) e marcas d'água digitais (S47) do que em ELA (S44) para modelos recentes. A ELA é eficaz para modelos 2022-2024.
- **Prevenção:** Mantenha-se atualizado sobre novas técnicas de detecção. Este gotcha deve ser revisitado a cada 6 meses.
- **Descoberto em:** 2026-06-18 (design prospectivo)

---

## Resolvidos

_Nenhum gotcha resolvido permanentemente ainda. Esta skill está na versão inicial (v2.0)._
