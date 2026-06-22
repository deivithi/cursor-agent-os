#!/usr/bin/env python3
"""
AI Forensic Analyzer v2 — Processamento Batch com Subagentes

Processa múltiplos arquivos de conteúdo em paralelo, consolidando resultados
individuais em um relatório unificado.

Modos de operação:
  1. Modo diretório: analisa todos os arquivos de texto/imagem em uma pasta
  2. Modo lista: analisa arquivos listados em um JSON/CSV
  3. Modo stdin: recebe lista de arquivos via pipe

Uso:
    python batch_analyzer.py --dir ./documentos/ --mode standard
    python batch_analyzer.py --file-list items.json --mode quick
    python batch_analyzer.py --dir ./images/ --type imagem --mode standard

Output: Relatório consolidado JSON com estatísticas agregadas.
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

TEXT_EXTENSIONS = {".txt", ".md", ".json", ".csv", ".html", ".xml", ".py", ".js", ".ts", ".go", ".java", ".rs"}
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".tiff", ".bmp", ".svg"}
CODE_EXTENSIONS = {".py", ".js", ".ts", ".jsx", ".tsx", ".go", ".java", ".rs", ".c", ".cpp", ".h", ".rb", ".php"}


def detect_content_type(filepath: str) -> str:
    """Detecta o tipo de conteúdo baseado na extensão."""
    ext = Path(filepath).suffix.lower()
    if ext in IMAGE_EXTENSIONS:
        return "imagem"
    elif ext in CODE_EXTENSIONS:
        return "codigo"
    else:
        return "texto"


def collect_files_from_dir(directory: str, content_type: str = None) -> list[str]:
    """Coleta arquivos de um diretório, opcionalmente filtrados por tipo."""
    files = []
    target_extensions = set()

    if content_type == "texto":
        target_extensions = TEXT_EXTENSIONS
    elif content_type == "imagem":
        target_extensions = IMAGE_EXTENSIONS
    elif content_type == "codigo":
        target_extensions = CODE_EXTENSIONS
    else:
        target_extensions = TEXT_EXTENSIONS | IMAGE_EXTENSIONS | CODE_EXTENSIONS

    for root, _, filenames in os.walk(directory):
        for filename in filenames:
            ext = Path(filename).suffix.lower()
            if ext in target_extensions:
                files.append(os.path.join(root, filename))

    return sorted(files)


def process_text_file(filepath: str, mode: str = "standard") -> dict:
    """Pré-processa arquivo de texto e gera entrada para o LLM."""
    script_dir = Path(__file__).parent
    stats_script = script_dir / "text_stats.py"

    if stats_script.exists():
        try:
            result = subprocess.run(
                ["python", str(stats_script), "--input", filepath],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode == 0:
                metrics = json.loads(result.stdout)
            else:
                metrics = {"error": result.stderr.strip()}
        except (subprocess.TimeoutExpired, json.JSONDecodeError, Exception) as e:
            metrics = {"error": str(e)}
    else:
        metrics = {"error": "text_stats.py não encontrado"}

    text_content = Path(filepath).read_text(encoding="utf-8", errors="replace")

    return {
        "file": filepath,
        "type": "texto",
        "mode": mode,
        "content": text_content[:50000],
        "content_length": len(text_content),
        "preprocessing_metrics": metrics.get("interpretacao", {}),
        "raw_metrics": metrics,
    }


def process_image_file(filepath: str, mode: str = "standard") -> dict:
    """Pré-processa imagem e gera entrada para o LLM."""
    script_dir = Path(__file__).parent
    img_script = script_dir / "image_forensics.py"

    if img_script.exists():
        try:
            result = subprocess.run(
                ["python", str(img_script), "--input", filepath],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode == 0:
                metrics = json.loads(result.stdout)
            else:
                metrics = {"error": result.stderr.strip()}
        except (subprocess.TimeoutExpired, json.JSONDecodeError, Exception) as e:
            metrics = {"error": str(e)}
    else:
        metrics = {"error": "image_forensics.py não encontrado"}

    description = (
        f"Imagem: {Path(filepath).name}\n"
        f"Tamanho: {metrics.get('basic_info', {}).get('size_kb', 'N/A')} KB\n"
        f"Formato: {metrics.get('exif_metadata', {}).get('image_info', {}).get('format', 'N/A')}\n"
        f"Indicadores suspeitos: {json.dumps(metrics.get('suspicious_indicators', []), ensure_ascii=False)}"
    )

    return {
        "file": filepath,
        "type": "imagem",
        "mode": mode,
        "content": description,
        "content_length": 0,
        "preprocessing_metrics": {},
        "raw_metrics": metrics,
    }


def generate_llm_prompt(item: dict, prompt_templates_dir: str = None) -> str:
    """
    Gera o user prompt completo para envio ao LLM.
    O system prompt deve ser concatenado separadamente.
    """
    content_type = item["type"]
    mode = item.get("mode", "standard")

    if prompt_templates_dir:
        template_map = {
            "texto": "user-text.txt",
            "imagem": "user-image.txt",
            "codigo": "user-code.txt",
        }
        template_file = os.path.join(prompt_templates_dir, template_map.get(content_type, "user-text.txt"))
        if os.path.exists(template_file):
            template = Path(template_file).read_text(encoding="utf-8")
            template = template.replace("[quick / standard / deep]", mode)
            template = template.replace("[COLE AQUI O TEXTO COMPLETO]", item["content"])
            template = template.replace("[COLE AQUI O CÓDIGO COMPLETO]", item["content"])
            return template

    prompt = f"""Tipo de conteúdo: {item['type'].capitalize()}
