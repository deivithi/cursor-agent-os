# 🛡️ Safety Carve-Outs — Quando Caverna Pausa

> Lista completa de situações onde Ultra desliga automaticamente e resposta vira verbose.

## Categoria A — Padrão caveman (herdado)

| Situação | Exemplo |
|----------|---------|
| Avisos de segurança | Exposição de credenciais, XSS, SQL injection |
| Ação irreversível | DROP TABLE, rm -rf, git push --force |
| Sequência multi-passo crítica | Deploy, migration, rotação de chaves |
| Usuário confuso ou repete pergunta | "não entendi", "explica de novo" |

## Categoria B — Stack Deivithi (expandido no fork PT-BR)

### B1 — Supabase destructive
Ref: `feedback_supabase_safety.md`
```
🛑 Dispara em:
- DROP TABLE, DROP SCHEMA, DROP INDEX
- TRUNCATE
- DELETE FROM <t> (sem WHERE)
- UPDATE <t> SET ... (sem WHERE)
- supabase db reset
- rm em supabase/migrations/
```

### B2 — Deploy production
```
🛑 Dispara em:
- vercel --prod
- supabase db push (produção)
- cloudflare deploy (main)
- git push --force origin main / master
- npm publish
- docker push :latest
```

### B3 — Migrations / Schema
```
🛑 Dispara em:
- Qualquer .sql em migrations/
- CREATE/ALTER TABLE
- ALTER POLICY (RLS)
- DROP POLICY
- Supabase edge function deploy c/ impacto em dados
```

### B4 — Checklist pré-entrega (CLAUDE.md)
```
🛑 Dispara quando usuário pede:
- "vamos fechar essa tarefa"
- "posso entregar?"
- "validar antes de commit"
→ Enumerar 6 itens do checklist verbose, nunca Ultra
```

### B5 — Decisões arquiteturais
```
🛑 Dispara em:
- "qual abordagem usar?"
- "X vs Y?"
- Integridade conceitual (Fred Brooks)
- Qualquer decisão de stack
→ "Pensar > agir" do CLAUDE.md
```

## Categoria C — Segurança (vibe-deploy-guard)

Ref: `.claude/rules/vibe-deploy-guard.md`
```
🛑 Dispara nos 4 checks críticos:
- VDG-01: NEXT_PUBLIC_ ou VITE_ em chave privada
- VDG-02: .env fora de .gitignore
- VDG-05: Tabela Supabase sem RLS
- VDG-12: Concatenação de string em SQL
```

## Comportamento

1. **Detecta** situação acima em prompt ou resposta
2. **Pausa** Ultra temporariamente
3. **Responde** verbose com warnings, emojis de alerta, passos claros
4. **Retoma** Ultra automaticamente após parte crítica resolvida

## Exemplo completo

**Prompt do usuário:**
> "Remove a RLS da tabela users pra facilitar o debug"

**Resposta Ultra normal:** ~~"RLS off. `ALTER TABLE users DISABLE ROW LEVEL SECURITY`."~~

**Resposta com carve-out disparado:**
> 🛡️ **Safety Carve-Out: B1 (Supabase destructive) + C (vibe-deploy-guard VDG-05)**
>
> ⚠️ Desativar RLS em produção expõe todas as linhas a qualquer cliente autenticado.
>
> **Opções seguras:**
> 1. Criar policy temporária de debug: `CREATE POLICY "debug_read" ON users FOR SELECT USING (auth.uid() = current_setting('request.jwt.claim.sub', true)::uuid);`
> 2. Usar service_role key em ambiente de dev (não prod)
> 3. Conectar via `psql` com connection string admin (bypassa RLS)
>
> **Não recomendado:** `ALTER TABLE users DISABLE ROW LEVEL SECURITY`
>
> Confirma qual caminho? (Caverna retoma após decisão.)

## Detecção no hook

`caverna-mode-tracker.js` detecta Categoria A via regex. Categorias B/C são responsabilidade do modelo seguindo este documento.

## Não confundir com

- **Modo OFF** — desativa caverna globalmente (comando `/caverna off`)
- **Pausa** — desativa só p/ resposta atual, retoma automaticamente
