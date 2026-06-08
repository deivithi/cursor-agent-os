# Web Fetch Tool — Referência API (Server Tool)

> **Fonte:** https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool
> **Atualizado:** 29/03/2026

Referência para quando construirmos apps que usam `web_fetch` como **server tool** na Claude API (não confundir com o WebFetch nativo do Claude Code CLI).

---

## Versões

| Versão | Recurso Principal | Requisito |
|--------|-------------------|-----------|
| `web_fetch_20250910` | Fetch padrão (HTML → texto, PDF → extração) | Qualquer modelo suportado |
| `web_fetch_20260209` | **Dynamic Filtering** — Claude escreve código para filtrar conteúdo ANTES de entrar no contexto | Opus 4.6 ou Sonnet 4.6 + Code Execution habilitado |

**Dynamic Filtering** é ideal para: extrair seções específicas de docs longos, processar dados estruturados, filtrar PDFs, reduzir custo de tokens em documentos grandes.

---

## Parâmetros

```json
{
  "type": "web_fetch_20260209",
  "name": "web_fetch",
  "max_uses": 10,
  "allowed_domains": ["example.com", "docs.example.com"],
  "blocked_domains": ["private.example.com"],
  "citations": { "enabled": true },
  "max_content_tokens": 100000
}
```

| Parâmetro | Tipo | Default | Descrição |
|-----------|------|---------|-----------|
| `max_uses` | number | sem limite | Limite de fetches por request. Após exceder → erro `max_uses_exceeded` |
| `allowed_domains` | string[] | todos | Whitelist de domínios permitidos |
| `blocked_domains` | string[] | nenhum | Blacklist de domínios bloqueados |
| `max_content_tokens` | number | sem limite | Trunca conteúdo que exceder esse limite (aproximado) |
| `citations` | object | desabilitado | `{"enabled": true}` para citações com `char_location` |

---

## Custo por Tipo de Conteúdo

| Tipo | Tamanho | Tokens estimados |
|------|---------|-----------------|
| Página web média | 10 kB | ~2.500 |
| Doc/página grande | 100 kB | ~25.000 |
| PDF acadêmico | 500 kB | ~125.000 |

**Pricing:** Sem custo adicional além dos tokens standard. Controlar com `max_content_tokens`.

---

## Segurança

- **URL Validation:** Claude só pode fetch URLs que já apareceram no contexto (mensagens do usuário, resultados de tools anteriores). Não pode construir URLs dinamicamente.
- **Data Exfiltration Risk:** Em ambientes onde Claude processa input não-confiável junto com dados sensíveis, há risco de exfiltração. Mitigações:
  - Desabilitar web_fetch em contextos sensíveis
  - Usar `max_uses` para limitar requests
  - Usar `allowed_domains` para restringir a domínios seguros
- **Não suporta:** Sites renderizados via JavaScript (SPA sem SSR)

---

## Padrão Combinado: Search + Fetch

```python
tools=[
    {"type": "web_search_20250305", "name": "web_search", "max_uses": 3},
    {
        "type": "web_fetch_20250910",
        "name": "web_fetch",
        "max_uses": 5,
        "citations": {"enabled": True},
    },
]
```

Fluxo: Claude busca → seleciona melhores resultados → faz fetch do conteúdo completo → analisa com citações.

---

## Erros Possíveis

| Código | Causa |
|--------|-------|
| `invalid_input` | URL inválida |
| `url_too_long` | URL > 250 caracteres |
| `url_not_allowed` | Bloqueada por domain filtering |
| `url_not_accessible` | Erro HTTP ao buscar |
| `too_many_requests` | Rate limit |
| `unsupported_content_type` | Só texto e PDF suportados |
| `max_uses_exceeded` | Limite de usos atingido |
| `unavailable` | Erro interno |
