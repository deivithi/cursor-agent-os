---
name: music-gen-free
description: >
  Geração de música gratuita via HuggingFace Spaces (MusicGen, ACE-Step) ou local (ACE-Step DiT-only 4GB VRAM).
  Zero custo. Experimental — depende de disponibilidade de Spaces e limites de VRAM local.
  Triggers: "gerar música", "criar música", "text to music", "trilha sonora",
  "background music", "jingle", "instrumental", "beat", "música IA".
license: MIT
metadata:
  version: "1.0"
  category: media-generation
  engine: HuggingFace Spaces + ACE-Step 1.5 (opcional)
  cost: zero
  requires_gpu: false (cloud) / 4GB VRAM mínimo (local)
  status: experimental
---

# music-gen-free

Geração de música via IA — cloud (HuggingFace Spaces) ou local (ACE-Step 1.5).

> **Status: EXPERIMENTAL.** A rota cloud depende de Spaces gratuitos (uptime não garantido). A rota local requer 4GB VRAM mínimo (GTX 1050 Ti = apertado mas possível em modo DiT-only).

---

## Route Table

| Intent do usuário | Rota | Ferramenta |
|---|---|---|
| Gerar música curta (até 30s) | **HF_MUSICGEN** | HuggingFace Space MusicGen |
| Gerar música com letras | **HF_ACESTEP** | HuggingFace Space ACE-Step |
| Gerar música local | **LOCAL** | ACE-Step 1.5 instalado localmente |
| Manipular áudio existente | **FFMPEG** | FFmpeg (cortar, mixar, fade) |

---

## Rota HF_MUSICGEN — HuggingFace Spaces (Recomendada)

Mais estável, sem instalação local, processamento na nuvem.

### Spaces recomendados

| Space | Modelo | Duração max | Qualidade |
|---|---|---|---|
| `facebook/MusicGen` | MusicGen Large | ~30s | Alta |
| `fffiloni/MusicGen-Continuation` | MusicGen + continuação | ~60s | Alta |

### Como usar

```
Usar: mcp__claude_ai_Hugging_Face__dynamic_space
- space_id: "facebook/MusicGen"
- inputs: { "text": "upbeat corporate background music, inspiring, no vocals" }
```

### Boas práticas para prompts de música

```
# Estrutura
[gênero], [mood], [instrumentos], [tempo], [vocal/instrumental]

# Exemplos
"upbeat corporate background music, piano and strings, 120 bpm, no vocals"
"calm lo-fi hip hop beat, soft piano, vinyl crackle, relaxing, instrumental"
"energetic electronic dance music, synths, driving bass, 128 bpm"
"acoustic guitar ballad, warm, emotional, fingerpicking, slow tempo"
"epic cinematic orchestral score, dramatic, brass section, timpani, building crescendo"
```

**Regras:**
- Prompts em inglês (modelos treinados em EN)
- Especificar "no vocals" / "instrumental" se não quiser voz
- Incluir BPM para controle de tempo
- Mencionar instrumentos específicos melhora resultado

---

## Rota LOCAL — ACE-Step 1.5 (Opcional)

> **Só instalar se precisar de geração frequente ou offline.**

### Pré-requisitos (GTX 1050 Ti — modo conservador)

```bash
# Instalar uv (package manager)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Clonar e instalar
git clone https://github.com/ACE-Step/ACE-Step-1.5.git
cd ACE-Step-1.5
uv sync

# Windows: instalar triton
pip install triton-windows
```

### Configuração para 4GB VRAM

```bash
# DiT-only mode (sem LLM, cabe em 4GB)
python app.py --dit-only --offload
```

**Limitações com 4GB:**
- Modo DiT-only apenas (sem processamento de letras avançado)
- Geração mais lenta (offload CPU↔GPU)
- Máximo ~30s de áudio por geração
- Fechar outros apps que usam GPU antes de gerar

---

## Rota FFMPEG — Manipulação de Áudio

Para quando já se tem música e precisa editar.

```bash
# Cortar trecho (do segundo 10 ao 40)
ffmpeg -i music.mp3 -ss 00:00:10 -to 00:00:40 -c copy excerpt.mp3

# Fade in (3s) + fade out (3s, começando no segundo 27)
ffmpeg -i music.mp3 -af "afade=t=in:ss=0:d=3,afade=t=out:st=27:d=3" faded.mp3

# Loop de música (repetir 3x)
ffmpeg -stream_loop 2 -i music.mp3 -c copy looped.mp3

# Mixar narração + música de fundo
ffmpeg -i narration.mp3 -i background.mp3 \
  -filter_complex "[1:a]volume=0.15[bg];[0:a][bg]amix=inputs=2:duration=first[out]" \
  -map "[out]" mixed.mp3

# Converter formato
ffmpeg -i music.wav -c:a libmp3lame -q:a 2 music.mp3
```

---

## Integração com Outras Skills

| Combinação | Pipeline |
|---|---|
| music-gen-free → **video-compose** | Música de fundo → compor em vídeo |
| **tts-free** + music-gen-free → **video-compose** | Narração + música → vídeo completo |
| music-gen-free → FFmpeg mix | Música + narração → áudio mixado |

---

## Limites Conhecidos

- **HF Spaces:** Cold starts (30-60s), filas em horários de pico, uptime não garantido
- **MusicGen:** Máximo ~30s por geração (limitação do modelo)
- **ACE-Step local:** 4GB VRAM é o mínimo absoluto — pode ter OOM em gerações longas
- **Qualidade:** Inferior a serviços pagos (Suno, Udio) para músicas complexas com vocais
- **Sem vocais reais:** Modelos gratuitos geram instrumental; vocais são sintéticos/limitados
- **Licenciamento:** Verificar licença do modelo para uso comercial (MusicGen = CC-BY-NC)
