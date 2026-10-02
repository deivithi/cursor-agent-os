---
name: ste-ptbr
description: >
  Português Técnico Simplificado (STE-PT) — adaptação PT-BR do ASD-STE100, a linguagem
  controlada da manutenção aeronáutica. Uma palavra = um sentido, voz ativa, imperativo em
  procedimento, máx. 20 palavras por passo e 25 por frase descritiva, dicionário de palavras
  não aprovadas com substituição obrigatória (registro burocrático + slop de IA + ambiguidade
  Febracis/Salesforce). Níveis 100 (estrito) e 80 ("80% do caminho", Karpathy). Inclui linter
  `scripts/ste_lint.py` para o gauntlet. Ativa com "STE", "ASD-STE100", "modo STE", "explica em
  STE", "STE 80", "linguagem controlada", "texto sem enrolação", "anti-slop", "/ste", e ao
  escrever runbook, procedimento, roteiro de homologação, mensagem de erro de Validation Rule,
  passo Gherkin ou comunicado para vendedores.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write
metadata:
  author: deivithi
  version: "1.0.0"
---

# ✈️ STE-PT — Português Técnico Simplificado

A aviação proibiu a ambiguidade no nível do dicionário em 1986. O leitor do manual podia morrer
se uma frase tivesse duas leituras. Esta skill aplica as mesmas regras ao português técnico do
ecossistema Febracis. O alvo é texto que um vendedor, um analista ou outro agente lê uma vez e
executa sem erro.

> Fonte: ASD-STE100 (asd-ste100.org, download grátis). Esta skill é uma **adaptação**, não uma
> tradução oficial. O dicionário PT-BR é nosso: `references/dicionario.json`.

## 📁 Estrutura

- `SKILL.md` — você está aqui.
- `references/regras.md` — as 9 seções de regras, com limites e exemplos.
- `references/dicionario.json` — palavras não aprovadas, palavras aprovadas e nomes técnicos. Fonte única do linter e da prancha.
- `assets/prancha-ste-pt.template.html` — prancha de referência com verificador (núcleo JS espelha o linter). `scripts/build_prancha.py` gera `assets/prancha-ste-pt.html`. Rode o build depois de editar o dicionário.
- `references/exemplos-febracis.md` — reescritas antes/depois (runbook, Validation Rule, Gherkin, e-mail).
- `scripts/ste_lint.py` — linter (stdlib). `tests/test_ste_lint.py` — gauntlet do linter.
- `gotchas.md` — falsos positivos e conflitos conhecidos.

## Quando usar

| Situação | Nível |
|---|---|
| Operador pede "explica em STE" / "modo STE" / `/ste` | 100 |
| Operador pede "STE 80" / "mais leve" / "80% do caminho" | 80 |
| Runbook, procedimento, roteiro de homologação, checklist de deploy | 100 |
| Mensagem de erro de Validation Rule, texto de tela Salesforce | 100 |
| Passo Gherkin (Dado/Quando/Então) | 100 |
| Comunicado para vendedores, e-mail operacional, README de procedimento | 80 |
| Relatório de auditoria (lead-audit, commission-audit) | 80 |

## Quando NÃO usar (→ handoff)

- Mensagem para o operador → não precisa desta skill. A regra sempre ativa `rules/ste-comunicacao.md` já aplica o STE-PT nível 80 em toda mensagem, sem comando. **STE e caverna não se misturam:** a caverna corta artigos e o STE proíbe cortar artigos.
- Texto de marketing, copy de evento, post → `brand-voice` / agency `marketing/`. STE mata o tom persuasivo.
- Código, commit, PR → `clean-code-rules`, `caverna-commit`.

## Workflow

1. **Classifique o texto.** Procedimento (passo a passo) ou descritivo (explicação).
2. **Escreva com as regras** de `references/regras.md`. Resumo abaixo.
3. **Rode o linter.**
   ```bash
   PYTHONIOENCODING=utf-8 py skills/ste-ptbr/scripts/ste_lint.py arquivo.md --nivel 100
   ```
   Texto em chat: grave em arquivo temporário no scratchpad e rode o linter nele.
4. **Corrija até zero erro.** Aviso pode ficar, com motivo.
5. **Reporte** a linha de resultado do linter junto da entrega (gauntlet).

## Regras em 1 tela

| # | Regra | Nível 100 | Nível 80 |
|---|---|---|---|
| 1 | Palavra aprovada, um sentido por palavra, mesma palavra para a mesma coisa | erro | registro = aviso |
| 2 | Grupo nominal com no máximo 3 palavras de conteúdo | aviso | aviso |
| 3 | Imperativo em procedimento; sem gerundismo; sem "deverá" | erro | aviso |
| 3b | Futuro do pretérito ("deveria", "poderia") | aviso | aviso |
| 4 | Procedimento ≤ 20 palavras; descritivo ≤ 25 | erro | 25 / 30 |
| 5 | Uma instrução por passo; condição primeiro ("Se X, faça Y") | erro | erro |
| 6 | Parágrafo ≤ 6 frases; primeira frase diz o tópico | erro | 8 frases |
| 7 | Aviso de segurança: comando primeiro, risco depois | — | — |
| 8 | Número exato; sem "etc."; sem "e/ou" | erro | erro |
| 9 | Voz ativa | erro em procedimento | aviso |

**Avisos de segurança (regra 7), adaptados ao nosso risco:**

- `⛔ BLOQUEIO:` risco de perda irreversível de dados (DROP, DELETE em massa, deploy em produção, LGPD). Liga com `human-architectural-gate.md`.
- `⚠️ ATENÇÃO:` risco de dado errado ou retrabalho (comissão, duplicado, regra de lead do Método CIS).

```
⛔ BLOQUEIO: Não rode DELETE sem WHERE. O comando exclui a tabela inteira.
```

## Integração com as rules

| Rule | Como o STE-PT se encaixa |
|---|---|
| `calibration.md` | O rótulo `[conf: X]` não conta palavra. Palavra vaga ("provavelmente") sai; o rótulo fica. |
| `gauntlet-protocol.md` | O linter é o check objetivo do texto. Resultado entra no report de gauntlet. |
| `anti-sycophancy.md` | Slop ("vale ressaltar", "robusto") é erro nos dois níveis. |
| `pt-br-acentos.md` | Acento obrigatório. Termo técnico EN (deploy, org, job) é nome técnico aprovado. |
| `human-architectural-gate.md` | `⛔ BLOQUEIO` é o formato do aviso nos domínios do gate. |

## Gotchas

⚠️ Consulte `gotchas.md`. Principais:

1. **"O lead é duplicado"** é estado, não voz passiva. O linter só marca "é + particípio" com agente ("por/pelo").
2. **"Se o lead for duplicado"** usa futuro do subjuntivo. É aprovado em condição.
3. **O linter não detecta sentido.** "Próximo" (seguinte) vs "próximo" (perto) exige revisão do agente.

## Referências

- ASD-STE100 — https://www.asd-ste100.org (especificação oficial, download grátis com cadastro)
- Andrej Karpathy — sugestão de pedir saída em ASD-STE100, ou "80% do caminho" até ele.
