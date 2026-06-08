# Memento-Skills — Agente Autônomo com Auto-Aprimoramento

## Quando Usar

Ative esta skill quando precisar de:
- **Geração de documentos** — PDF, XLSX, DOCX, PPTX com lógica complexa
- **Web search autônomo** — pesquisa + extração de páginas sem intervenção manual
- **Análise de imagens / OCR** — via skill `image-analysis` do Memento
- **Criação de novas skills** — use o `skill-creator` para gerar e evoluir skills no próprio Memento
- **Tarefas multi-step isoladas** — o Memento executa em sandbox uv, sem afetar o ambiente principal

**Palavras-chave de ativação:** `memento agent`, `memento skill`, `delegar ao memento`, `executar no memento`

---

## Configuração

| Item | Valor |
|---|---|
| **Executável** | `C:/Users/PC/.memento-env/Scripts/memento.exe` |
| **Config** | `C:/Users/PC/memento_s/config.json` |
| **Logs** | `C:/Users/PC/memento_s/logs/` |
| **Skills DB** | `C:/Users/PC/memento_s/` (SQLite) |
| **Provider** | OpenRouter → `minimax/minimax-m2.7` |
| **API Key** | mesma do Aria (`OPENROUTER_API_KEY`) |
| **Repo fonte** | `C:/Users/PC/.memento-skills/` |
| **Python** | 3.12.13 via uv |

---

## Comandos

```bash
# Sessão interativa
C:/Users/PC/.memento-env/Scripts/memento.exe agent

# Tarefa single-shot (mais usado pelo Claude Code)
C:/Users/PC/.memento-env/Scripts/memento.exe agent -m "sua tarefa aqui"

# Diagnóstico do ambiente
C:/Users/PC/.memento-env/Scripts/memento.exe doctor

# Validar skills instaladas
C:/Users/PC/.memento-env/Scripts/memento.exe verify

# GUI desktop
C:/Users/PC/.memento-env/Scripts/memento-gui.exe
```

---

## Built-in Skills Disponíveis (10)

| Skill | Capacidade |
|---|---|
| `filesystem` | Leitura, escrita, busca de arquivos e diretórios |
| `web-search` | Busca Tavily + extração de páginas web |
| `image-analysis` | Visão computacional, OCR, legendagem |
| `pdf` | Leitura, preenchimento de formulários, manipulação |
| `docx` | Criação e edição de documentos Word |
| `xlsx` | Processamento de planilhas Excel |
| `pptx` | Geração de apresentações PowerPoint |
| `skill-creator` | Desenvolvimento e otimização de novas skills |
| `uv-pip-install` | Gerenciamento de dependências Python no sandbox |
| `im-platform` | Integração com Feishu, DingTalk, WeCom, WeChat |

---

## Como Delegar do Claude Code

```bash
# Gerar um relatório Excel
C:/Users/PC/.memento-env/Scripts/memento.exe agent -m \
  "Crie um Excel com as vendas do mês em C:/Users/PC/Desktop/vendas.xlsx"

# Pesquisa autônoma na web
C:/Users/PC/.memento-env/Scripts/memento.exe agent -m \
  "Pesquise os 5 melhores frameworks Python para agentes IA em 2025"

# Criar nova skill
C:/Users/PC/.memento-env/Scripts/memento.exe agent -m \
  "Use skill-creator para criar uma skill de análise de DRE financeiro"
```

---

## Arquitetura do Loop de Aprendizado

```
Intent → Planning → Execution (sandbox uv) → Reflection → Finalize
                                   ↓
                     Falha? → Atualiza score da skill → Regenera skill
```

Skills evoluem automaticamente. O banco SQLite em `~/memento_s/` acumula histórico de execuções e scores de qualidade.

---

## Atualizar o Memento

```bash
cd C:/Users/PC/.memento-skills/
git pull
C:/Users/PC/.memento-env/Scripts/pip.exe install -e . --upgrade
```
