# 🚫 Anti-Patterns de LLMs ao Programar

> Exemplos concretos de como LLMs falham ao gerar código — com before/after e diff real.
> Fonte: Observações do Andrej Karpathy + exemplos adaptados do `forrestchang/andrej-karpathy-skills`.
> Carregue este arquivo quando detectar violações dos 4 anti-patterns abaixo durante code review.

---

## 1. Assumir Silenciosamente (Think Before Coding)

O LLM recebe pedido ambíguo e **escolhe uma interpretação sem perguntar**.

### ❌ Pedido: "Adicione export de dados de usuários"

```python
def export_users(format='json'):
    users = User.query.all()  # Todos? Paginação? Privacidade?
    if format == 'json':
        with open('users.json', 'w') as f:  # Onde salvar?
            json.dump([u.to_dict() for u in users], f)  # Quais campos?
```

**Problemas silenciados:**
- Assumiu exportar TODOS os usuários (privacidade?)
- Assumiu local do arquivo sem perguntar
- Assumiu quais campos incluir
- Assumiu formato sem confirmar

### ✅ O correto: Surfar as ambiguidades

```
Antes de implementar, preciso clarificar:

1. **Escopo**: Todos os usuários ou filtro? (implicações de privacidade)
2. **Formato**: Download no browser? Job em background? Endpoint API?
3. **Campos**: Quais campos? (alguns podem ser sensíveis)
4. **Volume**: Quantos usuários? (afeta a abordagem)

Abordagem mais simples: endpoint API com JSON paginado.
Qual a preferência?
```

---

## 2. Over-Abstraction Prematura (Simplicity First)

O LLM aplica design patterns para código que não precisa.

### ❌ Pedido: "Adicione função de calcular desconto"

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass

class DiscountStrategy(ABC):
    @abstractmethod
    def calculate(self, amount: float) -> float:
        pass

class PercentageDiscount(DiscountStrategy):
    def __init__(self, percentage: float):
        self.percentage = percentage
    def calculate(self, amount: float) -> float:
        return amount * (self.percentage / 100)

class FixedDiscount(DiscountStrategy):
    def __init__(self, fixed_amount: float):
        self.fixed_amount = fixed_amount
    def calculate(self, amount: float) -> float:
        return min(self.fixed_amount, amount)

@dataclass
class DiscountConfig:
    strategy: DiscountStrategy
    min_purchase: float = 0.0
    max_discount: float = float('inf')

class DiscountCalculator:
    def __init__(self, config: DiscountConfig):
        self.config = config
    def apply_discount(self, amount: float) -> float:
        if amount < self.config.min_purchase:
            return 0
        discount = self.config.strategy.calculate(amount)
        return min(discount, self.config.max_discount)
# 40+ linhas para uma conta simples
```

### ✅ O correto: Resolver o problema de hoje

```python
def calculate_discount(amount: float, percent: float) -> float:
    return amount * (percent / 100)
```

**Regra:** Adicionar Strategy/ABC/Config só quando REALMENTE precisar de múltiplos tipos de desconto. Se o requisito surgir depois, refatorar.

---

## 3. Drive-By Refactoring (Surgical Changes)

O LLM "melhora" código ao redor da mudança pedida.

### ❌ Pedido: "Corrija o bug de emails vazios no validador"

```diff
  def validate_user(user_data):
-     # Check email format
-     if not user_data.get('email'):
+     """Validate user data."""                          # docstring que ninguém pediu
+     email = user_data.get('email', '').strip()
+     if not email:
          raise ValueError("Email required")
-     if '@' not in user_data['email']:
+     if '@' not in email or '.' not in email.split('@')[1]:  # "melhorou" validação
          raise ValueError("Invalid email")
-     # Check username
-     if not user_data.get('username'):
+     username = user_data.get('username', '').strip()    # refatorou username
+     if not username:
          raise ValueError("Username required")
+     if len(username) < 3:                               # adicionou validação nova
+         raise ValueError("Username too short")
+     if not username.isalnum():                           # mais validação nova
+         raise ValueError("Username must be alphanumeric")
```

**Problemas:**
- Adicionou docstring sem ser pedido
- "Melhorou" validação de email além do bug
- Refatorou username sem necessidade
- Adicionou validações de username que ninguém pediu

### ✅ O correto: Tocar SÓ o bug reportado

```diff
  def validate_user(user_data):
      # Check email format
-     if not user_data.get('email'):
+     email = user_data.get('email', '')
+     if not email or not email.strip():
          raise ValueError("Email required")
      # Basic email validation
-     if '@' not in user_data['email']:
+     if '@' not in email:
          raise ValueError("Invalid email")
      # Check username (intocado)
      if not user_data.get('username'):
          raise ValueError("Username required")
      return True
```

---

## 4. Style Drift (Mudança de Estilo Silenciosa)

O LLM muda aspas, adiciona type hints e reformata ao fazer uma mudança simples.

### ❌ Pedido: "Adicione logging na função de upload"

```diff
- def upload_file(file_path, destination):
+ def upload_file(file_path: str, destination: str) -> bool:   # type hints não pedidos
+     """Upload file to destination with logging."""             # docstring não pedida
      try:
-         with open(file_path, 'rb') as f:
+         with open(file_path, "rb") as f:                      # mudou aspas '' → ""
              data = f.read()
-         response = requests.post(destination, files={'file': data})
-         if response.status_code == 200:
-             return True
-         else:
-             return False
+         response = requests.post(destination, files={"file": data})
+         success = response.status_code == 200                  # refatorou lógica
+         if success:
+             logger.info(f"Upload successful: {file_path}")
+         else:
+             logger.error(f"Upload failed: {status}")
+         return success
```

### ✅ O correto: Adicionar SÓ o logging, respeitando o estilo existente

```diff
+ import logging
+ logger = logging.getLogger(__name__)
+
  def upload_file(file_path, destination):
+     logger.info(f'Starting upload: {file_path}')
      try:
          with open(file_path, 'rb') as f:           # mesmas aspas
              data = f.read()
          response = requests.post(destination, files={'file': data})
          if response.status_code == 200:             # mesmo padrão booleano
+             logger.info(f'Upload successful: {file_path}')
              return True
          else:
+             logger.error(f'Upload failed: {file_path}, status={response.status_code}')
              return False
      except Exception as e:
-         print(f"Error: {e}")
+         logger.exception(f'Upload error: {file_path}')
          return False
```

---

## 📋 Tabela de Detecção Rápida

| Anti-Pattern | Sinal de Detecção | Severidade |
|---|---|---|
| Assumir silenciosamente | Implementou sem perguntar sobre ambiguidade | 🟠 HIGH |
| Over-abstraction | ABC/Strategy/Factory para uso único | 🟡 MEDIUM |
| Drive-by refactoring | Diff toca linhas que não são do pedido | 🟠 HIGH |
| Style drift | Aspas, type hints, docstrings mudados junto | 🟡 MEDIUM |

## 💡 Insight-Chave

Os exemplos "overcomplicados" não estão **errados** — eles seguem design patterns legítimos. O problema é **timing**: adicionam complexidade antes de ser necessária. Isso:
- Torna o código mais difícil de entender
- Introduz mais pontos de falha
- Demora mais para implementar
- É mais difícil de testar

> *"Bom código resolve o problema de hoje com simplicidade, não o problema de amanhã prematuramente."*
