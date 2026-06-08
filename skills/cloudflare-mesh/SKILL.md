# Cloudflare Mesh — Rede Privada do Ecossistema

> Ativa quando: **mesh**, **rede privada**, **cloudflare mesh**, **WARP**, **VPC network**, **Workers VPC**, **conectar serviços**, **private network**.

## O que é

Cloudflare Mesh cria uma rede privada many-to-many entre devices, servidores (Mesh Nodes) e Workers. Cada participante recebe um **Mesh IP** (`100.96.0.0/12`) e pode acessar qualquer outro via TCP, UDP ou ICMP — sem VPN, sem portas expostas.

- **Client devices** — Windows/macOS/Linux/mobile com Cloudflare One Client (GUI)
- **Mesh Nodes** — Servidores **Linux** com `warp-cli` headless (route subnets)
- **Workers** — Via VPC Network binding (`cf1:network`)

## Nosso Setup

| Nó | Tipo | Mesh IP | Serviços expostos |
|----|------|---------|-------------------|
| **Windows PC (Deivithi)** | Client device | `100.96.x.x` (atribuído) | n8n (:5678), MCPs locais |
| **Aria Agent (Render)** | Mesh Node (Docker) | `100.96.x.x` (atribuído) | FastAPI (:$PORT) |
| **Workers (agents)** | VPC Network binding | N/A (usa `env.MESH.fetch()`) | Serverless |

**Conta:** `Deivithi74@gmail.com` (ID: `835df0321c49991d60155e4100840414`)
**Free tier:** 50 nós + 50 usuários

## Setup Passo-a-Passo

### 1. Ativar Mesh (dashboard — uma vez)

1. [Abrir Mesh](https://dash.cloudflare.com/?to=/:account/mesh)
2. **Add a node** → nome: `windows-pc` → **Create node**
3. Copiar o **TOKEN** gerado
4. Pode clicar "I'll connect later" se não quiser instalar agora

### 2. Instalar Cloudflare One Client no Windows

1. Baixar de https://1.1.1.1/ → Windows installer
2. Instalar e abrir
3. Selecionar **Zero Trust security**
4. Entrar team name da conta Cloudflare
5. Autenticar com `deivithi74@gmail.com`
6. Verificar: ícone Cloudflare One na taskbar = Connected

**Windows Firewall (obrigatório):**
```powershell
# Permitir tráfego Mesh inbound
New-NetFirewallRule -DisplayName "Cloudflare Mesh" -Direction Inbound -RemoteAddress 100.96.0.0/12 -Action Allow -Protocol Any
```

### 3. Verificar conectividade

```bash
# No Windows (Git Bash)
warp-cli status          # Deve mostrar: Status update: Connected
warp-cli settings        # Verificar IP privado atribuído
```

### 4. Aria Agent como Mesh Node (Render + Docker)

O Aria agent no Render usa o `Dockerfile.mesh` que inclui `cloudflare-warp`:

```dockerfile
# Ver Aria/agent/Dockerfile.mesh
```

**Deploy no Render:**
1. Render Dashboard → Aria Agent service → Settings
2. **Environment:** Docker
3. **Dockerfile Path:** `Dockerfile.mesh`
4. Adicionar env var: `MESH_TOKEN=<token do dashboard>`

### 5. Workers VPC (agents serverless)

```jsonc
// wrangler.jsonc
{
  "vpc_networks": [
    {
      "binding": "MESH",
      "network_id": "cf1:network",
      "remote": true
    }
  ]
}
```

```typescript
// Dentro do Worker
const response = await env.MESH.fetch("http://<MESH_IP>:5678/api/v1/workflows");
```

## Gateway Policies Recomendadas

| Policy | Regra | Destino |
|--------|-------|---------|
| n8n access | Allow `identity:agent` OR `device:deivithi` | `<PC_MESH_IP>:5678` |
| Default deny | Block all | `100.96.0.0/12` |

Configurar em: Dashboard → Gateway → Network Policies

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Node offline | `warp-cli status` → se não Connected: `warp-cli connect` |
| Client não alcança Mesh IPs | Verificar Split Tunnel inclui `100.96.0.0/12` |
| Windows firewall bloqueia | Criar regra inbound para `100.96.0.0/12` (ver acima) |
| Worker não conecta | Verificar que existe pelo menos 1 Mesh Node ou Tunnel ativo na conta |
| Render node não conecta | Verificar `MESH_TOKEN` env var e logs do container |

## Referências

- [Docs: Cloudflare Mesh](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-mesh/)
- [Docs: Get Started](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-mesh/get-started/)
- [Docs: Workers VPC Networks](https://developers.cloudflare.com/workers-vpc/configuration/vpc-networks/)
- [Docs: Connect Workers to Mesh](https://developers.cloudflare.com/workers-vpc/examples/connect-to-cloudflare-mesh/)
- [Blog: Announcing Mesh](https://blog.cloudflare.com/mesh/)

## Gotchas

1. **Mesh Nodes = Linux only** — Windows e macOS são apenas client devices (GUI)
2. **Mesh IP range = `100.96.0.0/12`** — não confundir com CGNAT `100.64.0.0/10`
3. **Workers VPC em beta** — features podem mudar antes do GA
4. **Free tier** — 50 nós + 50 usuários. Suficiente para nosso ecossistema atual
5. **Post-quantum encrypted** — todo tráfego mesh usa criptografia pós-quântica

## Related Skills

- `vibe-deploy-guard` — checklist de segurança pré-deploy (VDG-01 a VDG-18)
- `cicd` — workflow de deploy Vercel/Supabase
- `n8n-workflow-patterns` — padrões de workflow que se beneficiam de acesso mesh
