# gotchas — image-gen-free

## 1. Cold starts em Spaces gratuitos
- Spaces free dormem após ~15min de inatividade
- Primeira chamada após dormir: 30-60s para acordar (building/loading)
- **Mitigação:** Não depender de latência baixa; avisar o usuário que pode demorar

## 2. Prompts em inglês
- Modelos de imagem são treinados predominantemente em inglês
- Prompts em português geram resultados inconsistentes
- **Regra:** SEMPRE traduzir o intent do usuário para inglês antes de enviar ao modelo

## 3. Aspect ratio
- A maioria dos Spaces gera imagens quadradas por padrão (512x512 ou 1024x1024)
- Para 16:9 ou outros ratios, verificar se o Space aceita parâmetros de dimensão
- Alternativa: gerar quadrado e croppar com FFmpeg/ImageMagick

## 4. NSFW filters
- Spaces públicos têm filtros NSFW — podem rejeitar prompts ambíguos
- Se o filtro bloquear: reformular o prompt removendo ambiguidades

## 5. Qualidade inconsistente
- Resultados variam entre chamadas mesmo com o mesmo prompt
- Para melhor qualidade: adicionar "high quality, detailed, professional" ao prompt
- Gerar 2-3 variações e escolher a melhor

## 6. Formato de output
- Output geralmente é PNG ou JPEG dependendo do Space
- Para formato específico, converter após download com FFmpeg:
  ```bash
  ffmpeg -i input.png -q:v 2 output.jpg   # PNG → JPEG
  ffmpeg -i input.jpg output.webp          # → WebP (menor)
  ```

## 7. Tamanho de arquivo
- Imagens geradas podem ser grandes (2-5MB em PNG)
- Para web/social media, comprimir:
  ```bash
  ffmpeg -i large.png -vf scale=1200:-1 -q:v 3 optimized.jpg
  ```
