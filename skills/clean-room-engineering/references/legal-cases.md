# Legal Cases — Clean Room Engineering

> Referencia detalhada dos cases legais que fundamentam clean room engineering.
> Carregada sob demanda pelo SKILL.md.

---

## Cases Historicos

### 1. Baker v. Selden (1879) — A Pedra Fundamental

- **Partes:** Baker (reu) vs Selden (autor de livro contabil)
- **Corte:** Suprema Corte dos EUA
- **Questao:** Selden tinha copyright sobre um sistema de contabilidade descrito em seu livro?
- **Decisao:** NAO. Copyright protege a **expressao** (o texto do livro), nao a **ideia** (o metodo contabil). Baker podia usar o mesmo metodo com seu proprio texto.
- **Principio:** Dicotomia ideia-expressao. Funcionalidade e livre; expressao e protegida.
- **Impacto:** Base de TODO o clean room engineering. 147 anos depois, ainda e citado em casos de software.

---

### 2. Apple v. Franklin (1983)

- **Partes:** Apple Computer vs Franklin Computer Corp
- **Corte:** Third Circuit Court of Appeals
- **Questao:** Object code (codigo compilado) de sistema operacional tem copyright?
- **Decisao:** SIM. Software em qualquer forma (source ou object) e protegido por copyright.
- **Principio:** Software recebe protecao de copyright, mesmo compilado.
- **Impacto:** Estabeleceu que copiar BIOS/SO byte-a-byte e violacao. Motivou a criacao do clean room como alternativa legal.

---

### 3. Compaq BIOS (1982-1983) — O Modelo Gold Standard

- **Partes:** Compaq Computer Corp (reimplementando IBM BIOS)
- **Custo:** ~US$1 milhao
- **Processo:**
  - **Time 1 (Dirty Room):** Desassemblou BIOS IBM. Documentou cada function call, interrupt, sequencia de boot, mapeamento de memoria. Produziu especificacao funcional SEM codigo.
  - **Time 2 (Clean Room):** Completamente isolado. Recebeu APENAS a especificacao. Reimplementou BIOS do zero em assembly.
- **Resultado:** BIOS funcionalmente equivalente. IBM nunca processou — o processo era juridicamente impecavel.
- **Vendas:** US$150 milhoes no primeiro ano.
- **Impacto:** Criou o modelo two-team que permanece valido ate hoje. Habilitou toda a industria de PC clones.

---

### 4. Sega v. Accolade (1992)

- **Partes:** Sega (fabricante de console) vs Accolade (desenvolvedora de jogos)
- **Corte:** Ninth Circuit Court of Appeals
- **Questao:** Accolade desassemblou o BIOS do Genesis para criar jogos compativeis. Isso e legal?
- **Decisao:** SIM. Reverse engineering para interoperabilidade e **fair use**, mesmo envolvendo copia temporaria do codigo durante analise.
- **Principio:** Desassembly para entender interfaces e legal quando nao ha outro meio de obter a informacao.
- **Impacto:** Legitimou reverse engineering para interoperabilidade. Base para emuladores e compatibilidade.

---

### 5. Lotus v. Borland (1995)

- **Partes:** Lotus (1-2-3 spreadsheet) vs Borland (Quattro Pro)
- **Corte:** First Circuit → Suprema Corte (4-4 tie, manteve decisao do Circuit)
- **Questao:** A hierarquia de menus do Lotus 1-2-3 e protegida por copyright?
- **Decisao:** NAO. Menus sao "metodo de operacao", nao expressao criativa.
- **Principio:** Interfaces de usuario e estruturas de comando nao tem copyright. Sao metodos de operacao.
- **Impacto:** Precedente para APIs e interfaces. Citado extensivamente em Oracle v. Google.

---

### 6. Oracle v. Google (2021) — O Caso Definitivo

- **Partes:** Oracle (dona do Java) vs Google (Android)
- **Corte:** Suprema Corte dos EUA
- **Decisao:** 6-2 a favor do Google. Uso de ~11.500 linhas de Java API declaring code e **fair use**.
- **Fatores de fair use:**
  1. **Proposito:** Transformativo (novo contexto — smartphones)
  2. **Natureza:** APIs sao funcionais, nao criativas
  3. **Quantidade:** Pequena fracao do total do Java
  4. **Efeito no mercado:** Android nao substituiu Java no mercado original