Modo de análise: {mode}

Conteúdo:
{item['content']}

Contexto adicional: Arquivo processado em lote. Origem: {item['file']}
Métricas de pré-processamento: {json.dumps(item.get('preprocessing_metrics', {}), ensure_ascii=False)}

Responda EXCLUSIVAMENTE com o JSON no schema definido."""

    return prompt


def consolidate_results(results: list[dict]) -> dict:
    """Consolida múltiplos resultados em relatório unificado."""
    if not results:
        return {"error": "Nenhum resultado para consolidar", "total": 0}

    verdicts = [r.get("veredito", "Desconhecido") for r in results]
    ia_count = verdicts.count("IA")
    humano_count = verdicts.count("Humano")
    misto_count = verdicts.count("Misto")
    incerto_count = verdicts.count("Incerto")

    confidences = [
        r.get("probabilidade_ia", 0)
        for r in results
        if isinstance(r.get("probabilidade_ia"), (int, float))
    ]
    avg_prob = round(sum(confidences) / len(confidences), 1) if confidences else 0

    bias_warnings_total = sum(len(r.get("bias_warnings", [])) for r in results)

    return {
        "relatorio": "AI Forensic Analyzer — Análise Batch",
        "data_analise": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
        "total_analisado": len(results),
        "estatisticas": {
            "ia": ia_count,
            "humano": humano_count,
            "misto": misto_count,
            "incerto": incerto_count,
            "probabilidade_ia_media": avg_prob,
            "total_bias_warnings": bias_warnings_total,
        },
        "resultados_individuais": results,
    }


def main():
    parser = argparse.ArgumentParser(
        description="AI Forensic Analyzer — Processamento Batch"
    )
    parser.add_argument("--dir", "-d", type=str, help="Diretório com arquivos para analisar")
    parser.add_argument("--file-list", "-f", type=str, help="Arquivo JSON com lista de paths")
    parser.add_argument(
        "--type",
        "-t",
        type=str,
        choices=["texto", "imagem", "codigo"],
        help="Filtrar por tipo de conteúdo",
    )
    parser.add_argument(
        "--mode",
        "-m",
        type=str,
        default="standard",
        choices=["quick", "standard", "deep"],
        help="Modo de análise (default: standard)",
    )
    parser.add_argument("--output", "-o", type=str, help="Caminho para salvar JSON consolidado")
    parser.add_argument(
        "--workers",
        "-w",
        type=int,
        default=4,
        help="Número de workers paralelos (default: 4)",
    )
    parser.add_argument(
        "--pretty",
        action="store_true",
        help="Output JSON formatado",
    )

    args = parser.parse_args()

    if args.dir:
        files = collect_files_from_dir(args.dir, content_type=args.type)
    elif args.file_list:
        with open(args.file_list, encoding="utf-8") as f:
            files = json.load(f)
        if not isinstance(files, list):
            print("Erro: --file-list deve conter um JSON array de paths", file=sys.stderr)
            sys.exit(1)
    else:
        print("Erro: Forneça --dir ou --file-list", file=sys.stderr)
        sys.exit(1)

    if not files:
        print("Nenhum arquivo encontrado para processar.", file=sys.stderr)
        sys.exit(0)

    print(f"Processando {len(files)} arquivos com {args.workers} workers...", file=sys.stderr)

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {}
        for filepath in files:
            content_type = detect_content_type(filepath)
            if content_type == "imagem":
                future = executor.submit(process_image_file, filepath, args.mode)
            else:
                future = executor.submit(process_text_file, filepath, args.mode)
            futures[future] = filepath

        for future in as_completed(futures):
            filepath = futures[future]
            try:
                result = future.result()
                print(f"  ✓ {filepath} ({result['type']})", file=sys.stderr)
                results.append(result)
            except Exception as e:
                print(f"  ✗ {filepath}: {e}", file=sys.stderr)
                results.append({"file": filepath, "error": str(e)})

    consolidated = consolidate_results(results)

    indent = 2 if args.pretty else None
    output_json = json.dumps(consolidated, ensure_ascii=False, indent=indent)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"\nRelatório consolidado salvo em: {args.output}")
    else:
        print(output_json)


if __name__ == "__main__":
    main()
