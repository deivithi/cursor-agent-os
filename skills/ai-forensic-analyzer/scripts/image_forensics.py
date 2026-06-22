#!/usr/bin/env python3
"""
AI Forensic Analyzer v2 — Pré-processamento Forense de Imagem

Extrai metadados e realiza análises forenses básicas em imagens:
- Extração de EXIF/XMP/ICC profile
- Error Level Analysis (ELA) — detecta regiões com níveis de compressão anômalos
- Análise de padrões de ruído
- Estimativa de origem (câmera real vs. geração sintética)

Dependências:
    pip install Pillow numpy

Uso:
    python image_forensics.py --input foto.jpg
    python image_forensics.py --input foto.png --output metrics.json
    python image_forensics.py --input foto.jpg --ela-quality 90

Output: JSON com metadados e métricas forenses.
"""

import argparse
import json
import io
import os
import struct
from pathlib import Path

try:
    from PIL import Image, ExifTags, TiffImagePlugin
    import numpy as np

    HAS_PIL = True
except ImportError:
    HAS_PIL = False


def extract_basic_info(filepath: str) -> dict:
    """Extrai informações básicas do arquivo (sem PIL)."""
    path = Path(filepath)
    stat = path.stat()

    info = {
        "filename": path.name,
        "size_bytes": stat.st_size,
        "size_kb": round(stat.st_size / 1024, 2),
        "size_mb": round(stat.st_size / (1024 * 1024), 4),
        "extension": path.suffix.lower(),
    }

    if not HAS_PIL:
        info["_warning"] = "Pillow não instalado. Metadados EXIF e ELA indisponíveis. Instale: pip install Pillow numpy"
        return info

    return info


def extract_exif(filepath: str) -> dict:
    """Extrai metadados EXIF, XMP e ICC profile da imagem."""
    if not HAS_PIL:
        return {"available": False, "error": "Pillow não instalado"}

    try:
        img = Image.open(filepath)
    except Exception as e:
        return {"available": False, "error": str(e)}

    exif_data = {"available": False, "data": {}, "warnings": []}

    try:
        raw_exif = img._getexif()
    except Exception:
        raw_exif = None

    if raw_exif:
        exif_data["available"] = True
        for tag_id, value in raw_exif.items():
            tag_name = ExifTags.TAGS.get(tag_id, f"Unknown_{tag_id}")
            if isinstance(value, bytes):
                value = f"<bytes: {len(value)} bytes>"
            elif isinstance(value, TiffImagePlugin.IFDRational):
                value = float(value)
            exif_data["data"][tag_name] = str(value)

    gps_data = {}
    if raw_exif:
        for tag_id, value in raw_exif.items():
            if ExifTags.TAGS.get(tag_id) == "GPSInfo":
                for gps_tag_id, gps_value in value.items():
                    gps_tag_name = ExifTags.GPSTAGS.get(gps_tag_id, f"GPS_{gps_tag_id}")
                    gps_data[gps_tag_name] = str(gps_value)
        if gps_data:
            exif_data["gps"] = gps_data

    img_info = {
        "format": img.format,
        "mode": img.mode,
        "width": img.width,
        "height": img.height,
        "ratio": f"{img.width}:{img.height}",
        "megapixels": round((img.width * img.height) / 1_000_000, 2),
    }

    for key in img.info:
        if key not in ("exif", "dpi"):
            val = img.info[key]
            if isinstance(val, bytes):
                val = f"<bytes: {len(val)} bytes>"
            img_info[f"meta_{key}"] = str(val)

    exif_data["image_info"] = img_info

    software = exif_data["data"].get("Software", "")
    make = exif_data["data"].get("Make", "")
    model = exif_data["data"].get("Model", "")
    datetime_original = exif_data["data"].get("DateTimeOriginal", "")
    artist = exif_data["data"].get("Artist", "")

    generation_keywords = [
        "midjourney", "dall-e", "dalle", "stable diffusion",
        "automatic1111", "comfyui", "invokeai", "leonardo",
        "firefly", "adobe firefly", "bing image creator",
        "novelai", "playground", "ideogram", "recraft",
        "krea", "magnific", "runway", "pika",
        "generated", "ai-generated", "synthetic",
    ]

    combined = f"{software} {make} {model} {artist}".lower()
    detected_gen_tools = [kw for kw in generation_keywords if kw in combined]

    if detected_gen_tools:
        exif_data["warnings"].append(
            f"FERRAMENTA DE GERAÇÃO IA DETECTADA NOS METADADOS: {', '.join(detected_gen_tools)}. "
            f"Software='{software}', Make='{make}', Model='{model}', Artist='{artist}'"
        )

    if not make and not model and not software and not datetime_original:
        exif_data["warnings"].append(
            "AUSÊNCIA TOTAL de metadados de câmera (Make, Model, Software, DateTimeOriginal). "
            "Consistente com imagem gerada por IA — mas também pode ser print screen ou remoção intencional."
        )

    return exif_data


