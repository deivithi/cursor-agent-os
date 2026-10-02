#!/usr/bin/env python3
"""ste_lint — verificador de Português Técnico Simplificado (STE-PT).

Adaptação PT-BR das regras do ASD-STE100 para textos do ecossistema Febracis.
Só usa a stdlib. Lê o dicionário em ../references/dicionario.json.
O núcleo JS de assets/prancha-ste-pt.template.html espelha este arquivo.

Uso:
    py ste_lint.py arquivo.md [--nivel 100|80] [--formato texto|json]
    type arquivo.md | py ste_lint.py - --nivel 80

Saída: código 0 sem erros, 1 com erros, 2 com falha de uso (arquivo ausente ou ilegível).
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path

DICIONARIO_PADRAO = Path(__file__).resolve().parent.parent / "references" / "dicionario.json"

# Limites por nível. Nível 80 = "80% do caminho até o STE" (Karpathy).
LIMITES = {
    100: {"procedimento": 20, "descritivo": 25, "frases_paragrafo": 6},
    80: {"procedimento": 25, "descritivo": 30, "frases_paragrafo": 8},
}

# Categorias do dicionário que viram apenas aviso no nível 80.
CATEGORIAS_FLEXIVEIS_80 = {"registro", "verbo"}

LETRA = "0-9A-Za-zÀ-ÖØ-öø-ÿ_"
PALAVRA = re.compile(rf"[{LETRA}]+(?:[-'’./,][{LETRA}]+)*")
FIM_DE_FRASE = re.compile(r"(?:(?<=[.!?…])|(?<=[.!?…][\"”’)]))\s+(?=[\"“(\[⛔⚠A-ZÀ-ÖØ-Þ0-9])")
ABREVIACOES = (
    "p. ex.", "p.p.", "aprox.", "profa.", "prof.", "ltda.", "obs.", "fig.", "sra.",
    "ex.", "pp.", "sr.", "dr.", "vs.", "nº.", "p.",
)  # fmt: skip

ITEM_NUMERADO = re.compile(r"^\s*\d+[.)]\s+")
ITEM_CHECKLIST = re.compile(r"^\s*[-*+]\s+\[[ xX]\]\s+")
ITEM_MARCADOR = re.compile(r"^\s*[-*+]\s+")
AVISO_SEGURANCA = re.compile(r"^\s*(?:⛔\s*)?(?:BLOQUEIO|(?:⚠️?\s*)?ATENÇÃO|CUIDADO)\s*:", re.IGNORECASE)
CONTINUACAO = re.compile(r"^(?: {2,}|\t)\S")
CERCA = re.compile(r"^(`{3,}|~{3,})")
# Mesmo conjunto de quebras de str.splitlines(); o núcleo JS usa este padrão.
QUEBRA_DE_LINHA = re.compile(r"\r\n|[\n\r\v\f\x1c-\x1e\x85\u2028\u2029]")
CHAVE_YAML = re.compile(r"^[A-Za-z_][\w-]*\s*:")

CODIGO_INLINE = re.compile(r"`[^`\n]+`")
LINK_MD = re.compile(r"\[[^\]]+\]\([^)]+\)")
URL = re.compile(r"https?://[^\s<>)]*[^\s<>).,;:!?\]]")
ROTULO_CONF = re.compile(r"\[conf:\s*[^\]]+\]", re.IGNORECASE)
ENFASE = re.compile(r"(\*\*|\*)(?=\S)(.+?)(?<=\S)\1")

PARTICIPIO = (
    r"(?:[a-zà-ÿ]+(?:ad|[ií]d|ít|ost|eit)[oa]s?"
    r"|(?:abert|escrit|vist|pag|ganh|gast|dit|cobert|descobert|suspens|impress)[oa]s?|entregues?)"
)
# Adjetivos com forma de particípio: nunca são passiva.
ADJETIVOS = {
    "válido", "válida", "inválido", "inválida", "rápido", "rápida", "adequado", "adequada",
    "errado", "errada", "apropriado", "apropriada", "obrigado", "obrigada", "delicado", "complicado",
    "privado", "privada", "dedicado", "sólido", "líquido", "tímido", "úmido", "nítido", "lúcido",
    "pálido", "ávido", "híbrido", "híbrida", "rígido", "rígida", "bonito", "bonita", "infinito",
    "favorito", "favorita", "explícito", "explícita", "implícito", "implícita", "gratuito", "gratuita",
    "esquisito", "composto", "proposto", "oposto", "disposto", "suposto",
}  # fmt: skip
# Substantivos com forma de particípio. "Foi dado/pedido" é passiva, então só valem no ramo "é/são".
SUBSTANTIVOS = {
    "resultado", "dado", "estado", "lado", "sentido", "conteúdo", "pedido", "significado",
    "cuidado", "mercado", "período", "partido",
}  # fmt: skip
SUBSTANTIVOS_NUNCA_PASSIVA = {"resultado", "conteúdo", "período", "mercado", "significado", "lado", "estado"}

# "foi/será/ser + particípio" é evento (passiva). "é/são + particípio" costuma ser
# estado ("o lead é duplicado"); só conta como passiva quando tem agente ("por/pelo").
VOZ_PASSIVA = re.compile(
    r"\b(?:foi|foram|será|serão|seja|sejam|fosse|fossem|ser|sido|está sendo|estão sendo)\s+(" + PARTICIPIO + r")\b"
    r"|\b(?:é|são|era|eram)\s+(" + PARTICIPIO + r")\s+(?:por|pel[oa]s?)\b",
    re.IGNORECASE,
)
GERUNDISMO = re.compile(
    r"\b(?:(?:vou|vai|vamos|vão|vá|irei|irá|iremos|irão)\s+estar|estarei|estaremos|estará|estarão)"
    r"(?:\s+(?:te|lhe|lhes|me|nos|se|vos))?\s+[a-zà-ÿ]+ndo\b",
    re.IGNORECASE,
)
FUTURO_DO_PRETERITO = re.compile(
    r"\b(?:seria|seriam|poderia|poderiam|deveria|deveriam|teria|teriam|faria|fariam|iria|iriam|"
    r"haveria|gostaria|gostariam|precisaria|precisariam|conseguiria|conseguiriam)\b",
    re.IGNORECASE,
)
PREP_DE = r"(?:de|do|da|dos|das)"
CADEIA_NOMINAL = re.compile(
    r"\b[a-zà-ÿ]+\s+" + PREP_DE + r"\s+[a-zà-ÿ]+\s+" + PREP_DE + r"\s+[a-zà-ÿ]+\s+" + PREP_DE + r"\s+[a-zà-ÿ]+\b",
    re.IGNORECASE,
)
MULTIPLAS_INSTRUCOES = re.compile(
    r";|\b(?:e depois|e em seguida|e então|, depois|, em seguida|e logo após)\b(?!\s+d[eoa]s?\b)",
    re.IGNORECASE,
)


@dataclass
class Achado:
    codigo: str
    severidade: str  # "erro" | "aviso"
    linha: int
    mensagem: str
    trecho: str


@dataclass
class Frase:
    texto: str
    linha: int
    tipo: str  # "procedimento" | "descritivo"
    palavras: int


@dataclass
class Relatorio:
    nivel: int
    frases: int = 0
    frases_ok: int = 0
    achados: list[Achado] = field(default_factory=list)

    @property
    def erros(self) -> int:
        return sum(1 for a in self.achados if a.severidade == "erro")

    @property
    def avisos(self) -> int:
        return sum(1 for a in self.achados if a.severidade == "aviso")

    @property
    def conformidade(self) -> float:
        # Arredonda meio para cima, igual ao Math.round do núcleo JS.
        return 100.0 if self.frases == 0 else math.floor(1000 * self.frases_ok / self.frases + 0.5) / 10

    def to_dict(self) -> dict:
        return {
            "nivel": self.nivel,
            "frases": self.frases,
            "frases_ok": self.frases_ok,
            "conformidade": self.conformidade,
            "erros": self.erros,
            "avisos": self.avisos,
            "achados": [asdict(a) for a in self.achados],
        }


def carregar_dicionario(caminho: Path = DICIONARIO_PADRAO) -> list[dict]:
    dados = json.loads(caminho.read_text(encoding="utf-8"))
    entradas = []
    for entrada in dados["nao_aprovadas"]:
        entrada = dict(entrada)
        entrada["_regex"] = re.compile(entrada["padrao"], re.IGNORECASE | re.MULTILINE)
        entradas.append(entrada)
    return entradas


def limpar_inline(texto: str) -> str:
    """Troca código, links e URLs por um token que conta como 1 palavra."""
    texto = ROTULO_CONF.sub("", texto)
    texto = CODIGO_INLINE.sub("CODIGO", texto)
    texto = LINK_MD.sub("LINK", texto)
    texto = URL.sub("URL", texto)
    texto = ENFASE.sub(r"\2", texto)
    return texto.strip()


def contar_palavras(texto: str) -> int:
    return len(PALAVRA.findall(texto))


def dividir_frases(texto: str) -> list[str]:
    protegido = texto
    for i, abrev in enumerate(ABREVIACOES):
        protegido = re.sub(rf"(?<![{LETRA}])" + re.escape(abrev), f"\x00{i}\x00", protegido, flags=re.IGNORECASE)
    frases = []
    for parte in FIM_DE_FRASE.split(protegido):
        for i, abrev in enumerate(ABREVIACOES):
            parte = parte.replace(f"\x00{i}\x00", abrev)
        parte = parte.strip()
        if contar_palavras(parte):
            frases.append(parte)
    return frases


def _alternar_cerca(cerca: str | None, marca: str) -> str | None:
    """Abre uma cerca, ou fecha a atual se a marca usa o mesmo caractere e é tão longa quanto ela."""
    if cerca is None:
        return marca
    return None if marca[0] == cerca[0] and len(marca) >= len(cerca) else cerca


def _fim_frontmatter(linhas: list[str]) -> int:
    """Número de linhas do frontmatter YAML no topo (0 se não houver)."""
    if not linhas or linhas[0].strip() != "---":
        return 0
    for i, linha in enumerate(linhas[1:], start=1):
        if linha.strip() == "---":
            corpo = linhas[1:i]
            return i + 1 if any(CHAVE_YAML.match(x) for x in corpo) else 0
    return 0


def blocos(texto: str) -> list[tuple[int, str, str]]:
    """Agrupa o Markdown em blocos (linha inicial, tipo, texto).

    Ignora frontmatter, código cercado, tabelas, títulos e citações. Cada item de lista é um bloco;
    linha indentada logo depois de um item continua o mesmo item.
    """
    resultado: list[tuple[int, str, str]] = []
    paragrafo: list[str] = []
    inicio = 0
    cerca: str | None = None
    item_aberto = False

    def fechar() -> None:
        nonlocal paragrafo
        if paragrafo:
            resultado.append((inicio, "descritivo", " ".join(paragrafo)))
            paragrafo = []

    linhas = QUEBRA_DE_LINHA.split(texto.lstrip("\ufeff"))
    pular_ate = _fim_frontmatter(linhas)
    for numero, linha in enumerate(linhas, start=1):
        if numero <= pular_ate:
            continue
        bruta = linha.strip()
        marca = CERCA.match(bruta)
        if marca:
            fechar()
            item_aberto = False
            cerca = _alternar_cerca(cerca, marca.group(1))
            continue
        if cerca is not None:
            continue
        if not bruta or bruta.startswith(("#", "|", ">", "<!--")) or re.fullmatch(r"[-*_=]{3,}", bruta):
            fechar()
            item_aberto = False
            continue
        if ITEM_NUMERADO.match(linha) or AVISO_SEGURANCA.match(linha) or ITEM_CHECKLIST.match(linha):
            fechar()
            corpo = ITEM_CHECKLIST.sub("", ITEM_NUMERADO.sub("", linha)).strip()
            resultado.append((numero, "procedimento", corpo))
            item_aberto = True
            continue
        if ITEM_MARCADOR.match(linha):
            fechar()
            sub_de_passo = item_aberto and CONTINUACAO.match(linha) and resultado[-1][1] == "procedimento"
            tipo = "procedimento" if sub_de_passo else "descritivo"
            resultado.append((numero, tipo, ITEM_MARCADOR.sub("", linha).strip()))
            item_aberto = True
            continue
        if item_aberto and CONTINUACAO.match(linha):
            ini, tipo, corpo = resultado[-1]
            resultado[-1] = (ini, tipo, f"{corpo} {bruta}")
            continue
        item_aberto = False
        if not paragrafo:
            inicio = numero
        paragrafo.append(bruta)
    fechar()
    return resultado


def cerca_aberta(texto: str) -> int:
    """Linha de uma cerca de código sem fechamento (0 se todas fecham)."""
    cerca, linha_aberta = None, 0
    for numero, linha in enumerate(QUEBRA_DE_LINHA.split(texto.lstrip("\ufeff")), start=1):
        marca = CERCA.match(linha.strip())
        if not marca:
            continue
        if cerca is None:
            linha_aberta = numero
        cerca = _alternar_cerca(cerca, marca.group(1))
    return linha_aberta if cerca is not None else 0


def verificar(texto: str, nivel: int = 100, dicionario: list[dict] | None = None) -> Relatorio:
    if nivel not in LIMITES:
        raise ValueError(f"nível inválido: {nivel} (use 100 ou 80)")
    dicionario = carregar_dicionario() if dicionario is None else dicionario
    limites = LIMITES[nivel]
    rel = Relatorio(nivel=nivel)

    aberta = cerca_aberta(texto)
    if aberta:
        rel.achados.append(Achado("A10", "aviso", aberta, "cerca de código sem fechamento: o resto do texto foi ignorado", ""))

    for linha, tipo, bruto in blocos(texto):
        limpo = limpar_inline(bruto)
        frases = [Frase(f, linha, tipo, contar_palavras(f)) for f in dividir_frases(limpo)]
        longo = tipo == "descritivo" and len(frases) > limites["frases_paragrafo"]
        if longo:
            mensagem = f"parágrafo com {len(frases)} frases (máx. {limites['frases_paragrafo']})"
            rel.achados.append(Achado("E03", "erro", linha, mensagem, frases[0].texto[:60]))
        for frase in frases:
            rel.frases += 1
            achados = verificar_frase(frase, nivel, limites, dicionario)
            rel.achados.extend(achados)
            if not longo and not any(a.severidade == "erro" for a in achados):
                rel.frases_ok += 1
    return rel


def _passiva_valida(m: re.Match[str]) -> bool:
    if m.group(1):  # ramo foi/será/ser
        palavra = m.group(1).lower()
        return palavra not in ADJETIVOS and palavra not in SUBSTANTIVOS_NUNCA_PASSIVA
    palavra = m.group(2).lower()  # ramo é/são + agente
    return palavra not in ADJETIVOS and palavra not in SUBSTANTIVOS


def verificar_frase(frase: Frase, nivel: int, limites: dict, dicionario: list[dict]) -> list[Achado]:
    achados: list[Achado] = []
    texto, linha = frase.texto, frase.linha
    procedimento = frase.tipo == "procedimento"
    trecho = texto[:80]

    def add(codigo: str, severidade: str, mensagem: str) -> None:
        achados.append(Achado(codigo, severidade, linha, mensagem, trecho))

    limite = limites[frase.tipo]
    if frase.palavras > limite:
        rotulo = "procedimento" if procedimento else "frase descritiva"
        add("E01" if procedimento else "E02", "erro", f"{rotulo} com {frase.palavras} palavras (máx. {limite})")

    for entrada in dicionario:
        if entrada["categoria"] == "verbo" and not procedimento:
            continue
        # Palavra toda em maiúsculas (DELETE, DROP) é nome técnico, não palavra comum.
        m = next((m for m in entrada["_regex"].finditer(texto) if not m.group(0).isupper()), None)
        if not m:
            continue
        flexivel = nivel == 80 and entrada["categoria"] in CATEGORIAS_FLEXIVEIS_80
        mensagem = f"“{m.group(0)}” não aprovado ({entrada['categoria']}) → {entrada['alternativa']}"
        add("E04", "aviso" if flexivel else "erro", mensagem)

    m = next((m for m in VOZ_PASSIVA.finditer(texto) if _passiva_valida(m)), None)
    if m:
        add("A05", "erro" if procedimento and nivel == 100 else "aviso", f"voz passiva: “{m.group(0)}” → use voz ativa")

    m = GERUNDISMO.search(texto)
    if m:
        add("E06", "erro" if nivel == 100 else "aviso", f"gerundismo: “{m.group(0)}” → use presente ou futuro")

    m = CADEIA_NOMINAL.search(texto)
    if m:
        add("A07", "aviso", f"grupo nominal longo: “{m.group(0)}” (máx. 3 palavras de conteúdo)")

    if procedimento:
        m = MULTIPLAS_INSTRUCOES.search(texto)
        if m:
            add("E08", "erro", f"mais de uma instrução na frase (“{m.group(0).strip()}”) → separe em passos")

    m = FUTURO_DO_PRETERITO.search(texto)
    if m:
        add("A09", "aviso", f"futuro do pretérito “{m.group(0)}” → use presente ou imperativo")

    return achados


def formatar_texto(rel: Relatorio, origem: str) -> str:
    linhas = [f"STE-PT · nível {rel.nivel} · {origem}"]
    for a in sorted(rel.achados, key=lambda a: (a.linha, a.codigo)):
        icone = "✕" if a.severidade == "erro" else "!"
        linhas.append(f"  {icone} L{a.linha:<4} {a.codigo}  {a.mensagem}")
    if rel.frases == 0:
        linhas.append("Resultado: nenhuma frase verificada (arquivo vazio ou só código, tabela e título).")
    else:
        linhas.append(
            f"Resultado: {rel.frases_ok}/{rel.frases} frases conformes ({rel.conformidade}%) · "
            f"{rel.erros} erro(s) · {rel.avisos} aviso(s)"
        )
    return "\n".join(linhas)


def _ler(nome: str) -> str:
    if nome == "-":
        dados = sys.stdin.buffer.read() if hasattr(sys.stdin, "buffer") else sys.stdin.read().encode("utf-8")
        return dados.decode("utf-8-sig")
    caminho = Path(nome)
    if not caminho.is_file():
        raise FileNotFoundError(f"arquivo não encontrado: {nome}")
    return caminho.read_text(encoding="utf-8-sig")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Verificador de Português Técnico Simplificado (STE-PT)")
    parser.add_argument("arquivos", nargs="+", help="arquivos .md/.txt, ou - para stdin")
    parser.add_argument("--nivel", type=int, choices=sorted(LIMITES), default=100)
    parser.add_argument("--formato", choices=("texto", "json"), default="texto")
    args = parser.parse_args(argv)

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    try:
        dicionario = carregar_dicionario()
    except (OSError, ValueError) as exc:
        print(f"dicionário ilegível: {exc}", file=sys.stderr)
        return 2

    saida_json = []
    total_erros = 0
    falha_uso = False
    for nome in args.arquivos:
        try:
            texto = _ler(nome)
        except (OSError, UnicodeDecodeError) as exc:
            motivo = "não é UTF-8" if isinstance(exc, UnicodeDecodeError) else str(exc)
            print(f"{nome}: {motivo}", file=sys.stderr)
            falha_uso = True
            if args.formato == "json":
                saida_json.append({"arquivo": nome, "falha": motivo})
            continue
        rel = verificar(texto, args.nivel, dicionario)
        total_erros += rel.erros
        if args.formato == "json":
            saida_json.append({"arquivo": nome, **rel.to_dict()})
        else:
            print(formatar_texto(rel, nome))
    if args.formato == "json":
        print(json.dumps(saida_json, ensure_ascii=False, indent=2))
    if falha_uso:
        return 2
    return 1 if total_erros else 0


if __name__ == "__main__":
    sys.exit(main())
