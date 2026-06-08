# codebase-graph — Gotchas & Problemas Conhecidos

## 1. Mermaid tem limite de ~50-80 nós antes de ficar ilegível
**Problema:** Grafos com muitos nós ficam ilegíveis e o render pode falhar.
**Solução:** Para projetos grandes, gerar subgrafos por camada ou módulo. Máximo 50 nós por diagrama.

## 2. Dynamic imports não são detectados por análise estática
**Problema:** `import()` dinâmico, `require()` com variáveis, e lazy loading não aparecem no grafo.
**Solução:** Documentar como "relações não detectadas" no output. Para projetos com muitos dynamic imports, complementar com runtime analysis.

## 3. Barrel files (index.ts) mascaram dependências reais
**Problema:** `import { X } from './models'` pode ser re-export de `./models/User.ts`. O grafo mostra dependência no barrel, não na fonte real.
**Solução:** Rastrear re-exports quando detectar `export { X } from './Y'` em index files.

## 4. Monorepos com múltiplos package.json
**Problema:** Dependências entre packages do monorepo não são capturadas pelo scan de imports simples.
**Solução:** Ler workspace config (package.json workspaces, pnpm-workspace.yaml) e mapear cross-package imports.

## 5. Python com imports relativos e absolutos
**Problema:** Python pode importar o mesmo módulo de formas diferentes (`from .models import User` vs `from myapp.models import User`).
**Solução:** Resolver imports relativos para absolutos usando o path do arquivo como referência.

## 6. Context window: projetos grandes estouram o limite
**Problema:** Ler 200+ arquivos para extração excede o context window do LLM.
**Solução:** Usar subagentes (1 por camada/módulo) e consolidar resultados no agente principal. Modo DEEP deve SEMPRE usar subagentes.

## 7. Arquivos CSS/HTML/Config inflam o grafo sem valor
**Problema:** Incluir .css, .html, .json, .env etc. adiciona nós sem relações significativas.
**Solução:** Filtrar por extensões de código-fonte apenas: .ts, .tsx, .js, .jsx, .py, .go, .rs, .java.