def error_level_analysis(filepath: str, quality: int = 90) -> dict:
    """
    Error Level Analysis (ELA).
    Recomprime a imagem a uma qualidade conhecida e calcula a diferença.
    Regiões com alto erro podem indicar edição ou composição.
    Padrões de erro anômalos podem indicar geração por IA.
    """
    if not HAS_PIL:
        return {"available": False, "error": "Pillow e numpy não instalados"}

    try:
        img = Image.open(filepath).convert("RGB")
    except Exception as e:
        return {"available": False, "error": str(e)}

    buffer = io.BytesIO()
    img.save(buffer, "JPEG", quality=quality)
    buffer.seek(0)
    recompressed = Image.open(buffer)

    orig_arr = np.array(img, dtype=np.float32)
    recomp_arr = np.array(recompressed, dtype=np.float32)

    diff = np.abs(orig_arr - recomp_arr)
    max_diff = np.max(diff)
    mean_diff = np.mean(diff)
    std_diff = np.std(diff)

    threshold_high = max_diff * 0.7
    high_diff_pixels = np.sum(diff > threshold_high)
    total_pixels = diff.size
    high_diff_ratio = round(high_diff_pixels / total_pixels, 6)

    return {
        "available": True,
        "quality_used": quality,
        "max_difference": round(float(max_diff), 2),
        "mean_difference": round(float(mean_diff), 4),
        "std_difference": round(float(std_diff), 4),
        "high_diff_pixel_ratio": high_diff_ratio,
        "interpretation": _interpret_ela(mean_diff, std_diff, high_diff_ratio),
    }


def _interpret_ela(mean_diff: float, std_diff: float, high_diff_ratio: float) -> str:
    """Interpreta resultados da ELA."""
    if mean_diff < 1.0 and std_diff < 0.5:
        return (
            "ELA muito baixa e uniforme. Imagem pode ser sintética (gerada por IA) "
            "— toda a imagem está no mesmo 'nível' de compressão, sem variações naturais."
        )
    elif mean_diff < 3.0 and high_diff_ratio < 0.01:
        return (
            "ELA baixa. Pouca variação entre regiões. Pode indicar imagem gerada por IA "
            "ou foto real com pouca textura."
        )
    elif high_diff_ratio > 0.05:
        return (
            "ELA com regiões de alta diferença detectadas. Pode indicar edição/manipulação "
            "localizada ou imagem real com texturas variadas."
        )
    else:
        return (
            "ELA dentro de padrões normais. Não é possível determinar origem apenas pela ELA."
        )


def analyze_noise_pattern(filepath: str) -> dict:
    """Análise simplificada de padrão de ruído."""
    if not HAS_PIL:
        return {"available": False, "error": "Pillow e numpy não instalados"}

    try:
        img = Image.open(filepath).convert("L")
    except Exception as e:
        return {"available": False, "error": str(e)}

    arr = np.array(img, dtype=np.float32)

    noise_std = float(np.std(arr))
    noise_mean = float(np.mean(arr))

    if noise_std < 10:
        interpretation = (
            "Ruído muito baixo. Imagem excessivamente 'limpa'. "
            "Pode indicar geração por IA ou pós-processamento pesado (denoising)."
        )
    elif noise_std > 80:
        interpretation = (
            "Ruído muito alto. Pode indicar foto real em baixa luminosidade "
            "ou compressão agressiva."
        )
    else:
        interpretation = "Nível de ruído dentro da faixa normal."

    return {
        "available": True,
        "noise_mean": round(noise_mean, 2),
        "noise_std": round(noise_std, 2),
        "interpretation": interpretation,
    }


def analyze_image(filepath: str, ela_quality: int = 90) -> dict:
    """Executa todas as análises e retorna dicionário consolidado."""
    metrics = {
        "basic_info": extract_basic_info(filepath),
        "exif_metadata": extract_exif(filepath),
        "ela": error_level_analysis(filepath, quality=ela_quality),
        "noise_analysis": analyze_noise_pattern(filepath),
        "suspicious_indicators": [],
    }

    suspicious = metrics["suspicious_indicators"]

    if metrics["exif_metadata"].get("warnings"):
        suspicious.extend(metrics["exif_metadata"]["warnings"])

    if metrics["ela"].get("available"):
        mean_diff = metrics["ela"].get("mean_difference", 0)
        if mean_diff < 1.0:
            suspicious.append(
                f"ELA anômalo — diferença média muito baixa ({mean_diff:.4f}). "
                "Possível imagem gerada por IA (S44)."
            )

    if metrics["noise_analysis"].get("available"):
        noise_std = metrics["noise_analysis"].get("noise_std", 0)
        if noise_std < 10:
            suspicious.append(
                f"Ruído anormalmente baixo (std={noise_std:.1f}). "
                "Sem ruído de sensor fotográfico real. Possível IA (S45)."
            )

    return metrics


def main():
    parser = argparse.ArgumentParser(
        description="AI Forensic Analyzer — Pré-processamento Forense de Imagem"
    )
    parser.add_argument("--input", "-i", type=str, required=True, help="Caminho para imagem")
    parser.add_argument("--output", "-o", type=str, help="Caminho para salvar JSON de métricas")
    parser.add_argument(
        "--ela-quality",
        type=int,
        default=90,
        help="Qualidade JPEG para ELA (default: 90)",
    )
    parser.add_argument("--pretty", action="store_true", help="Output JSON formatado")

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Erro: Arquivo não encontrado: {args.input}", file=sys.stderr)
        sys.exit(1)

    if not HAS_PIL:
        print(
            "AVISO: Pillow não instalado. Apenas informações básicas disponíveis.",
            file=sys.stderr,
        )
        print("Instale com: pip install Pillow numpy", file=sys.stderr)

    metrics = analyze_image(args.input, ela_quality=args.ela_quality)

    indent = 2 if args.pretty else None
    output_json = json.dumps(metrics, ensure_ascii=False, indent=indent)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"Métricas salvas em: {args.output}")
    else:
        print(output_json)


if __name__ == "__main__":
    main()
