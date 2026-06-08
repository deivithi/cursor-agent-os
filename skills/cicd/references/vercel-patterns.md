# ▲ Vercel Patterns

> Referência rápida para operações comuns no Vercel.

## Deploy

```bash
# Preview deploy (staging)
npx vercel --yes

# Production deploy
npx vercel --prod --yes

# Deploy de diretório específico
cd Aria && npx vercel --prod --yes
```

## Env Vars

```bash
# Listar
npx vercel env ls

# Adicionar
npx vercel env add NOME_VAR production    # Apenas produção
npx vercel env add NOME_VAR preview       # Apenas preview
npx vercel env add NOME_VAR development   # Apenas dev

# Remover
npx vercel env rm NOME_VAR production
```

## Rollback

```bash
# Listar deploys recentes
npx vercel ls | head -10

# Promover deploy anterior como produção
npx vercel promote <deployment-url> --yes

# Inspecionar deploy
npx vercel inspect <deployment-url>
```

## Logs

```bash
# Runtime logs (TTL: 1h no Hobby/Pro)
npx vercel logs <deployment-url> | head -30

# Build logs
npx vercel inspect <deployment-url>
```

## Domains

```bash
# Listar domínios
npx vercel domains ls

# Adicionar domínio
npx vercel domains add exemplo.com

# Remover domínio
npx vercel domains rm exemplo.com
```

## Gotchas Vercel

1. **`--prod` deploya branch atual**, não necessariamente main
2. **Logs expiram em 1h** no plano Hobby — capturar imediatamente
3. **Cold start** pode causar timeout na primeira request
4. **Serverless functions** têm limite de 10s (Hobby) / 60s (Pro)
5. **Build output** máximo de 100MB (Hobby)
