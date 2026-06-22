---
name: ai-forensic-analyzer
description: >
  Análise forense multi-modal de conteúdo (texto, imagem, áudio, código) para
  detectar geração por IA. Taxonomia de 52 sinais em 7 categorias, calibração
  de confiança com bias-awareness, detecção de anti-evasão, output JSON
  estruturado. Baseado em DetectGPT (Stanford/ICML 2023), watermarking
  (Kirchenbauer et al.), benchmarks Weber-Wulff e Stanford HAI.
  Ativa com: detector de IA, verificar se foi escrito por IA, análise forense
  de texto, deepfake, ChatGPT detector, conteúdo gerado por IA, AI detection,
  forensic analyzer, verificar autenticidade, texto suspeito.
allowed-tools: Bash, Read, Glob, Grep, Write
metadata:
  author: deivithi
  version: "2.0"
  domain: ai-forensics
  subdomain: content-analysis
  license: Apache-2.0
tags:
  - ai-detection
  - forensics
  - content-analysis
  - deepfake-detection
  - llm-detection
  - multimodal
  - detectgpt
  - text-analysis
  - image-forensics
  - anti-evasion
---

# AI Forensic Analyzer v2 — Análise Forense Multi-Modal de Conteúdo IA

> **"Não afirme o que não pode provar. Cada evidência é rastreável ou não existe."**

Análise forense de conteúdo para determinar se foi gerado por IA (texto, imagem, áudio, código).
Baseado em pesquisa acadêmica de ponta (DetectGPT/Stanford, watermarking/Kirchenbauer, benchmarks Weber-Wulff)
e calibrado para minimizar falsos positivos — especialmente em populações vulneráveis a viés (não-nativos, neurodivergentes).

## Estrutura de Arquivos

| Arquivo | Conteúdo |
|---------|----------|
| `SKILL.md` | Você está aqui. Metodologia completa. |
| `gotchas.md` | ⚠️ Armadilhas e problemas conhecidos. |
| `prompts/system-v2.txt` | System prompt do analista forense (9 regras + 52 sinais). |
| `prompts/user-*.txt` | Templates por tipo de conteúdo (texto/imagem/código/áudio/misto). |
| `schemas/output-v2.json` | JSON Schema completo do output. |
| `scripts/text_stats.py` | Pré-processamento: burstiness, TTR, densidade de conectivos. |
| `scripts/image_forensics.py` | Pré-processamento: EXIF, ELA, noise patterns. |
| `scripts/batch_analyzer.py` | Processamento em lote com subagentes. |
| `references/` | Resumos dos papers e benchmarks de referência. |

## Skills Relacionadas

| Skill | Relação |
|-------|---------|
| `/cyber` | Router para 736 skills de cybersecurity. Use para deepfake avançado, steganografia, etc. |
| `security-audit` | Metodologia de auditoria Trail of Bits. Use se a análise revelar código suspeito que precisa de auditoria estrutural. |
| `mythos` | Caça autônoma de vulnerabilidades. Use para análise profunda de código potencialmente malicioso. |
| `doc-extract` | Extração de texto de documentos (PDF, DOCX). Use ANTES desta skill se o conteúdo vier em documento. |
| `guardrails` | Sanitização de input/output. Use se o conteúdo analisado contiver dados sensíveis. |
| `batch-processing` | Processamento paralelo. Use para analisar grandes volumes de conteúdo. |

---

## Quando Usar

| Cenário | Use `ai-forensic-analyzer` | Observação |
|---------|---------------------------|------------|
| Verificar se um texto foi escrito por IA (ChatGPT, Claude, etc.) | ✅ | Modo padrão |
| Analisar imagem suspeita de ser gerada por IA (Midjourney, DALL-E) | ✅ | Requer `image_forensics.py` |
| Verificar se código-fonte foi gerado por IA | ✅ | Modo código |
| Analisar áudio suspeito de voice cloning | ✅ | Modo áudio (via transcrição + metadados) |
| Verificar conteúdo misto (texto + imagens) | ✅ | Modo multi |
| Auditoria de conteúdo para compliance acadêmico/editorial | ✅ | Use modo `deep` |
| Triagem de submissões em larga escala | ✅ | Use `batch_analyzer.py` + modo `quick` |
| Conteúdo "humanizado" artificialmente (suspeita de evasão) | ✅ | Ativa análise de anti-evasão |

