---
name: video-compose
description: >
  Composição de vídeos a partir de imagens + áudio via FFmpeg. Zero custo, 100% local.
  Cria vídeos para social media, apresentações narradas, slideshows e content marketing.
  Integra com tts-free (narração) e image-gen-free (imagens).
  Triggers: "criar vídeo", "montar vídeo", "slideshow", "vídeo com narração",
  "imagens para vídeo", "MP4", "reel", "shorts", "vídeo social media".
license: MIT
metadata:
  version: "1.0"
  category: media-generation
  engine: FFmpeg 8.1
  cost: zero
  requires_gpu: false
---

# video-compose

Composição de vídeos com FFmpeg — imagens + áudio → MP4 profissional. 100% local, zero custo.

## Pré-requisitos

```bash
ffmpeg -version    # FFmpeg 8.1 — JÁ INSTALADO
```

---

## Route Table

| Intent do usuário | Rota | Pipeline |
|---|---|---|
| Imagem estática + áudio → vídeo | **STILL** | Uma imagem + MP3 → MP4 |
| Slideshow de imagens | **SLIDESHOW** | N imagens → MP4 com transições |
| Slideshow + narração | **NARRATED** | N imagens + TTS → MP4 sincronizado |
| Concatenar vídeos | **CONCAT** | N vídeos → 1 vídeo |
| Adicionar áudio a vídeo | **AUDIO** | Vídeo + MP3 → MP4 com áudio |
| Adicionar legendas | **SUBTITLES** | Vídeo + SRT → MP4 com subs |

---

## Rota STILL — Imagem + Áudio → Vídeo

Caso mais comum: uma imagem de fundo + narração TTS = vídeo para social media.

```bash
# Com imagem de fundo existente
ffmpeg -loop 1 -i background.png -i narration.mp3 \
  -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
  -shortest -pix_fmt yuv420p \
  output.mp4

# Com cor sólida como fundo (sem imagem)
ffmpeg -f lavfi -i "color=c=0x1a1a2e:s=1920x1080:d=300" -i narration.mp3 \
  -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
  -shortest -pix_fmt yuv420p \
  output.mp4
```

**Flags importantes:**
- `-loop 1`: repete a imagem pela duração do áudio (APENAS com input de imagem, não MP3)
- `-f lavfi -i "color=..."`: gera fundo de cor sólida (alternativa quando não há imagem)
- `-shortest`: termina quando o stream mais curto acaba
- `-pix_fmt yuv420p`: compatibilidade máxima com players
- `-tune stillimage`: otimiza encoding para imagem estática

> **GOTCHA:** `-loop 1` só funciona com inputs de imagem (PNG/JPG), não com áudio. Para vídeo sem imagem de fundo, usar `lavfi color`.

---

## Rota SLIDESHOW — Múltiplas Imagens

### Duração fixa por slide (5s cada)
```bash
ffmpeg -framerate 1/5 -i slide_%03d.png \
  -c:v libx264 -r 30 -pix_fmt yuv420p \
  slideshow.mp4
```

### Com crossfade entre slides (2s transição)
```bash
# Gerar slides com duração + transição via filter_complex
ffmpeg -loop 1 -t 5 -i slide1.png -loop 1 -t 5 -i slide2.png -loop 1 -t 5 -i slide3.png \
  -filter_complex \
  "[0][1]xfade=transition=fade:duration=1:offset=4[v01]; \
   [v01][2]xfade=transition=fade:duration=1:offset=8[v]" \
  -map "[v]" -c:v libx264 -pix_fmt yuv420p \
  slideshow_fade.mp4
```

**Transições disponíveis:** `fade`, `wipeleft`, `wiperight`, `wipeup`, `wipedown`, `slideleft`, `slideright`, `circlecrop`, `dissolve`, `pixelize`, `diagtl`, `diagtr`

---

## Rota NARRATED — Pipeline Completo

Pipeline mais poderoso: imagens geradas + narração TTS → vídeo profissional.

### Passo 1: Gerar narração (skill tts-free)
```bash
edge-tts --voice pt-BR-FranciscaNeural \
  --text "Bem-vindos ao nosso evento..." \
  --write-media narration.mp3 \
  --write-subtitles narration.srt
```

### Passo 2: Obter duração do áudio
```bash
ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 narration.mp3
```

### Passo 3: Compor vídeo
```bash
# Imagem única + narração
ffmpeg -loop 1 -i background.png -i narration.mp3 \
  -c:v libx264 -tune stillimage -c:a aac -b:a 192k \
  -shortest -pix_fmt yuv420p \
  video.mp4
```

### Passo 4: Adicionar legendas (opcional)
```bash
ffmpeg -i video.mp4 -vf "subtitles=narration.srt:force_style='FontSize=24,PrimaryColour=&HFFFFFF,OutlineColour=&H000000,Outline=2'" \
  -c:a copy \
  video_subtitled.mp4
```

---

## Rota CONCAT — Juntar Vídeos

```bash
# Criar lista de arquivos
printf "file 'part1.mp4'\nfile 'part2.mp4'\nfile 'part3.mp4'" > concat_list.txt

# Concatenar (se mesmo codec/resolução)
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy output.mp4
```

---

## Rota AUDIO — Adicionar/Trocar Áudio

```bash
# Adicionar áudio a vídeo sem som
ffmpeg -i video.mp4 -i music.mp3 \
  -c:v copy -c:a aac -b:a 192k -shortest \
  output.mp4

# Mixar áudio existente com música de fundo (narração 80%, música 20%)
ffmpeg -i video_narrated.mp4 -i background_music.mp3 \
  -filter_complex "[0:a]volume=1.0[a1];[1:a]volume=0.2[a2];[a1][a2]amix=inputs=2:duration=first[aout]" \
  -map 0:v -map "[aout]" -c:v copy -c:a aac \
  output_mixed.mp4
```

---

## Rota SUBTITLES — Embutir Legendas

```bash
# Legendas hardcoded (queimadas no vídeo)
ffmpeg -i video.mp4 \
  -vf "subtitles=subs.srt:force_style='FontName=Arial,FontSize=22,PrimaryColour=&HFFFFFF,OutlineColour=&H000000,Outline=2,Shadow=1'" \
  -c:a copy \
  output.mp4

# Legendas como stream separado (soft subs)
ffmpeg -i video.mp4 -i subs.srt \
  -c:v copy -c:a copy -c:s mov_text \
  output.mp4
```

---

## Presets de Output por Plataforma

| Plataforma | Resolução | Aspect | Comando extra |
|---|---|---|---|
| **Instagram Reels/Stories** | 1080x1920 | 9:16 | `-vf scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2` |
| **YouTube** | 1920x1080 | 16:9 | `-vf scale=1920:1080` |
| **Twitter/X** | 1280x720 | 16:9 | `-vf scale=1280:720` |
| **LinkedIn** | 1920x1080 | 16:9 | `-vf scale=1920:1080` |
| **TikTok** | 1080x1920 | 9:16 | Mesmo que Instagram |
| **Quadrado** | 1080x1080 | 1:1 | `-vf scale=1080:1080` |

---

## Integração com Outras Skills

| Combinação | Pipeline |
|---|---|
| **tts-free** → video-compose | Texto → MP3 + SRT → Vídeo narrado com legendas |
| **image-gen-free** → video-compose | Prompt → Imagens → Slideshow |
| **image-gen-free** + **tts-free** → video-compose | Prompt → Imagens + Narração → Vídeo completo |
| **minimax-pdf** → video-compose | Slides do PDF → Vídeo apresentação |
| **data-charts** → video-compose | Gráficos → Vídeo animado com dados |
