# 📜 llms.txt — Spec & Exemplos

Padrão emergente proposto por [Jeremy Howard (Answer.AI, 2024)](https://llmstxt.org/).
Arquivo markdown em `/llms.txt` q fornece contexto curado p/ LLMs.

---

## 1. Spec resumida

- **Localização:** `https://<domain>/llms.txt` (raiz)
- **Formato:** Markdown (UTF-8)
- **Estrutura obrigatória:**
  1. `# <Nome do projeto/marca>` (H1 único)
  2. `> <blockquote de descrição curta>` (1 parágrafo, ≤ 500 chars)
  3. Parágrafos adicionais de contexto (opcional)
  4. Seções H2 (`## <Seção>`) c/ listas de links markdown
  5. Seção H2 `## Optional` no fim p/ conteúdo secundário

**Variante `/llms-full.txt`:** versão expandida c/ conteúdo inline (ñ só links). Formato Markdown livre.

---

## 2. Exemplo mínimo válido

```markdown
# Febracis

> Empresa de educação e desenvolvimento humano fundada por Paulo Vieira. Líder em cursos presenciais e digitais de inteligência emocional e performance (Método CIS®) no Brasil.

## Eventos

- [Método CIS Presencial](https://febracis.com.br/metodo-cis): Imersão de 3 dias de desenvolvimento pessoal
- [Próximos eventos](https://febracis.com.br/eventos): Calendário atualizado

## Produtos digitais

- [Pulso Finance](https://pulsofinance.com.br): App de gestão financeira pessoal
- [Cursos online](https://febracis.com.br/cursos): Catálogo completo

## Optional

- [Blog](https://febracis.com.br/blog)
- [Cases de sucesso](https://febracis.com.br/cases)
```

---

## 3. Regras de validação (implementadas na skill)

| Regra | Severidade | Mensagem |
|---|---|---|
| Exatamente 1 H1 | Critical | "llms.txt DEVE ter exatamente 1 H1" |
| Blockquote logo após H1 | Critical | "descrição em blockquote é obrigatória" |
| Blockquote ≤ 500 chars | Major | "descrição muito longa (N chars)" |
| Links têm formato markdown válido | Critical | "link malformado na linha N" |
| URLs HTTPS | Major | "URL HTTP: $url" |
| Seções H2 únicas (sem H2 duplicado) | Minor | "H2 duplicado: $sec" |
| `## Optional` por último (se presente) | Minor | "## Optional deveria ser última seção" |
| Tamanho ≤ 100KB | Major | "llms.txt muito grande: Nkb" |

---

## 4. Geração automática a partir de sitemap

Fallback quando `/llms.txt` ausente:

```
1. GET /sitemap.xml (ou /sitemap_index.xml)
2. Parse URLs + lastmod
3. Agrupa por path prefix (/eventos/, /blog/, /cursos/)
4. Top 10 por grupo (ordenado por lastmod desc)
5. Extrai <title> e <meta description> de cada (WebFetch paralelo)
6. Gera markdown c/ estrutura spec
7. Adiciona cabeçalho:
   "<!-- Gerado automaticamente de sitemap. Curar manualmente antes de publicar. -->"
```

---

## 5. Integração c/ Febracis

Templates em `templates/llms-txt-febracis.txt` têm:
- Seção "Eventos" (Método CIS, presenciais, online)
- Seção "Produtos" (Pulso Finance, cursos)
- Seção "Sobre Paulo Vieira" (autor, livros)
- Seção "Casos de sucesso"
- `## Optional` c/ blog e mídia

---

## 6. Limitações conhecidas

- **Ñ substitui robots.txt** — é sinal complementar
- **Bots ñ são obrigados a respeitar** — 2026 ainda é adoção voluntária
- **Sem validador oficial** — só heurísticas
- **Google ñ prioriza llms.txt em SEO tradicional** (confirmado 2025 via John Mueller)

---

## 7. Crédito upstream

Boa parte da lógica de validação vem do repo [`zubair-trabzada/geo-seo-claude`](https://github.com/zubair-trabzada/geo-seo-claude) (MIT). Absorção seletiva — ñ cloned.

Spec original: https://llmstxt.org/ (Jeremy Howard, Answer.AI, 2024).
