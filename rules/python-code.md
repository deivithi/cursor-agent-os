---
paths: ["**/*.py", "**/Pipfile", "**/pyproject.toml"]
---

# Python Code Rules

- Usar `PYTHONIOENCODING=utf-8` em todos os comandos Python no Windows
- Preferir f-strings sobre .format() ou concatenação
- Type hints obrigatórios em funções públicas
- Para n8n Code nodes em Python: usar `_input`, `_json`, `_node` syntax (prefixo underscore)
- Bibliotecas padrão do workspace: markitdown, notebooklm-py, polars, plotly
- Encoding Windows: sempre especificar `encoding='utf-8'` em open()
