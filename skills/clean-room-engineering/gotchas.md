# Gotchas — Clean Room Engineering

> Edge cases, falsos positivos e armadilhas conhecidas.
> Consultar ANTES de flaggear contaminacao.

---

## Falsos Positivos de Similaridade

### 1. Padroes Universais NAO sao contaminacao

Codigo que implementa padroes universais tera similaridade alta com QUALQUER implementacao:

- **Design patterns:** Singleton, Factory, Observer, Strategy
- **Algoritmos classicos:** QuickSort, BFS/DFS, Binary Search, Hash Map
- **Boilerplate de framework:** Express routes, React hooks, Next.js API routes
- **Idiomas de linguagem:** list comprehension (Python), destructuring (JS), pattern matching (Rust)
- **Protocolos padrao:** HTTP headers, JSON parsing, WebSocket handshake

**Regra:** Se o padrao aparece em 100+ projetos nao-relacionados, similaridade NAO indica contaminacao.

### 2. APIs Padrao Geram Codigo Similar

Implementacoes que usam a mesma stdlib/framework produzem codigo naturalmente similar:

```
# Dois devs escrevendo "ler arquivo JSON" em Python
# AMBOS vao escrever algo muito parecido com:
with open(path) as f:
    data = json.load(f)
```

**Regra:** Similaridade em chamadas de stdlib/framework e esperada e NAO e contaminacao.

### 3. Nomes Descritivos vs Nomes Copiados

- `parse_json()` e um nome descritivo — qualquer dev escolheria algo similar
- `_internal_recursive_node_walker_v2()` e um nome especifico — alta probabilidade de copia

**Regra:** Nomes que descrevem a funcao (verbo + substantivo) sao esperados. Nomes idiossincraticos que coincidem com o original sao red flag.

---

## Limitacoes de Ferramentas de Similaridade

### JPlag
- **Bom para:** Deteccao de plagio academico, token-level similarity
- **Limitacao:** Nao detecta "parafraseamento" — codigo que faz a mesma coisa com estrutura diferente passa facilmente
- **Threshold:** < 15% e seguro, mas 0% nao significa independencia (pode significar refatoracao superficial)

### MOSS (Stanford)
- **Bom para:** Comparacao entre multiplas submissoes
- **Limitacao:** Projetado para ambiente academico, nao para codebases de producao grandes
- **Acesso:** Requer registro academico

### difflib (Python)
- **Bom para:** Comparacao rapida e local
- **Limitacao:** Sequencia-based, nao entende semantica. Renomear variaveis reduz similaridade artificialmente

### Realidade
> Nenhuma ferramenta detecta contaminacao semantica — quando o codigo faz a mesma coisa de forma diferente. Ferramentas medem similaridade sintatica, nao intelectual. Um resultado "limpo" e necessario mas NAO suficiente.

---

## Jurisdicoes Diferentes

### EUA (base dos cases legais citados)
- Dicotomia ideia-expressao e estabelecida (Baker v. Selden)
- Fair use e flexivel (4 fatores, caso a caso)
- APIs tendem a nao ser protegidas (Oracle v. Google)
- Clean room two-team e aceito (Compaq)

### Uniao Europeia
- **EU AI Act (2025-2026):** Exige transparencia sobre dados de treinamento de IA
- **Database Directive:** Protecao sui generis de bancos de dados (nao existe nos EUA)
- **Copyright Directive (Art. 3-4):** Text and data mining tem excecoes limitadas
- Copyleft enforcement tende a ser mais forte (ex: casos de GPL na Alemanha via gpl-violations.org)

### Brasil
- Lei de Direitos Autorais (9.610/98) protege programas de computador como obra literaria
- Lei de Software (9.609/98) protecao especifica
- Clean room NAO tem jurisprudencia brasileira especifica
- **Cautela adicional:** tribunais brasileiros podem interpretar de forma diferente dos EUA

**Regra:** Se o projeto tem impacto comercial em multiplas jurisdicoes, consulte advogado local.

---

## Training Data Contamination — A Grande Incognita

### O problema
LLMs foram treinadas em bilhoes de linhas de codigo open source, incluindo codigo GPL. Quando uma LLM gera codigo "do zero", ela esta potencialmente reproduzindo padroes aprendidos de codigo copyleft.

### Por que isso importa
O modelo classico de clean room assume que o Time 2 (implementador) NAO tem conhecimento previo do codigo original. Uma LLM treinada no codigo original **por definicao** tem conhecimento previo.

### Status legal (abril 2026)
- Nenhum tribunal decidiu se treinamento em GPL = "contaminacao"
- Doe v. GitHub/Copilot esta em andamento mas nao resolveu esta questao
- chardet 7.0.0 e o caso mais proximo, mas nao chegou a tribunal
- Heather Meeker (advogada especialista) argumenta que IA PODE servir como clean team
- Criticos argumentam que e "license laundering" — a lavagem e eficaz mas nao e independencia

### Mitigacoes possiveis
1. **Documentar tudo** — prompts, modelos usados, decisoes
2. **Modelos diferentes** para analise e implementacao
3. **Verificacao de provenance** com multiplas ferramentas
4. **Revisao humana** do codigo gerado
5. **Aceitar o risco** de forma documentada e consciente

### O que NAO fazer
- Fingir que o problema nao existe
- Assumir que baixa similaridade = total independencia
- Usar uma unica ferramenta como prova definitiva
- Ignorar que o modelo foi treinado em codigo copyleft

---

## Armadilhas Comuns

### 1. "Spec Publica" com Detalhes de Implementacao

READMEs e docs frequentemente incluem trechos de codigo como exemplo. Esses trechos SAO expressao protegida.

**Errado:** Copiar exemplos de codigo da documentacao para a spec
**Certo:** Descrever o comportamento que o exemplo demonstra, sem o codigo

### 2. Test Suite do Original como Referencia

Testes sao codigo. Copiar a test suite do projeto original e copiar expressao.

**Errado:** `cp original/tests/* meu-projeto/tests/`
**Certo:** Gerar testes novos a partir da spec sanitizada

**Excecao:** Testes de conformidade de protocolo/padrao (ex: RFC compliance tests) podem ser usados se estao sob licenca permissiva ou sao parte de uma spec publica.

### 3. "E So uma Funcao Pequena"

Tamanho nao determina protecao de copyright. Uma funcao de 10 linhas com logica criativa unica e protegida tanto quanto um modulo de 10.000 linhas.

### 4. Clean Room para Contornar Contrato

Clean room protege contra claims de copyright. NAO protege contra:
- Violacao de NDA
- Breach of contract
- Trade secret misappropriation
- Patentes (algoritmos patenteados sao protegidos independente da implementacao)

### 5. Assumir que "Open Source" = "Pode Tudo"

Cada licenca tem regras especificas:
- **MIT/Apache:** Permissivo — use, mas mantenha atribuicao
- **GPL:** Copyleft forte — derivados devem ser GPL
- **LGPL:** Copyleft fraco — linking sem contaminar
- **AGPL:** Copyleft de rede — uso em servidor = distribuicao
- **SSPL:** Copyleft extremo — todo o stack de servico deve ser aberto

**Clean room so e necessario quando a licenca IMPEDE o uso desejado.** Se a licenca ja permite, use diretamente com atribuicao.
