# 🎨 Aria Style Guide — Convenções de Código

> Convenções específicas do projeto Aria (SaaS). Atualize conforme o projeto evolui.

## TypeScript

### Tipos
- ✅ Interfaces para objetos: `interface UserProps { ... }`
- ✅ Types para unions/intersections: `type Status = 'active' | 'inactive'`
- ❌ Nunca `any` — usar `unknown` se tipo é desconhecido
- ❌ Nunca type assertions (`as`) sem comentário justificando

### Funções
- ✅ Arrow functions para callbacks: `items.map((item) => ...)`
- ✅ Named functions para exports: `export function handleAuth() { ... }`
- ✅ Early return para reduzir nesting
- ✅ Destructuring nos parâmetros: `function process({ id, name }: Input)`

### Imports
- ✅ Agrupar: 1) externos, 2) internos, 3) types
- ✅ Named imports: `import { useState } from 'react'`
- ❌ Nunca `import *` (exceto para namespacing explícito)

## React

### Componentes
- ✅ Funções (nunca classes)
- ✅ Props com interface explícita (não inline)
- ✅ Export nomeado: `export function Button() { ... }`
- ❌ Nunca default export para componentes

### Estilização
- ✅ Tailwind CSS (classes utilitárias)
- ✅ `cn()` para classes condicionais
- ❌ Nunca CSS modules ou styled-components
- ❌ Nunca inline styles (exceto valores dinâmicos calculados)

### Hooks
- ✅ Custom hooks em `hooks/` com prefixo `use`
- ✅ `useCallback` para funções passadas como props
- ❌ Nunca `useEffect` sem cleanup quando necessário

## API Routes

### Padrão
- ✅ Validação Zod em TODOS os endpoints
- ✅ Response tipada: `ApiResponse<T>`
- ✅ Error handling com try/catch + log estruturado
- ✅ Status codes corretos (200, 201, 400, 401, 404, 500)

### Naming
- ✅ Endpoints em kebab-case: `/api/user-profile`
- ✅ Handlers com prefixo `handle`: `handleCreateUser`
- ✅ Schemas com sufixo `Schema`: `CreateUserSchema`

## Logging
- ✅ Pino para logging estruturado
- ✅ `redact` para campos sensíveis
- ❌ Nunca `console.log` em código de produção
- ❌ Nunca logar: passwords, tokens, CPF, dados pessoais completos

## Testes
- ✅ Vitest como test runner
- ✅ Testes ao lado do arquivo: `feature.test.ts`
- ✅ Describe blocks por funcionalidade
- ✅ Testar happy path + pelo menos 1 edge case
