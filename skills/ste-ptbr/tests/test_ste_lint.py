"""Testes do ste_lint. Rodar: py -m pytest -q skills/ste-ptbr/tests"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import ste_lint as sl

DIC = sl.carregar_dicionario()


def codigos(texto: str, nivel: int = 100, severidade: str | None = None) -> list[str]:
    rel = sl.verificar(texto, nivel, DIC)
    return [a.codigo for a in rel.achados if severidade is None or a.severidade == severidade]


# --- contagem e divisão ---------------------------------------------------------


@pytest.mark.parametrize(
    ("texto", "esperado"),
    [
        ("Exclua o lead duplicado.", 4),
        ("Atualize o e-mail do lead.", 5),  # hífen = 1 palavra
        ("Rode CODIGO na org.", 4),
        ("O job roda às 6h com 1.000 leads.", 8),
    ],
)
def test_contar_palavras(texto: str, esperado: int) -> None:
    assert sl.contar_palavras(texto) == esperado


def test_dividir_frases_respeita_abreviacao() -> None:
    frases = sl.dividir_frases("Use um filtro, p. ex. por e-mail. Depois exporte o setup. Fim.")
    assert frases == ["Use um filtro, p. ex. por e-mail.", "Depois exporte o setup.", "Fim."]


def test_codigo_inline_e_rotulo_conf_nao_inflam_contagem() -> None:
    limpo = sl.limpar_inline("Rode `py -m pytest -q skills/ste-ptbr/tests` agora. [conf: alta]")
    assert sl.contar_palavras(limpo) == 3


# --- limites de tamanho --------------------------------------------------------


def test_procedimento_acima_de_20_palavras_e_erro() -> None:
    passo = "1. " + " ".join(["palavra"] * 21) + "."
    assert "E01" in codigos(passo)


def test_procedimento_com_20_palavras_passa() -> None:
    passo = "1. " + " ".join(["palavra"] * 20) + "."
    assert "E01" not in codigos(passo)


def test_descritivo_acima_de_25_palavras_e_erro() -> None:
    assert "E02" in codigos(" ".join(["palavra"] * 26) + ".")


def test_nivel_80_amplia_limites() -> None:
    passo = "1. " + " ".join(["palavra"] * 24) + "."
    assert "E01" in codigos(passo, 100)
    assert "E01" not in codigos(passo, 80)


def test_paragrafo_com_7_frases_e_erro() -> None:
    paragrafo = " ".join(["O job roda."] * 7)
    assert "E03" in codigos(paragrafo)
    assert "E03" not in codigos(" ".join(["O job roda."] * 6))


# --- dicionário ----------------------------------------------------------------


@pytest.mark.parametrize(
    "texto",
    [
        "Efetue o backup da org.",
        "Utilize o filtro de duplicados.",
        "Delete o lead duplicado.",
        "Garanta que o lead não é duplicado.",
        "Vale ressaltar que o job roda às 6h.",
        "Valide e-mail, telefone, etc.",
        "Envie para o PO e/ou o gestor.",
        "Suba para produção às 18h.",
        "É crucial validar o CPF.",
    ],
)
def test_palavra_nao_aprovada_e_erro_no_nivel_100(texto: str) -> None:
    assert "E04" in codigos(texto, 100, "erro")


@pytest.mark.parametrize(
    "texto",
    [
        "Faça o backup da org.",
        "Use o filtro de duplicados.",
        "Exclua o lead duplicado.",
        "Confirme que o lead não é duplicado.",
        "O job roda às 6h.",
    ],
)
def test_alternativa_aprovada_passa(texto: str) -> None:
    assert codigos(texto) == []


def test_registro_vira_aviso_no_nivel_80_mas_slop_continua_erro() -> None:
    assert codigos("Utilize o filtro.", 80, "erro") == []
    assert "E04" in codigos("Utilize o filtro.", 80, "aviso")
    assert "E04" in codigos("Vale ressaltar que o job roda.", 80, "erro")


def test_verbo_deve_se_so_conta_em_procedimento() -> None:
    assert "E04" in codigos("1. O analista deverá exportar o relatório.")
    assert "E04" not in codigos("O analista deverá exportar o relatório.")


def test_dicionario_tem_exemplos_coerentes() -> None:
    """Todo exemplo não aprovado dispara a própria regra, e o aprovado não."""
    for entrada in DIC:
        assert entrada["_regex"].search(entrada["nao_aprovado"]), entrada["termo"]
        assert not entrada["_regex"].search(entrada["aprovado"]), entrada["termo"]


# --- verbos e estrutura --------------------------------------------------------


def test_voz_passiva_e_erro_em_procedimento_e_aviso_em_descritivo() -> None:
    assert "A05" in codigos("1. O campo deve ser preenchido pelo vendedor.", 100, "erro")
    assert "A05" in codigos("O relatório foi enviado ontem.", 100, "aviso")


def test_adjetivo_em_ido_nao_e_voz_passiva() -> None:
    assert "A05" not in codigos("O e-mail é válido.")


def test_estado_com_e_so_e_passiva_com_agente() -> None:
    assert "A05" not in codigos("O lead é duplicado.")
    assert "A05" in codigos("O lead é aprovado pelo gestor.")


def test_gerundismo_e_erro() -> None:
    assert "E06" in codigos("Vou estar enviando o relatório amanhã.")
    assert "E06" not in codigos("Envio o relatório amanhã.")


def test_cadeia_nominal_longa_gera_aviso() -> None:
    assert "A07" in codigos("A taxa de conversão de leads do evento caiu.", severidade="aviso")
    assert "A07" not in codigos("A conversão dos leads caiu.")


def test_duas_instrucoes_no_mesmo_passo_e_erro() -> None:
    assert "E08" in codigos("1. Exporte o relatório e depois envie ao PO.")
    assert "E08" in codigos("1. Exporte o relatório; envie ao PO.")
    assert "E08" not in codigos("1. Exporte o relatório.")


def test_futuro_do_preterito_gera_aviso() -> None:
    assert "A09" in codigos("O job deveria rodar às 6h.", severidade="aviso")


def test_aviso_de_seguranca_e_tratado_como_procedimento() -> None:
    texto = "⛔ BLOQUEIO: Não rode DELETE sem WHERE. O comando apaga a tabela inteira."
    tipos = {tipo for _, tipo, _ in sl.blocos(texto)}
    assert tipos == {"procedimento"}


# --- Markdown ------------------------------------------------------------------


def test_ignora_codigo_cercado_tabela_e_titulo() -> None:
    texto = (
        "# Título enorme que tem muitas palavras e não deve contar para nada aqui\n"
        "```sql\n"
        "DELETE FROM leads; -- utilize garanta etc\n"
        "```\n"
        "| Efetue | Utilize |\n"
        "Exclua o lead.\n"
    )
    rel = sl.verificar(texto, 100, DIC)
    assert rel.frases == 1
    assert rel.erros == 0


def test_ignora_frontmatter_yaml() -> None:
    texto = "---\nname: x\ndescription: Utilize e efetue etc. e/ou garanta tudo.\n---\nExclua o lead.\n"
    rel = sl.verificar(texto, 100, DIC)
    assert rel.frases == 1
    assert rel.erros == 0


def test_comando_em_maiusculas_e_nome_tecnico() -> None:
    assert "E04" not in codigos("Não rode DELETE sem WHERE.")
    assert "E04" in codigos("Não delete o lead.")


EXEMPLOS = Path(__file__).resolve().parent.parent / "references" / "exemplos-febracis.md"


def test_exemplos_febracis_passam_no_nivel_100() -> None:
    rel = sl.verificar(EXEMPLOS.read_text(encoding="utf-8"), 100, DIC)
    assert rel.erros == 0, [a.mensagem for a in rel.achados]
    assert rel.frases >= 15


# --- regressões da revisão adversarial (02/10/2026) -------------------------------


def test_dicionario_ida_e_volta_pelo_verificar() -> None:
    """Exemplos do dicionário passam pelo fluxo completo (blocos, maiúsculas, categoria verbo)."""
    for entrada in DIC:
        prefixo = "1. " if entrada["categoria"] == "verbo" else ""
        assert "E04" in codigos(prefixo + entrada["nao_aprovado"]), entrada["termo"]
        assert "E04" not in codigos(prefixo + entrada["aprovado"]), entrada["termo"]


@pytest.mark.parametrize(
    "texto",
    ["O lead será excluído.", "O lead foi incluído pelo sistema.", "O chamado foi aberto.", "O acesso foi dado ao time."],
)
def test_passiva_com_participio_acentuado_e_irregular(texto: str) -> None:
    assert "A05" in codigos(texto)


def test_passiva_nao_marca_substantivo_depois_de_foi() -> None:
    assert "A05" not in codigos("O atraso foi resultado do limite de API.")


def test_em_nivel_de_do_salesforce_e_aprovado() -> None:
    assert "E04" not in codigos("A segurança em nível de campo bloqueia o acesso.")
    assert "E04" in codigos("Erro a nível de perfil.")


@pytest.mark.parametrize(
    ("texto", "codigo", "esperado"),
    [
        ("Eu vou estar te enviando o arquivo.", "E06", True),
        ("O job pode estar falhando.", "E06", False),
        ("1. Exclua os leads, depois de confirmar o total.", "E08", False),
        ("O código sobe para produção.", "E04", True),
        ("O custo subiu em produção.", "E04", False),
        ("Abra o lead e envie o mesmo ao gestor.", "E04", True),
        ("Use o mesmo filtro.", "E04", False),
        ("Uma alavanca de crescimento.", "E04", False),
        ("Utilizamos o filtro.", "E04", True),
        ("O período de garantia acabou.", "E04", False),
        ("Eu gostaria de exportar o relatório.", "A09", True),
    ],
)
def test_regras_ajustadas(texto: str, codigo: str, esperado: bool) -> None:
    assert (codigo in codigos(texto)) is esperado


def test_gerundismo_vira_aviso_no_nivel_80() -> None:
    assert "E06" in codigos("Vou estar enviando o relatório.", 80, "aviso")


def test_passo_quebrado_em_duas_linhas_e_um_bloco() -> None:
    texto = "1. " + " ".join(["palavra"] * 14) + "\n   " + " ".join(["palavra"] * 14) + ".\n"
    assert [tipo for _, tipo, _ in sl.blocos(texto)] == ["procedimento"]
    assert "E01" in codigos(texto)


def test_checklist_e_procedimento() -> None:
    assert "E08" in codigos("- [ ] Rode o job de deploy; confira o log.")


def test_aviso_sem_seletor_de_variacao() -> None:
    assert sl.blocos("⚠ ATENÇÃO: Confirme o total.")[0][1] == "procedimento"


def test_link_e_url_contam_uma_palavra() -> None:
    assert sl.contar_palavras(sl.limpar_inline("Veja o [Relatório de comissões do Método CIS](https://x.com/a).")) == 3
    assert len(sl.dividir_frases(sl.limpar_inline("Veja https://febracis.com.br. O job roda às 6h. Depois saia."))) == 3


def test_underscore_faz_parte_da_palavra() -> None:
    assert sl.contar_palavras("Preencha Data_Evento__c agora.") == 3


def test_abreviacoes_e_aspas_de_fechamento() -> None:
    assert len(sl.dividir_frases("O Prof. Silva aprovou. Ele saiu.")) == 2
    assert len(sl.dividir_frases('Ele disse "use isto." Depois saiu.')) == 2


def test_bom_e_hr_no_topo() -> None:
    assert sl.verificar("﻿---\ndescription: utilizar efetuar\n---\nExclua o lead.\n", 100, DIC).erros == 0
    rel = sl.verificar("---\nExclua o lead.\n\n---\nUse o filtro.\n", 100, DIC)
    assert rel.frases == 2  # "---" sem chave YAML é linha horizontal, não frontmatter


def test_cerca_sem_fechamento_e_cercas_mistas() -> None:
    rel = sl.verificar("```\nutilizar\n\nUtilize o job.\n", 100, DIC)
    assert any(a.codigo == "A10" for a in rel.achados)
    assert sl.verificar("```\n~~~\n```\nUtilize o job.\n", 100, DIC).erros == 1


def test_paragrafo_longo_reduz_conformidade() -> None:
    rel = sl.verificar(" ".join(["O job roda."] * 10), 100, DIC)
    assert rel.conformidade == 0.0


def test_cli_arquivo_nao_utf8_e_varios_arquivos(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    ruim = tmp_path / "cp1252.md"
    ruim.write_bytes("Não use isto.".encode("cp1252"))
    bom = tmp_path / "bom.md"
    bom.write_text("﻿Exclua o lead.\n", encoding="utf-8")
    assert sl.main([str(ruim)]) == 2
    assert sl.main([str(bom)]) == 0
    capsys.readouterr()
    assert sl.main([str(bom), str(tmp_path / "nao-existe.md"), "--formato", "json"]) == 2
    saida = capsys.readouterr().out
    dados = json.loads(saida[saida.index("[") :])
    assert len(dados) == 2
    assert dados[1]["falha"]


# --- regressões da re-checagem (02/10/2026) --------------------------------------


@pytest.mark.parametrize(
    ("texto", "esperado"),
    [
        ("Dois leads têm o mesmo e-mail.", False),
        ("Envie o mesmo e o outro.", True),
        ("O utilizador do sistema.", False),
        ("O possuidor da conta.", False),
        ("Alavanque a venda.", True),
        ("Suba a versão.", False),
        ("Suba o pacote.", True),
    ],
)
def test_dicionario_apos_recheck(texto: str, esperado: bool) -> None:
    assert ("E04" in codigos(texto)) is esperado


def test_subitem_de_passo_e_procedimento() -> None:
    texto = "1. Abra o lead.\n   - Exporte o arquivo; depois salve.\n"
    assert [tipo for _, tipo, _ in sl.blocos(texto)] == ["procedimento", "procedimento"]
    assert "E08" in codigos(texto)


def test_cerca_de_quatro_crases_com_tres_dentro() -> None:
    texto = "````md\n```\nutilizar\n```\n````\nUse o job.\n"
    rel = sl.verificar(texto, 100, DIC)
    assert rel.frases == 1
    assert rel.erros == 0


def test_conformidade_arredonda_meio_para_cima() -> None:
    texto = "Use o job.\n\n" + "\n\n".join(["Utilize o job."] * 15)
    assert sl.verificar(texto, 100, DIC).conformidade == 6.3


def test_retorno_de_carro_solto_quebra_linha() -> None:
    texto = "1. Use o job.\r2. Efetue o job.\r3. Use o job."
    assert len(sl.blocos(texto)) == 3


def test_prancha_usa_dicionario_atual() -> None:
    import build_prancha

    assert build_prancha.SAIDA.read_text(encoding="utf-8") == build_prancha.gerar(), (
        "assets/prancha-ste-pt.html desatualizada: rode scripts/build_prancha.py"
    )


def test_conformidade_e_relatorio_json() -> None:
    rel = sl.verificar("Exclua o lead.\n\nUtilize o filtro.", 100, DIC)
    dados = rel.to_dict()
    assert dados["frases"] == 2
    assert dados["frases_ok"] == 1
    assert dados["conformidade"] == 50.0
    json.dumps(dados, ensure_ascii=False)


def test_nivel_invalido_levanta_erro() -> None:
    with pytest.raises(ValueError):
        sl.verificar("Texto.", 50, DIC)


# --- CLI -----------------------------------------------------------------------


def test_cli_codigo_de_saida(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    bom = tmp_path / "bom.md"
    bom.write_text("1. Exporte o relatório.\n2. Envie o relatório ao PO.\n", encoding="utf-8")
    ruim = tmp_path / "ruim.md"
    ruim.write_text("1. Efetue o backup e depois delete o lead.\n", encoding="utf-8")

    assert sl.main([str(bom)]) == 0
    assert sl.main([str(ruim)]) == 1
    assert sl.main([str(tmp_path / "nao-existe.md")]) == 2

    assert sl.main([str(ruim), "--formato", "json"]) == 1
    saida = capsys.readouterr().out
    dados = json.loads(saida[saida.index("[") :])
    assert dados[0]["erros"] >= 2
