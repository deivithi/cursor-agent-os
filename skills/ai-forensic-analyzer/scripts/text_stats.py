#!/usr/bin/env python3
"""
AI Forensic Analyzer v2 — Pré-processamento Estatístico de Texto

Calcula métricas quantitativas para injeção no prompt do LLM:
- Burstiness (variância de comprimento de sentença)
- Type-Token Ratio (diversidade lexical)
- Densidade de conectivos LLM-típicos
- Distribuição de comprimento de sentenças
- Repetição de n-gramas

Uso:
    python text_stats.py --input "texto para analisar"
    python text_stats.py --input texto.txt --output metrics.json
    python text_stats.py --stdin < texto.txt

Output: JSON com todas as métricas calculadas.
"""

import argparse
import json
import re
import sys
from collections import Counter
from math import sqrt
from pathlib import Path


LLM_CONNECTIVES = [
    "no entanto", "entretanto", "todavia", "contudo", "porém",
    "além disso", "ademais", "outrossim",
    "é importante notar que", "é fundamental ressaltar que",
    "vale lembrar que", "cabe destacar que", "convém mencionar que",
    "em conclusão", "em suma", "em síntese", "por fim", "finalmente",
    "por um lado", "por outro lado", "em contrapartida",
    "nesse sentido", "neste contexto", "diante disso",
    "dessa forma", "desse modo", "assim sendo",
    "posto isto", "ante o exposto", "face ao exposto",
    "no mundo atual", "na era digital", "cada vez mais",
    "sem precedentes", "é essencial", "é fundamental", "é crucial",
    "não apenas", "mas também", "tanto quanto",
    "em primeiro lugar", "em segundo lugar", "em terceiro lugar",
    "primeiramente", "segundamente", "por último",
]

LLM_FILLER_PATTERNS = [
    r"\bimportante ressaltar\b",
    r"\bfundamental destacar\b",
    r"\bessencial compreender\b",
    r"\bcrucial entender\b",
    r"\bsignificativo notar\b",
    r"\bno mundo (atual|contemporâneo|moderno)\b",
    r"\bna era (digital|da informação|atual)\b",
    r"\bcada vez mais\b",
    r"\bsem precedentes\b",
    r"\btransformando (a|o) [\w\s]+ de forma\b",
    r"\bé (importante|fundamental|essencial|crucial) que\b",
    r"\bdesempenha um papel (fundamental|crucial|importante|essencial)\b",
]


def split_sentences(text: str) -> list[str]:
    """Divide texto em sentenças usando pontuação terminal."""
    sentences = re.split(r'(?<=[.!?;])\s+', text)
    return [s.strip() for s in sentences if s.strip() and len(s.strip()) > 2]


def split_words(text: str) -> list[str]:
    """Tokenização simples por palavras."""
    return re.findall(r'\b\w+\b', text.lower())


def calculate_burstiness(sentences: list[str]) -> float:
    """
    Burstiness = variância do comprimento das sentenças.
    Texto humano tende a ter alta burstiness (frases longas e curtas alternadas).
    Texto IA tende a ter baixa burstiness (frases de comprimento uniforme).
    """
    if len(sentences) < 2:
        return 0.0

    lengths = [len(s.split()) for s in sentences]
    mean_len = sum(lengths) / len(lengths)
    variance = sum((l - mean_len) ** 2 for l in lengths) / len(lengths)
    return round(sqrt(variance), 4)


def calculate_ttr(words: list[str]) -> float:
    """
    Type-Token Ratio: tipos únicos / total de tokens.
    Texto humano tende a ter TTR mais alto (maior diversidade lexical).
    Texto IA tende a ter TTR mais baixo (repete mais palavras).
    """
    if not words:
        return 0.0
    return round(len(set(words)) / len(words), 4)


