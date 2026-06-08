# FFmpeg Patterns — Referência Rápida

## Obter informações de um arquivo
```bash
# Duração
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4

# Resolução
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 input.mp4

# Info completa
ffprobe -v quiet -print_format json -show_format -show_streams input.mp4
```

## Converter formatos
```bash
# MP4 → WebM
ffmpeg -i input.mp4 -c:v libvpx-vp9 -c:a libopus output.webm

# MOV → MP4
ffmpeg -i input.mov -c:v libx264 -c:a aac output.mp4

# Extrair áudio de vídeo
ffmpeg -i video.mp4 -vn -c:a libmp3lame -q:a 2 audio.mp3

# Extrair frames de vídeo
ffmpeg -i video.mp4 -vf "fps=1" frame_%04d.png
```

## Redimensionar
```bash
# Resolução específica
ffmpeg -i input.mp4 -vf "scale=1920:1080" output.mp4

# Manter aspect ratio (largura fixa)
ffmpeg -i input.mp4 -vf "scale=1280:-2" output.mp4

# Pad para aspect ratio específico (letterbox)
ffmpeg -i input.mp4 -vf "scale=1080:1080:force_original_aspect_ratio=decrease,pad=1080:1080:(ow-iw)/2:(oh-ih)/2:black" output.mp4
```

## Cortar/Trimmar
```bash
# Cortar do segundo 10 ao 30
ffmpeg -i input.mp4 -ss 00:00:10 -to 00:00:30 -c copy output.mp4

# Primeiros 60 segundos
ffmpeg -i input.mp4 -t 60 -c copy output.mp4
```

## Overlay (texto, imagem)
```bash
# Texto no vídeo
ffmpeg -i input.mp4 -vf "drawtext=text='Título':fontsize=48:fontcolor=white:x=(w-text_w)/2:y=50:fontfile=/Windows/Fonts/arial.ttf" output.mp4

# Logo/watermark
ffmpeg -i input.mp4 -i logo.png -filter_complex "overlay=W-w-10:H-h-10" output.mp4
```

## GIF
```bash
# Vídeo → GIF otimizado
ffmpeg -i input.mp4 -vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif
```

## Áudio
```bash
# Normalizar volume
ffmpeg -i input.mp3 -af "loudnorm=I=-16:TP=-1.5:LRA=11" output.mp3

# Fade in/out (3s cada)
ffmpeg -i input.mp3 -af "afade=t=in:ss=0:d=3,afade=t=out:st=57:d=3" output.mp3

# Converter sample rate
ffmpeg -i input.mp3 -ar 44100 output.mp3
```

## Batch (múltiplos arquivos)
```bash
# Converter todos os PNG de um diretório para JPEG
for f in *.png; do ffmpeg -i "$f" "${f%.png}.jpg"; done

# Redimensionar todas as imagens para 1080px de largura
for f in *.png; do ffmpeg -i "$f" -vf "scale=1080:-2" "resized_$f"; done
```
