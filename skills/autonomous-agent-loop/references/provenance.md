# 📜 Proveniência — Autonomous Agent Loop

## Fonte Original
- **Repositório:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch)
- **Autor:** Andrej Karpathy (ex-diretor de IA Tesla, co-fundador OpenAI)
- **Data de criação:** 06/03/2026
- **Data de extração:** 18/03/2026
- **Licença do original:** Nenhuma declarada (⚠️)

## O que foi extraído
Padrões arquiteturais de design de agentes autônomos — **NÃO** código fonte.
Esta skill contém **conhecimento generalizado**, não cópia de implementação.

## 10 Padrões Extraídos
1. Loop Autônomo Infinito (The Forever Loop)
2. Métrica Única de Sucesso (Single Source of Truth)
3. Separação Imutável vs Modificável (The Firewall)
4. Experimentos Time-Boxed (Fixed Budget)
5. Logging Estruturado (The Ledger)
6. Keep/Discard/Crash — Protocolo de Decisão
7. Critério de Simplicidade (Simplicity Wins)
8. Controle de Blast Radius
9. Program.md — Instruções para Agentes
10. Git como Sistema de Experimentos

## Contexto Original
- Karpathy treina modelos GPT (~50M params) em loop autônomo
- Cada experimento: 5 min numa GPU NVIDIA
- ~12 experimentos/hora, ~100 por noite
- Agente modifica APENAS `train.py`, avaliação em `prepare.py` é imutável
- Métrica: `val_bpb` (validation bits per byte) — menor = melhor

## Adaptação Realizada
Os padrões foram **generalizados** para qualquer domínio:
- ML → Vendas (scoring de leads)
- ML → Marketing (A/B testing de emails)
- ML → Operações (otimização de SLA)
- ML → Qualquer sistema com métricas mensuráveis

## Alinhamento com Princípios do Workspace
- ✅ Integridade Conceitual (Fred Brooks) → Padrão 7 (Simplicidade)
- ✅ "Pensar é Caro" (Ronnald Hawk) → Padrão 9 (Program.md)
- ✅ Zero Frankenstein → Padrão 8 (Blast Radius)
- ✅ Sistemas de Verdade → Padrão 3 (Firewall imutável vs modificável)
