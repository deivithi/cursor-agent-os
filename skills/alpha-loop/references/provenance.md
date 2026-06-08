# 📚 Alpha Loop — Proveniência e Fontes

## Fonte Principal

**Paper:** Code Generation with AlphaCodium: From Prompt Engineering to Flow Engineering
**Autores:** Tal Ridnik, Dedy Kredo, Itamar Friedman (CodiumAI / Qodo)
**Link:** https://arxiv.org/abs/2401.08500
**Publicado:** Janeiro 2024
**Repo:** https://github.com/Codium-ai/AlphaCodium (4K+ ⭐)

## Resultado Key

- GPT-4 accuracy (pass@5) em CodeContests: **19% → 44%** (2.3x improvement)
- Custo: 15-20 API calls por solução
- O flow supera inclusive OpenAI o1 em direct prompting (blog Qodo, 2025)

## Princípios Extraídos

1. **Flow > Prompt:** Múltiplos estágios estruturados > um prompt único perfeito
2. **Test-anchored iteration:** Testes como critério objetivo de progresso
3. **Easy-to-hard knowledge accumulation:** Cada passo alimenta o próximo
4. **Modular code generation:** Sub-funções nomeadas > monolitos
5. **AI tests are cheap:** Gerar testes é mais fácil que gerar soluções
6. **Surgical refinement:** Corrigir sub-função específica > reescrever tudo

## Adaptações para Claude Code

| AlphaCodium Original | Nossa Adaptação |
|---------------------|-----------------|
| CodeContests (competitive programming) | Tasks de engenharia de software real |
| API calls fixas (GPT-4) | Claude Code com tools (Read, Edit, Bash) |
| Pass@5 (5 tentativas) | Pass@1 com iteração interna |
| Testes unitários puros | Testes + validação visual + lint |
| Sem contexto de codebase | Integrado com Glob, Grep, Read para contexto completo |

## Fontes Complementares

- [Qodo Blog: System 2 Thinking](https://www.qodo.ai/blog/system-2-thinking-alphacodium-outperforms-direct-prompting-of-openai-o1/)
- [Analytics Vidhya: AlphaCodium Analysis](https://www.analyticsvidhya.com/blog/2024/01/codiumais-alphacodium-outperforms-deepminds-alphacode-in-ai-code-generation/)
- [SWE-bench](https://www.swebench.com/) — Framework de benchmark que inspira nosso corpus
