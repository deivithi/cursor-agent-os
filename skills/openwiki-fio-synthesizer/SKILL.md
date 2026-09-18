---
name: openwiki-fio-synthesizer
description: Sintetiza notas proativas e sinais de bookmarks da OpenWiki (~/.openwiki/wiki) em fios estruturados de 6 tweets para o X/Twitter (conta @opanteranegra77), aplicando os padrões anti-clichê e de tom da skill humanizer 2.8.0 para entrega no Hermes cron. Use ao criar conteúdo a partir do Personal Brain ou alimentar o FIO-IA.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0.0"
---

# OpenWiki FIO Synthesizer

Ponte de inteligência que conecta a **memória proativa do OpenWiki Personal Brain** (`~/.openwiki/wiki`) à linha de produção editorial do **FIO-IA** (Hermes cron 4×/dia), refinada pelas regras da skill **`humanizer 2.8.0`**.

---

## 🎯 Quando Usar

- Ao transformar temas, bookmarks e sinais capturados no X pelo OpenWiki em **fios autorais de 6 tweets**.
- Para abastecer o pipeline de conteúdo da conta `@opanteranegra77`.
- Para gerar rascunhos de posts técnicos com voz humana autêntica, evitando chavões de IA.
- Para inspecionar as notas mais recentes da wiki local e sugerir tópicos de alto engajamento.

## 🚫 Quando NÃO Usar (→ Handoff)

| Cenário | Skill recomendada |
|---|---|
| Ingestão bruta de bookmarks e autenticação da API do X | `openwiki-personal-brain` |
| Gerenciamento de crons e jobs agendados no Hermes | `cronjob-authoring` / Hermes runner |
| Criação de apresentações e slides em markdown | `markdown-slides` / `pptx-generator` |

---

## 📐 Estrutura Canônica de um Fio (6 Tweets)

1. **Tweet 1 (O Gancho Magnético):** Apresenta uma contradição, insight contra-intuitivo ou problema doloroso sem clichês de abertura.
2. **Tweet 2 (O Mecanismo / A Causa Raiz):** Explica o "porquê" daquilo acontecer, desmistificando o conceito.
3. **Tweet 3 (O Passo Prático 1 / Framework):** Primeira ação concreta ou princípio aplicável.
4. **Tweet 4 (O Passo Prático 2 / Exemplo Real):** Segunda ação com dados, caso prático ou ferramenta.
5. **Tweet 5 (O Erro Comum a Evitar):** Alerta sobre a principal armadilha ao tentar implementar a solução.
6. **Tweet 6 (A Síntese + CTA Discreto):** Resumo em uma frase contundente, convite à reflexão ou RT.

---

## 🛡️ Filtro Anti-IA (Humanizer 2.8.0)

- **Proibido:**
  - *"No mundo acelerado de hoje..."* / *"Mergulhe conosco..."*
  - Listas genéricas sem opinião ou contexto real.
  - Emojis em excesso no início de cada linha.
  - Conclusões com *"Em suma"* ou *"Lembre-se: o futuro é agora"*.
- **Obrigatório:**
  - Frases curtas intercaladas com parágrafos de uma linha.
  - Uso de termos cotidianos, exemplos práticos de tecnologia e dados observáveis.
  - Máximo de 280 caracteres por tweet.

---

## 🔄 Workflow de Produção

1. **Leitura da Wiki:**
   - Varrer `~/.openwiki/wiki` em busca das notas criadas/atualizadas nas últimas 24–48h.
2. **Extração do Core Insight:**
   - Selecionar uma tese única e clara.
3. **Execução do Gerador:**
   ```powershell
   python skills/openwiki-fio-synthesizer/scripts/synthesize-openwiki-fio.py --topic "Nome do Topico"
   ```
4. **Aplicação do Humanizer:**
   - Ajustar cadência e pontuação.
5. **Persistência / Hermes Backup:**
   - Salvar saída em `state/email-corpo.txt` conforme protocolo ADR-005.

---

## 📚 Referências

- [`references/humanizer-fio-rules.md`](references/humanizer-fio-rules.md) — Regras de estilo, tom de voz e blacklist de palavras de IA.
- [`skills/openwiki-personal-brain/SKILL.md`](../openwiki-personal-brain/SKILL.md) — Setup e operação do OpenWiki Personal Brain.
- [`DECISIONS.md`](../../DECISIONS.md) — **ADR-005** (FIO-IA canônico no Hermes).
