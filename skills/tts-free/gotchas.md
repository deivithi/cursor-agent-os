# gotchas — tts-free (edge-tts)

## 1. Limite de caracteres por chamada
- **Máximo seguro:** ~5000 caracteres por chamada
- **Solução:** Para textos longos, dividir em chunks de 4000 chars e concatenar os MP3s com FFmpeg:
  ```bash
  # Gerar partes
  edge-tts --voice pt-BR-FranciscaNeural --text "$PART1" --write-media part1.mp3
  edge-tts --voice pt-BR-FranciscaNeural --text "$PART2" --write-media part2.mp3
  # Concatenar
  printf "file 'part1.mp3'\nfile 'part2.mp3'" > list.txt
  ffmpeg -f concat -safe 0 -i list.txt -c copy final.mp3
  ```

## 2. Requer internet
- edge-tts usa o serviço online do Microsoft Edge — **não funciona offline**
- Se a conexão cair, o comando falha silenciosamente ou com timeout
- **Diagnóstico:** `edge-tts --list-voices` — se retorna vazio, problema de rede

## 3. Rate limiting
- Microsoft não documenta limites exatos, mas uso muito intensivo (centenas de chamadas/minuto) pode resultar em throttling
- **Mitigação:** Espaçar chamadas em batch com `sleep 1` entre elas
- Para uso normal (dezenas de chamadas/dia) não há problema

## 4. Encoding de caracteres especiais
- Em Windows/Git Bash, caracteres acentuados no `--text` podem corromper
- **Solução:** Salvar texto em arquivo UTF-8 e ler com `$(cat arquivo.txt)`
- Alternativa: usar Python script em vez de CLI para textos com muitos acentos

## 5. Formato de saída
- Output padrão é MP3 (codec interno do edge-tts)
- Para WAV ou outros formatos, converter com FFmpeg após geração:
  ```bash
  ffmpeg -i audio.mp3 -acodec pcm_s16le audio.wav
  ```

## 6. Legendas SRT vs VTT
- `--write-subtitles` detecta formato pela extensão: `.srt` ou `.vtt`
- SRT: compatível com a maioria dos players e editores de vídeo
- VTT: melhor para web (HTML5 `<track>`)
- **Regra:** Usar `.srt` por padrão (mais universal)

## 7. Vozes multilíngues
- Vozes com sufixo `MultilingualNeural` suportam múltiplos idiomas no mesmo texto
- Vozes sem esse sufixo podem pronunciar palavras estrangeiras com sotaque forte
- **Regra:** Para textos misturando PT-BR e EN, usar `ThalitaMultilingualNeural`
