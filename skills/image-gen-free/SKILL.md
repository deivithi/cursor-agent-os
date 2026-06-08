---
name: image-gen-free
description: >
  Geração de imagens gratuita via HuggingFace Spaces (cloud, sem GPU local).
  Zero custo, sem API key paga. Usa MCP HuggingFace (dynamic_space) para rodar
  modelos text-to-image em Spaces gratuitos. Triggers: "gerar imagem", "criar imagem",
  "text to image", "ilustração", "arte IA", "thumbnail", "banner", "social media image".
license: MIT
metadata:
  version: "1.0"
  category: media-generation
  engine: HuggingFace Spaces (free tier)
  cost: zero
  requires_gpu: false
---

# image-gen-free

Geração de imagens via HuggingFace Spaces gratuitos — processamento na nuvem HF, zero GPU local.

## Pré-requisitos

- MCP HuggingFace conectado (usuário: Deivithi77) — **JÁ ATIVO**
- Nenhuma instalação local necessária

---

## Route Table

| Intent do usuário | Rota | Ferramenta |
|---|---|---|
| Gerar imagem a partir de texto | **GENERATE** | `mcp__claude_ai_Hugging_Face__dynamic_space` |
| Buscar modelos de imagem | **SEARCH** | `mcp__claude_ai_Hugging_Face__space_search` |
| Detalhes de um modelo | **DETAILS** | `mcp__claude_ai_Hugging_Face__hub_repo_details` |

---

## Rota GENERATE — Pipeline Padrão

### Passo 1: Escolher Space

Spaces recomendados (gratuitos, populares, estáveis):

| Space | Modelo | Qualidade | Velocidade |
|---|---|---|---|
| `evalstate/flux1_schnell` | FLUX.1 schnell | Alta | Rápido (~15s) — **TESTADO** |
| `mcp-tools/FLUX.1-Krea-dev` | FLUX Krea | Muito alta (fotorrealista) | Médio (~30s) |
| `mcp-tools/Qwen-Image` | Qwen Image | Alta (bom com texto) | Médio |
| `mcp-tools/Qwen-Image-Fast` | Qwen Image Fast | Alta | Rápido |

### Passo 2: Gerar via Gradio Client (Python)

> **IMPORTANTE:** O MCP `dynamic_space` tem `invoke` desabilitado. Usar `gradio_client` (já instalado) via Python.

```python
from gradio_client import Client
import shutil

client = Client('evalstate/flux1_schnell')
result = client.predict(
    prompt='<descrição detalhada em inglês>',
    seed=0,
    randomize_seed=True,
    width=1280,
    height=720,
    num_inference_steps=4,
    api_name='/infer'
)

# result é tupla: (caminho_temp_imagem, seed_info)
img_path = result[0] if isinstance(result, tuple) else result
shutil.copy2(str(img_path), 'output.webp')
```

### Passo 3: Salvar output

O Gradio client salva em diretório temporário. Copiar para o destino desejado com `shutil.copy2`.
Output padrão: `.webp` (converter com FFmpeg se precisar de PNG/JPG).

---

## Boas Práticas para Prompts

### Estrutura de prompt eficaz
```
[Sujeito principal], [estilo/meio], [iluminação], [composição], [detalhes]
```

### Exemplos
```
"Professional headshot of a business woman, studio lighting, 
sharp focus, neutral background, corporate style, 8k quality"

"Minimalist logo design for a finance app called Pulso, 
clean lines, gradient purple to blue, flat design, vector style"

"Social media banner for coaching event, energetic crowd, 
motivational atmosphere, warm golden lighting, 16:9 aspect ratio"
```

### Regras
- **SEMPRE** prompts em inglês (modelos treinados em EN)
- Ser específico: "studio photo of a cat" > "cat"
- Incluir estilo desejado: "watercolor", "photorealistic", "flat design", "3D render"
- Incluir qualidade: "high resolution", "8k", "detailed", "sharp"
- Para aspect ratio específico, mencionar no prompt: "16:9 aspect ratio", "square format"

---

## Integração com Outras Skills

| Combinação | Pipeline |
|---|---|
| **video-compose** | Gerar imagens → FFmpeg combina com áudio → MP4 |
| **tts-free** | Imagem + narração TTS → vídeo narrado |
| **minimax-pdf** | Gerar ilustrações para relatórios/propostas |
| **FIO-IA** | Gerar arte para threads no X |
| **landing pages** | Hero images, banners, ícones |

---

## Limites Conhecidos

- **Cold starts:** Spaces gratuitos dormem após inatividade — primeira chamada pode levar 30-60s
- **Filas:** Em horários de pico, pode haver fila de espera no Space
- **Rate limit:** Free tier HF tem limites (não documentados exatamente), mas uso normal funciona
- **Sem uptime garantido:** Spaces podem ficar offline temporariamente
- **Resolução:** Depende do modelo — geralmente 512x512 a 1024x1024
- **Sem API key local:** Usa autenticação HF via MCP (já configurado)

## Fallback

Se o Space principal estiver offline:
1. Tentar outro Space da tabela
2. Usar `space_search` para encontrar alternativas ativas
3. Para design/branding: considerar Canva MCP como alternativa