## Quando NÃO Usar (→ Handoff)

| Cenário | Use em vez disso | Razão |
|---------|-----------------|-------|
| Investigação criminal que exija cadeia de custódia | `/cyber` → digital-forensics | Esta skill é análise de conteúdo, não forense digital legal |
| Deepfake de vídeo com análise frame-a-frame | `/cyber` → deepfake-detection | Esta skill cobre imagem estática, não vídeo |
| Análise de malware em binário | `/cyber` → malware-analysis | Esta skill analisa código-fonte, não binários |
| Extrair texto de PDF/DOCX antes de analisar | `doc-extract` | Execute `doc-extract` primeiro, depois esta skill |
| Conteúdo com dados sensíveis (PII, credenciais) | `guardrails` → depois esta skill | Sanitize antes de enviar para análise |

---

## Workflow

### 1. Pré-processamento (opcional mas recomendado)

Execute os scripts de pré-processamento ANTES de chamar o LLM:

```
python scripts/text_stats.py --input "texto para analisar" --output metrics.json
python scripts/image_forensics.py --input foto.jpg --output metrics.json
```

As métricas são injetadas no prompt do usuário, melhorando a precisão da análise com dados quantitativos.

### 2. Seleção de Modo

| Modo | Sinais analisados | Profundidade | Quando usar |
|------|-------------------|-------------|-------------|
| `quick` | Top 15 sinais (maior peso) | Superficial | Triagem em massa, primeira passagem |
| `standard` | Todos os 52 sinais | Padrão | Análise normal (recomendado) |
| `deep` | 52 sinais + anti-evasão + contra-evidências | Completa | Auditoria, decisões importantes |

### 3. Chamada ao LLM

Monte o prompt combinando `system-v2.txt` + template do tipo de conteúdo:

**Exemplo (texto, modo standard):**
```
[system-v2.txt]
[user-text.txt com parâmetros: tipo=Texto, modo=standard, conteúdo=...]
```

**Via OpenClaw:**
```json
{
  "skill": "ai-forensic-analyzer",
  "mode": "standard",
  "content_type": "Texto",
  "content": "texto para analisar...",
  "context": "Post de LinkedIn sobre IA",
  "preprocessing_metrics": { ... }
}
```

**Via Cursor/Claude Code:**
Carregue a skill e cole system prompt + user template com `response_format: json`.

### 4. Interpretação do Output

O JSON de saída segue o schema `schemas/output-v2.json`. Pontos críticos:

- **`bias_warnings`**: Leia SEMPRE. Se houver `risco_falso_positivo: Alto`, o resultado NÃO deve ser usado como prova.
- **`nivel_admissibilidade`**: "Triagem apenas" → NÃO use para decisões finais. "Inconclusivo" → revisão humana obrigatória.
- **`sinais_anti_evasao`**: Se presente, o conteúdo pode ter sido modificado para enganar detectores.

### 5. Ação Pós-Análise

| Veredito | Ação recomendada |
|----------|-----------------|
| IA + Alta confiança | Conteúdo muito provavelmente gerado por IA |
| IA + Média confiança | Investigar mais; pode ser falso positivo |
| Humano + Alta confiança | Conteúdo muito provavelmente humano |
| Misto | Separar partes IA das partes humanas |
| Incerto | NÃO usar este resultado; requer outros métodos |

---

## Matriz de Sinais (Resumo)

A taxonomia completa está em `references/signal-taxonomy.md`. Aqui as 7 categorias:

| Categoria | Sinais | Peso médio |
|-----------|--------|------------|
| Estatístico (S01-S07) | Burstiness, TTR, perplexity, distribuição de sentenças | Alto |
| Linguístico (S08-S14) | Conectivos LLM, diversidade sintática, adjetivação | Alto |
| Estilométrico (S15-S21) | Voz pessoal, tom, metáforas, nominalizações | Médio |
| Estrutural (S22-S27) | Template essay, headings, listas simétricas | Alto |
| Artefatos LLM (S28-S35) | Alucinações, placeholders, citações vagas | MUITO ALTO |
| Semântico (S36-S42) | Genericidade, profundidade, originalidade | Alto |
| Multimodal (S43-S47) | Metadados, ELA, noise, SynthID | MUITO ALTO |
| Código (S48-S52) | Comentários didáticos, variáveis genéricas, edge cases | Alto |
| **HUMANO (H01-H10)** | Voz pessoal, erros naturais, especificidade, criatividade | Alto |

