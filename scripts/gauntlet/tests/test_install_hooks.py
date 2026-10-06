"""Testes do instalador de hooks — sempre em arquivos temporários."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import install_hooks as ih  # noqa: E402

ORCA = {"hooks": [{"type": "command", "command": '"C:/x/claude-hook.cmd"', "timeout": 5}]}


def _setup(tmp_path: Path) -> tuple[Path, Path]:
    claude = tmp_path / "settings.json"
    claude.write_text(json.dumps({"model": "x", "hooks": {"Stop": [ORCA]}}), encoding="utf-8")
    cursor = tmp_path / "hooks.json"
    cursor.write_text(json.dumps({"version": 1, "hooks": {"stop": [{"command": "orca", "timeout": 5}]}}))
    return claude, cursor


def _args(claude: Path, cursor: Path, *extra: str) -> list[str]:
    return ["--claude-settings", str(claude), "--cursor-hooks", str(cursor), *extra]


def test_instala_preservando_hooks_existentes(tmp_path: Path) -> None:
    claude, cursor = _setup(tmp_path)
    ih.main(_args(claude, cursor))
    c = json.loads(claude.read_text(encoding="utf-8"))
    assert c["model"] == "x"
    assert c["hooks"]["Stop"][0] == ORCA
    cmd = c["hooks"]["Stop"][1]["hooks"][0]["command"]
    assert cmd.startswith('py -3 "') and cmd.endswith('gauntlet.py" hook') and "\\" not in cmd
    k = json.loads(cursor.read_text(encoding="utf-8"))
    assert [h["command"] for h in k["hooks"]["stop"]][0] == "orca"
    assert "gauntlet.py" in k["hooks"]["stop"][1]["command"]
    assert (tmp_path / "settings.json.bak-gauntlet").exists()


def test_idempotente(tmp_path: Path) -> None:
    claude, cursor = _setup(tmp_path)
    ih.main(_args(claude, cursor))
    first = claude.read_text(encoding="utf-8")
    assert "sem mudança" in ih.claude(claude, uninstall=False)
    assert claude.read_text(encoding="utf-8") == first


def test_desinstala(tmp_path: Path) -> None:
    claude, cursor = _setup(tmp_path)
    ih.main(_args(claude, cursor))
    ih.main(_args(claude, cursor, "--uninstall"))
    assert json.loads(claude.read_text(encoding="utf-8"))["hooks"]["Stop"] == [ORCA]
    assert json.loads(cursor.read_text(encoding="utf-8"))["hooks"]["stop"] == [{"command": "orca", "timeout": 5}]


def test_cria_arquivo_ausente(tmp_path: Path) -> None:
    ih.main(_args(tmp_path / "a" / "settings.json", tmp_path / "b" / "hooks.json"))
    assert json.loads((tmp_path / "b" / "hooks.json").read_text(encoding="utf-8"))["version"] == 1