def calculate_connective_density(text: str) -> dict:
    """
    Densidade de conectivos LLM-típicos no texto.
    Retorna contagem e densidade por 1000 palavras.
    """
    text_lower = text.lower()
    words = split_words(text)
    if not words:
        return {"count": 0, "per_1000_words": 0.0, "found": []}

    found = []
    for connective in LLM_CONNECTIVES:
        count = len(re.findall(re.escape(connective), text_lower))
        if count > 0:
            found.append({"connective": connective, "count": count})

    total_count = sum(f["count"] for f in found)
    per_1000 = round((total_count / len(words)) * 1000, 2)

    return {
        "count": total_count,
        "per_1000_words": per_1000,
        "found": found,
    }


def calculate_filler_density(text: str) -> dict:
    """Densidade de frases de preenchimento típicas de LLM."""
    text_lower = text.lower()
    words = split_words(text)
    if not words:
        return {"count": 0, "per_1000_words": 0.0, "found": []}

    found = []
    for pattern in LLM_FILLER_PATTERNS:
        matches = re.findall(pattern, text_lower)
        if matches:
            found.append({"pattern": pattern, "count": len(matches)})

    total_count = sum(f["count"] for f in found)
    per_1000 = round((total_count / len(words)) * 1000, 2)

    return {
        "count": total_count,
        "per_1000_words": per_1000,
        "found": found,
    }


def detect_ngram_repetition(words: list[str], n: int = 3) -> dict:
    """Detecta repetição de n-gramas (padrão comum em texto IA)."""
    if len(words) < n:
        return {"repeated_count": 0, "repeated_ngrams": []}

    ngrams = [tuple(words[i : i + n]) for i in range(len(words) - n + 1)]
    counter = Counter(ngrams)
    repeated = [
        {"ngram": " ".join(k), "count": v}
        for k, v in counter.most_common(10)
        if v > 1
    ]

    return {
        "repeated_count": len(repeated),
        "repeated_ngrams": repeated,
    }


def calculate_sentence_stats(sentences: list[str]) -> dict:
    """Estatísticas de comprimento de sentença."""
    if not sentences:
        return {"mean": 0, "std_dev": 0, "min": 0, "max": 0, "count": 0}

    lengths = [len(s.split()) for s in sentences]
    mean_len = sum(lengths) / len(lengths)
    variance = sum((l - mean_len) ** 2 for l in lengths) / len(lengths)
    std_dev = sqrt(variance)

    return {
        "mean": round(mean_len, 2),
        "std_dev": round(std_dev, 2),
        "min": min(lengths),
        "max": max(lengths),
        "count": len(sentences),
    }


def count_passive_voice(text: str) -> dict:
    """
    Contagem de construções de voz passiva analítica (típicas de LLM).
    Ex: "é importante que", "deve ser considerado", "pode ser observado".
    """
    passive_patterns = [
        r"\b(é|são|foi|foram|era|eram|será|serão|seria|seriam)\s+\w+(do|da)\b",
        r"\b(pode|deve|precisa|necessita)\s+ser\b",
        r"\b(é|são)\s+(importante|fundamental|essencial|crucial|necessário|preciso)\b",
        r"\b(deve|pode)\s+ser\s+(considerado|observado|notado|destacado|ressaltado)\b",
    ]

    text_lower = text.lower()
    total_matches = 0
    matches_detail = []

    for pattern in passive_patterns:
        found = re.findall(pattern, text_lower)
        if found:
            count = len(found)
            total_matches += count
            matches_detail.append({"pattern": pattern, "count": count})

    words = split_words(text)
    per_1000 = round((total_matches / len(words)) * 1000, 2) if words else 0.0

    return {"count": total_matches, "per_1000_words": per_1000, "matches": matches_detail}


