# Smart Explore — Exploração Progressiva de Código

Explore o codebase de forma inteligente e eficiente em tokens para: **$ARGUMENTS**

## Regras Críticas

- **NUNCA** leia arquivos inteiros sem antes filtrar o que importa
- Siga as 3 camadas obrigatoriamente — cada camada reduz o escopo
- Reporte custo estimado em tokens a cada camada

## Camada 1: Descoberta (~50-100 tokens por resultado)

Encontre arquivos e símbolos relevantes usando Glob e Grep.

1. Use `Glob` com padrões inteligentes para encontrar arquivos candidatos
2. Use `Grep` para buscar keywords, classes, funções, imports relacionados a "$ARGUMENTS"
3. Apresente uma **tabela indexada** com resultados:

```
| # | Arquivo | Match | Relevância |
|---|---------|-------|------------|
| 1 | src/... | class X | Alta |
| 2 | lib/... | import Y | Média |
```

Pergunte: "Quais itens quer que eu aprofunde?"
Se o contexto for claro, avance automaticamente nos top 3.

## Camada 2: Estrutura (~100-200 tokens por arquivo)

Para cada arquivo selecionado, mostre apenas a **estrutura** (outline):

1. Leia o arquivo e extraia: exports, classes, funções, interfaces, types
2. Mostre como outline hierárquico:

```
📄 src/services/auth.ts
  ├── import { jwt } from 'jsonwebtoken'
  ├── export class AuthService
  │   ├── constructor(db: Database)
  │   ├── async login(email, password): Promise<Token>
  │   ├── async verify(token): Promise<User>
  │   └── private hashPassword(pw): string
  └── export const authMiddleware: RequestHandler
```

3. Identifique dependências e conexões entre arquivos

## Camada 3: Detalhe (~500-1000 tokens por símbolo)

Só agora leia a implementação completa dos símbolos específicos relevantes.

1. Leia apenas as funções/classes que importam
2. Analise: lógica, patterns usados, edge cases, possíveis bugs
3. Mapeie dependências upstream e downstream

## Output Final

Apresente um resumo estruturado:

```
## Descobertas sobre: $ARGUMENTS

### Arquitetura
- [como funciona, padrões identificados]

### Arquivos-chave
- [arquivo:linha — o que faz]

### Dependências
- [o que depende do quê]

### Observações
- [patterns, riscos, oportunidades]
```

## Economia de Tokens

Sempre mostre ao final:
- Arquivos encontrados (Camada 1): X
- Arquivos analisados (Camada 2): Y
- Símbolos detalhados (Camada 3): Z
- Estimativa: ~N tokens usados vs ~M se tivesse lido tudo
