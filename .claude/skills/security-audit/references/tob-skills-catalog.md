# Trail of Bits — Catálogo de Skills (35+ plugins)

## Fonte
- Repositório: https://github.com/trailofbits/skills (4K⭐)
- Config: https://github.com/trailofbits/claude-code-config
- Licença: CC-BY-SA-4.0

## Categorias e Skills

### 🔒 Smart Contract Security (2)
| Skill | Função |
|-------|--------|
| `building-secure-contracts` | Patterns de segurança para smart contracts (Solidity/Vyper) |
| `entry-point-analyzer` | Análise de pontos de entrada em contratos |

### 🔍 Code Auditing (12) — MAIS RELEVANTE PARA NÓS
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `audit-context-building` | Ultra-granular code analysis antes de vuln hunting | ✅ **Extraído** |
| `differential-review` | Review focado em segurança com análise histórica | ✅ **Extraído** |
| `variant-analysis` | Encontrar variantes de bugs conhecidos no codebase | ✅ **Extraído** |
| `fp-check` | Verificação sistemática de false positives | ✅ **Extraído** |
| `insecure-defaults` | Detectar configurações default inseguras | ✅ **Extraído** |
| `sharp-edges` | APIs fáceis de usar de forma insegura | ✅ **Extraído** |
| `supply-chain-risk-auditor` | Auditoria de dependências e supply chain | ✅ **Extraído** |
| `static-analysis` | Integração com ferramentas de análise estática | ✅ (via Semgrep) |
| `semgrep-rule-creator` | Criar rules Semgrep customizadas | ⚠️ Futuro |
| `semgrep-rule-variant-creator` | Criar variantes de rules existentes | ⚠️ Futuro |
| `agentic-actions-auditor` | Auditar ações de agentes IA | ⚠️ Futuro |
| `burpsuite-project-parser` | Parser de projetos Burp Suite | ❌ Não usamos |
| `testing-handbook-skills` | Metodologia de testes de segurança | ⚠️ Futuro |

### 🦠 Malware Analysis (1)
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `yara-authoring` | Criar regras YARA para detecção de malware | ❌ Não é nosso foco |

### ✅ Verification (4)
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `constant-time-analysis` | Detectar timing side-channels em crypto | ⚠️ Nicho |
| `property-based-testing` | Testes baseados em propriedades | ✅ Via TDD |
| `spec-to-code-compliance` | Verificar código contra especificação | ⚠️ Futuro |
| `zeroize-audit` | Detectar secrets não limpos da memória | ⚠️ Nicho |

### 🔄 Reverse Engineering (1)
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `dwarf-expert` | Debug info DWARF para RE | ❌ Nicho |

### 📱 Mobile Security (1)
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `firebase-apk-scanner` | Scanner de segurança de APKs Firebase | ⚠️ Se tivermos app mobile |

### 🛠️ Development (10)
| Skill | Função | Aplicável? |
|-------|--------|-----------|
| `seatbelt-sandboxer` | Sandboxing de processos | ⚠️ |
| `modern-python` | Best practices Python moderno | ✅ Via clean-code-rules |
| `skill-improver` | Melhorar skills existentes | ✅ Via skill-architect |
| `workflow-skill-design` | Design de skills | ✅ Via skill-architect |
| `second-opinion` | Segunda opinião em decisões | ⚠️ |
| `gh-cli` | GitHub CLI patterns | ✅ Já temos |
| `git-cleanup` | Limpeza de repositório | ⚠️ |
| `devcontainer-setup` | Configurar dev containers | ❌ Usamos local |
| `ask-questions-if-underspecified` | Pedir clarificação | ✅ Já fazemos |
| `let-fate-decide` | Decisão aleatória | ❌ Irrelevante |

## Patterns Extraídos para Nossa Skill

Dos 35+ plugins, **7 patterns** foram extraídos e incorporados ao nosso `security-audit`:

1. **Audit Context Building** (Fase 1 completa)
2. **Variant Analysis** (Pattern 1)
3. **Supply Chain Risk** (Pattern 2)
4. **Insecure Defaults** (Pattern 3)
5. **Sharp Edges** (Pattern 4)
6. **Differential Review** (Pattern 5)
7. **FP-Check** (Fase 3.3)

## Trophy Case (Findings Reais do Trail of Bits)
- Timing side-channel em ML-DSA signing (discovered via `constant-time-analysis`)
- Múltiplos findings em smart contracts (discovered via `variant-analysis`)
- Supply chain risks em dependências npm (discovered via `supply-chain-risk-auditor`)

## Semgrep OWASP Top 10 2025
- 4000+ rules atualizadas para OWASP Top 10 2025
- Suporte expandido: Express, NestJS, Hapi, Koa (JS/TS)
- Taint tracking melhorado para fluxos cross-file
- Validado contra OWASP JuiceShop e BrokenCrystals
- Fonte: https://semgrep.dev/p/owasp-top-ten