def analyze_text(text: str) -> dict:
    """Executa todas as análises e retorna dicionário consolidado."""
    sentences = split_sentences(text)
    words = split_words(text)
    chars = len(text)

    metrics = {
        "tamanho_total_caracteres": chars,
        "tamanho_total_palavras": len(words),
        "tamanho_total_sentencas": len(sentences),
        "burstiness": calculate_burstiness(sentences),
        "type_token_ratio": calculate_ttr(words),
        "densidade_conectivos": calculate_connective_density(text),
        "densidade_fillers": calculate_filler_density(text),
        "repeticao_3gramas": detect_ngram_repetition(words, 3),
        "repeticao_4gramas": detect_ngram_repetition(words, 4),
        "estatisticas_sentencas": calculate_sentence_stats(sentences),
        "voz_passiva": count_passive_voice(text),
        "interpretacao": {},
    }

    interp = metrics["interpretacao"]

    if metrics["burstiness"] < 3.0 and metrics["tamanho_total_sentencas"] >= 5:
        interp["burstiness_alerta"] = (
            "Burstiness baixo (< 3.0): frases de comprimento muito uniforme. "
            "FORTE indicador de texto gerado por IA. (S01)"
        )
    elif metrics["burstiness"] > 7.0:
        interp["burstiness_alerta"] = (
            "Burstiness alto (> 7.0): variação natural entre frases longas e curtas. "
            "Indicador de texto HUMANO. (H09)"
        )

    if metrics["type_token_ratio"] < 0.45 and metrics["tamanho_total_palavras"] > 100:
        interp["ttr_alerta"] = (
            f"TTR baixo ({metrics['type_token_ratio']:.3f} < 0.45): baixa diversidade lexical "
            "para texto deste tamanho. Indicador de IA. (S03)"
        )

    connective_per_1000 = metrics["densidade_conectivos"]["per_1000_words"]
    if connective_per_1000 > 15:
        interp["conectivos_alerta"] = (
            f"Densidade de conectivos LLM muito alta ({connective_per_1000}/1000 palavras). "
            "FORTE indicador de IA. (S08, S13)"
        )
    elif connective_per_1000 > 8:
        interp["conectivos_alerta"] = (
            f"Densidade de conectivos LLM elevada ({connective_per_1000}/1000 palavras). "
            "Indicador moderado de IA. (S08)"
        )

    filler_per_1000 = metrics["densidade_fillers"]["per_1000_words"]
    if filler_per_1000 > 5:
        interp["fillers_alerta"] = (
            f"Densidade de frases de preenchimento elevada ({filler_per_1000}/1000 palavras). "
            "Indicador de IA. (S32)"
        )

    repeated_3grams = metrics["repeticao_3gramas"]["repeated_count"]
    if repeated_3grams > 0:
        interp["ngram_alerta"] = (
            f"{repeated_3grams} trigramas repetidos detectados. Indicador de IA. (S05)"
        )

    passive_per_1000 = metrics["voz_passiva"]["per_1000_words"]
    if passive_per_1000 > 20:
        interp["passiva_alerta"] = (
            f"Voz passiva analítica muito frequente ({passive_per_1000}/1000 palavras). "
            "Indicador de IA. (S14)"
        )

    return metrics


def main():
    parser = argparse.ArgumentParser(
        description="AI Forensic Analyzer — Pré-processamento Estatístico de Texto"
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--input", "-i", type=str, help="Texto direto ou caminho para arquivo .txt")
    group.add_argument("--stdin", action="store_true", help="Ler texto do stdin")
    parser.add_argument("--output", "-o", type=str, help="Caminho para salvar JSON de métricas")
    parser.add_argument("--pretty", action="store_true", help="Output JSON formatado")

    args = parser.parse_args()

    if args.stdin:
        text = sys.stdin.read()
    elif args.input:
        input_path = Path(args.input)
        if input_path.exists() and input_path.suffix in (".txt", ".md", ".json"):
            text = input_path.read_text(encoding="utf-8")
        else:
            text = args.input
    else:
        print("Erro: Forneça --input ou --stdin", file=sys.stderr)
        sys.exit(1)

    if not text.strip():
        print("Erro: Texto vazio", file=sys.stderr)
        sys.exit(1)

    metrics = analyze_text(text)

    indent = 2 if args.pretty else None
    output_json = json.dumps(metrics, ensure_ascii=False, indent=indent)

    if args.output:
        Path(args.output).write_text(output_json, encoding="utf-8")
        print(f"Métricas salvas em: {args.output}")
    else:
        print(output_json)


if __name__ == "__main__":
    main()
