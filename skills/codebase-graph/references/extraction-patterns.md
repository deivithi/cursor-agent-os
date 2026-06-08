# Extraction Patterns — Referência Detalhada

## Fontes & Inspiração

- **Understand-Anything** (Lum1104, 6K⭐): Multi-agent pipeline com tree-sitter, React Flow dashboard
- **codebase-memory-mcp** (DeusData): MCP server com knowledge graph persistente, 64 linguagens
- **code-graph-rag** (vitali87): RAG com dependency graph via tree-sitter
- **CodeVisualizer** (DucPhamNgoc08): VS Code extension com flowcharts + dependency graphs
- **CodeRAG** (Shivam Sahu): Tree-sitter AST → knowledge graph para RAG

## Padrão de Extração Universal

```
Para cada arquivo de código-fonte:
  1. IDENTIFICAR tipo (classe, módulo, script)
  2. EXTRAIR exports (o que este arquivo oferece)
  3. EXTRAIR imports (do que este arquivo depende)
  4. CLASSIFICAR camada (API, Service, Data, UI, Utility, Config, Test)
  5. CATALOGAR membros (métodos, funções, constantes)
  6. REGISTRAR metadata (LOC, complexidade estimada)
```

## TypeScript/JavaScript — Padrões Detalhados

### Imports
```typescript
// Named import
import { UserService } from './services/UserService'
// → Relação: currentFile --IMPORTS--> ./services/UserService [names: UserService]

// Default import
import UserService from './services/UserService'
// → Relação: currentFile --IMPORTS--> ./services/UserService [default]

// Namespace import
import * as utils from './utils'
// → Relação: currentFile --IMPORTS--> ./utils [namespace]

// Side-effect import
import './styles.css'
// → Ignorar (não cria relação significativa)

// Dynamic import
const mod = await import('./module')
// → ⚠️ Não detectável estaticamente. Documentar como nota.
```

### Exports
```typescript
// Named export
export function createUser() {}
// → Entidade: function createUser, exported

// Default export
export default class UserService {}
// → Entidade: class UserService, exported (default)

// Re-export (barrel)
export { User } from './User'
// → Re-export: rastrear até fonte real
```

### Relações de classe
```typescript
class Admin extends User implements Serializable {}
// → EXTENDS User
// → IMPLEMENTS Serializable

class UserService {
    private db: PrismaClient  // → COMPOSES PrismaClient
    constructor(private logger: Logger) {} // → COMPOSES Logger
}
```

## Python — Padrões Detalhados

### Imports
```python
# Absolute import
from myapp.models import User
# → Relação: currentFile --IMPORTS--> myapp/models [names: User]

# Relative import
from .models import User
# → Resolver para absolute: currentPackage/models [names: User]

# Module import
import os
# → Dependência externa (stdlib), geralmente ignorar

# Wildcard import
from .models import *
# → ⚠️ Difícil de rastrear. Marcar como "importa tudo de models"
```

### Classes e funções
```python
class Admin(User, Serializable):
    pass
# → Entidade: class Admin
# → EXTENDS User
# → EXTENDS Serializable (mixin/interface)

@dataclass
class UserDTO:
    name: str
    email: str
# → Entidade: class UserDTO (data class)

def create_user(data: dict) -> User:
    pass
# → Entidade: function create_user
```

## Classificação de Camadas — Heurísticas

| Padrão no path | Camada | Cor |
|----------------|--------|-----|
| `/api/`, `/routes/`, `/controllers/`, `/endpoints/` | API | 🔵 |
| `/services/`, `/usecases/`, `/domain/`, `/business/` | Service | 🟢 |
| `/models/`, `/entities/`, `/db/`, `/prisma/`, `/repositories/` | Data | 🟡 |
| `/components/`, `/pages/`, `/views/`, `/screens/`, `/ui/` | UI | 🟣 |
| `/utils/`, `/helpers/`, `/lib/`, `/shared/`, `/common/` | Utility | ⚪ |
| `/config/`, `/env/`, `/settings/`, `*.config.*` | Config | ⚙️ |
| `/test/`, `/spec/`, `/__tests__/`, `*.test.*`, `*.spec.*` | Test | 🧪 |
| `/middleware/`, `/plugins/`, `/hooks/` | Infra | 🔶 |

Quando o path não encaixar em nenhum padrão: analisar exports e imports para inferir.

## Ferramentas Complementares (não obrigatórias)

| Ferramenta | Quando usar | Como |
|-----------|-------------|------|
| **tree-sitter** | Parsing preciso de AST (opcional) | `npm install tree-sitter tree-sitter-typescript` |
| **madge** | Dependências de módulos JS/TS | `npx madge --image graph.svg src/` |
| **pydeps** | Dependências de módulos Python | `pydeps --noshow mypackage` |
| **dependency-cruiser** | Validação de regras de dependência JS/TS | `npx depcruise src/` |