---

## Calibração de Confiança e Bias Awareness

### Fatores de Risco de Falso Positivo

| Fator | Risco | Ação |
|--------|-------|------|
| Autor potencialmente não-nativo de inglês | **~61% FP** (Liang et al., Stanford 2023) | Reduzir confiança em 1 nível |
| Estudante negro (contexto acadêmico) | **20% FP** (Common Sense Media 2024) | Reduzir confiança em 1 nível |
| Conteúdo técnico/científico | Formalidade confundida com IA | Reduzir confiança em 1 nível |
| Texto < 100 palavras | Dados insuficientes | Máximo "Média" confiança |
| Conteúdo criativo (poesia, ficção) | Padrões criativos ≠ padrões IA | Reduzir confiança em 1 nível |
| Conteúdo traduzido | Artefatos de tradução ≠ IA | Reduzir confiança em 1 nível |
| Neurodivergência do autor | Padrão documentado de FP | Reduzir confiança em 1 nível |

### Regra de Ouro

> **NUNCA use o resultado desta skill como prova única para decisões irreversíveis.**
> Isso inclui: reprovação acadêmica, demissão, acusação de plágio, decisão judicial.
> O resultado é uma ferramenta de TRIAGEM que requer verificação humana.

---

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Modo `quick`. Analisa 15 sinais principais. Ideal para triagem. |
| **Médio** | Modo `standard`. Analisa todos os 52 sinais. Recomendado para maioria dos casos. |
| **Complexo** | Modo `deep`. Análise completa + anti-evasão + contra-evidências. Use `batch_analyzer.py` para volumes grandes. Sugere decomposição por tipo de conteúdo. |

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Imagem com suspeita de deepfake avançado | `/cyber` (digital image forensics) | ELA e noise analysis inconclusivos |
| Código com potencial malware | `mythos` | Padrões de ofuscação ou exploração |
| Documento precisa ser extraído primeiro | `doc-extract` | Conteúdo está em PDF/DOCX/XLSX |
| Conteúdo contém PII ou dados sensíveis | `guardrails` | Antes de enviar para análise |
| Volume > 50 itens para analisar | `batch-processing` | Processamento paralelo com subagentes |
| Resultado "Incerto" e precisa de investigação profunda | `security-audit` (metodologia) | Abordagem estruturada de auditoria |

---

## Gotchas

⚠️ Consulte `gotchas.md` para lista completa. Principais:

1. **Textos < 100 palavras** → risco altíssimo de falso positivo. Confiança máxima: "Baixa".
2. **Inglês não-nativo** → ~61% de falso positivo documentado. SEMPRE sinalize em bias_warnings.
3. **Conteúdo técnico** → formalidade e estrutura padrão confundem detectores.
4. **Após paráfrase** → accuracy cai de ~91% para ~28% (Taloni et al. 2023).
5. **Mistura IA + edição humana** → muito difícil de classificar; tende a "Incerto".

---

## Referências

### Papers Acadêmicos

| Paper | Link | Relevância |
|-------|------|------------|
| DetectGPT (Mitchell et al., Stanford — ICML 2023) | `references/detectgpt-paper.md` | Probability curvature para detecção zero-shot. AUROC 0.95. |
| A Watermark for LLMs (Kirchenbauer et al., 2023) | `references/watermarking-paper.md` | Watermarking por token selection. Base do SynthID. |
| GPT Detectors Bias (Liang et al., Stanford — Patterns 2023) | `references/bias-research.md` | 61.3% FP em ENL writers. Referência fundamental. |

### Benchmarks

| Estudo | Link | Achado principal |
|--------|------|-----------------|
| Weber-Wulff et al. (2023) — 14 ferramentas | `references/benchmarks-comparison.md` | Nenhuma acima de 80% accuracy; 5 acima de 70%. |
| Common Sense Media (2024) — Viés racial | `references/bias-research.md` | 20% FP Black vs 7% White. |
| Taloni et al. (2023) — Anti-evasão | `references/evasion-techniques.md` | Originality.ai 91.3% → 27.8% pós Undetectable.ai. |

### Taxonomia

| Documento | Link |
|-----------|------|
| Catálogo completo de 52 sinais | `references/signal-taxonomy.md` |