- **Principio:** APIs declarativas podem ser copiadas sob fair use, especialmente para interoperabilidade.
- **Impacto:** Maior caso de software copyright da historia. Confirmou que interfaces funcionais sao mais "ideia" que "expressao".

---

### 7. Doe v. GitHub / Copilot (2022-presente)

- **Partes:** Desenvolvedores open source vs GitHub, Microsoft, OpenAI
- **Corte:** Northern District of California
- **Questao:** Copilot treinou em bilhoes de linhas de codigo GPL/MIT sem cumprir atribuicao e termos de licenca. Isso viola copyright?
- **Timeline:**
  - Nov 2022: Processo aberto
  - Jan 2024: Juiz Tigar descartou claim de copyright DMCA (nao demonstraram geracao de codigo identico)
  - 2024: Claims de breach-of-license e contrato mantidos
  - 2025: Settlement reportado; EU AI Act entra em vigor exigindo transparencia de dados de treino
- **Status (abril 2026):** Estabeleceu que licencas open source sao **acordos executaveis**, nao sugestoes.
- **Impacto:** Ainda em evolucao. Caso mais relevante para a questao "IA treinada em GPL = contaminacao?"

---

## Case Study Contemporaneo: chardet 7.0.0 (Marco 2026)

### Contexto
- **chardet:** Biblioteca Python de deteccao de character encoding, ~130 milhoes de downloads/mes
- **Maintainer:** Dan Blanchard (12+ anos mantendo o projeto)
- **Licenca original:** LGPL (copyleft fraco)

### O que aconteceu
1. Dan usou Claude Code (Opus 4.6) para reescrever chardet do zero
2. Mudou licenca de LGPL para MIT
3. JPlag retornou 0.04% de similaridade media com o codebase antigo
4. Publicou como chardet 7.0.0

### A controversia
- **Mark Pilgrim** (criador original, silencioso desde 2011) voltou para abrir issue: "No right to relicense this project"
- **Argumento contra:** Dan conhecia profundamente o codigo original (12 anos). Claude quase certamente foi treinado no chardet. Claude foi observado referenciando partes do codebase original durante o rewrite.
- **Argumento a favor:** O codigo novo e demonstravelmente diferente (0.04% similaridade). Comportamento funcional nao e protegido por copyright.

### Analise de Simon Willison
> *"Pessoalmente inclinado a achar que o rewrite e legitimo, mas os argumentos dos dois lados sao inteiramente crediveis."*

### Status (abril 2026)
- Nao chegou a tribunal
- Permanece como o caso mais proximo de um teste juridico de clean room com IA
- Comunidade dividida

### Licoes
1. Familiaridade do desenvolvedor com o original e o maior vetor de contaminacao
2. Similaridade baixa em ferramenta automatica NAO garante independencia
3. A questao "LLM treinada no codigo = conhecimento previo?" permanece sem resposta judicial
4. Transparencia total sobre o processo e a melhor defesa

---

## Principios Consolidados

| Principio | Base Legal | Aplicacao Clean Room |
|-----------|-----------|---------------------|
| Ideias sao livres | Baker v. Selden (1879) | Comportamento funcional pode ser reimplementado |
| Software tem copyright | Apple v. Franklin (1983) | Copiar codigo = violacao; reimplementar = valido |
| Two-team isolation funciona | Compaq (1982) | Separar analise de implementacao |
| RE para interop e fair use | Sega v. Accolade (1992) | Desassembly para entender interfaces e legal |
| APIs nao sao expressao | Lotus v. Borland (1995) + Oracle v. Google (2021) | Interfaces podem ser reimplementadas |
| Licencas sao contratos | Doe v. GitHub (2022+) | Termos de licenca devem ser respeitados |

---

## Aviso Legal

> **Esta referencia e informativa, NAO e aconselhamento juridico.** A aplicacao de clean room engineering com IA e territorio juridico nao testado em tribunal (abril 2026). Para decisoes com impacto comercial significativo, consulte um advogado especializado em propriedade intelectual e software.

> **Jurisdicao:** Cases citados sao predominantemente dos EUA. O EU AI Act (2025-2026) introduz requisitos diferentes. Outras jurisdicoes podem diferir substancialmente.
