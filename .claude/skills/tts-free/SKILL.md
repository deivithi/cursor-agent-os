---
name: tts-free
description: >
  Text-to-Speech gratuito via edge-tts (vozes Microsoft Edge Neural).
  Zero custo, zero API key, CPU only. 400+ vozes, 100+ idiomas, PT-BR nativo.
  Triggers: "sintetizar voz", "text to speech", "TTS", "gerar áudio",
  "narrar", "fala", "voz", "edge-tts", "legendas SRT", "áudio MP3".
license: MIT
metadata:
  version: "1.0"
  category: media-generation
  engine: edge-tts 7.2.8
  cost: zero
  requires_gpu: false
---

# tts-free

Text-to-Speech profissional gratuito — vozes neurais Microsoft Edge, sem API key.

## Pré-requisitos

```bash
pip install edge-tts    # Já instalado
```

---

## Route Table

| Intent do usuário | Rota | Comando |
|---|---|---|
| Sintetizar fala (PT-BR feminina) | **DEFAULT** | `edge-tts --voice pt-BR-FranciscaNeural --text "..." --write-media output.mp3` |
| Sintetizar fala (PT-BR masculina) | **MALE** | `edge-tts --voice pt-BR-AntonioNeural --text "..." --write-media output.mp3` |
| Sintetizar com legendas | **SUBTITLES** | Adicionar `--write-subtitles output.srt` |
| Narrar arquivo de texto | **FILE** | Ler arquivo → passar conteúdo via `--text` |
| Listar vozes disponíveis | **VOICES** | `edge-tts --list-voices` |
| Voz em outro idioma | **CUSTOM** | Escolher voice ID da tabela de vozes |

---

## Vozes PT-BR (Padrão)

| Voice ID | Gênero | Personalidade |
|---|---|---|
| `pt-BR-FranciscaNeural` | Feminina | Amigável, positiva — **DEFAULT** |
| `pt-BR-AntonioNeural` | Masculino | Amigável, positivo |
| `pt-BR-ThalitaMultilingualNeural` | Feminina | Multilíngue (PT-BR + outros idiomas) |

## Vozes EN-US (Populares)

| Voice ID | Gênero | Estilo |
|---|---|---|
| `en-US-AriaNeural` | Feminina | Confiante, para notícias/narrativas |
| `en-US-AndrewMultilingualNeural` | Masculino | Quente, autêntico, multilíngue |
| `en-US-AvaMultilingualNeural` | Feminina | Expressiva, carinhosa, multilíngue |
| `en-US-BrianNeural` | Masculino | Casual, sincero |
| `en-US-JennyNeural` | Feminina | Amigável, considerada |

> Para lista completa: `edge-tts --list-voices` ou ver `references/voices.md`

---

## Parâmetros de Controle

| Parâmetro | Flag | Exemplos |
|---|---|---|
| Velocidade | `--rate` | `--rate=+20%` (mais rápido), `--rate=-10%` (mais lento) |
| Volume | `--volume` | `--volume=+50%`, `--volume=-30%` |
| Pitch | `--pitch` | `--pitch=+10Hz`, `--pitch=-5Hz` |
| Output áudio | `--write-media` | `--write-media audio.mp3` |
| Output legendas | `--write-subtitles` | `--write-subtitles subs.srt` ou `subs.vtt` |

---

## Exemplos Práticos

### 1. Narração simples PT-BR
```bash
edge-tts --voice pt-BR-FranciscaNeural \
  --text "Olá! Bem-vindo ao nosso canal." \
  --write-media narration.mp3
```

### 2. Com legendas sincronizadas
```bash
edge-tts --voice pt-BR-AntonioNeural \
  --text "Este é um teste com legendas." \
  --write-media audio.mp3 \
  --write-subtitles subtitles.srt
```

### 3. Velocidade ajustada
```bash
edge-tts --voice pt-BR-FranciscaNeural \
  --rate=+15% \
  --text "Texto mais rápido para conteúdo dinâmico." \
  --write-media fast.mp3
```

### 4. Texto longo (de arquivo)
```bash
# Ler conteúdo do arquivo e passar como texto
TEXT=$(cat script.txt)
edge-tts --voice pt-BR-FranciscaNeural \
  --text "$TEXT" \
  --write-media narration.mp3 \
  --write-subtitles narration.srt
```

### 5. Multilíngue (PT-BR + EN no mesmo áudio)
```bash
# Usar ThalitaMultilingualNeural para misturar idiomas
edge-tts --voice pt-BR-ThalitaMultilingualNeural \
  --text "Isso é incrível! This is amazing!" \
  --write-media multilingual.mp3
```

---

## Integração com Outras Skills

| Combinação | Pipeline |
|---|---|
| **video-compose** | TTS gera áudio → FFmpeg combina com imagens → MP4 |
| **minimax-pdf** | Extrair texto do PDF → TTS narra o conteúdo |
| **FIO-IA** | Gerar áudio das threads para formato podcast/reel |
| **landing pages** | Narrar demos, tutoriais, conteúdo acessível |

---

## Limites Conhecidos

- Requer internet (usa serviço Microsoft Edge online)
- Rate limiting em uso muito intensivo (ver `gotchas.md`)
- Sem clonagem de voz (vozes fixas do catálogo Microsoft)
- Máximo ~5000 caracteres por chamada (dividir textos maiores)
