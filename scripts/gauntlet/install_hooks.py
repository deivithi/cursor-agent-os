#!/usr/bin/env python3
"""Registra (ou remove) o Stop hook do gauntlet no Claude Code e no Cursor.

Idempotente. Faz backup `.bak-gauntlet` antes de gravar.

  py -3 install_hooks.py            # instala
  py -3 install_hooks.py --uninstall
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

SCRIPT = Path(__file__).resolve().with_name("gauntlet.py")
MARKER = "gauntlet.py"
# Git Bash (Claude Code no Windows) exige barra normal + aspas no caminho.
CLAUDE_CMD = f'py -3 "{SCRIPT.as_posix()}" hook'
CURSOR_CMD = f'py -3 "{SCRIPT}" hook'


def _load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


def _save(path: Path, data: dict) -> None:
    if path.exists():
        shutil.copy2(path, path.with_name(path.name + ".bak-gauntlet"))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def claude(path: Path, uninstall: bool) -> str:
    data = _load(path)
    stop = data.setdefault("hooks", {}).setdefault("Stop", [])
    kept = [grp for grp in stop if not any(MARKER in h.get("command", "") for h in grp.get("hooks", []))]
    if not uninstall:
        kept.append(
            {
                "hooks": [
                    {
                        "type": "command",
                        "command": CLAUDE_CMD,
                        "timeout": 900,
                        "statusMessage": "🧪 Gauntlet avaliando o código alterado...",
                    }
                ]
            }
        )
    changed = kept != stop
    data["hooks"]["Stop"] = kept
    if changed:
        _save(path, data)
    return f"{path}: {'removido' if uninstall else 'instalado'}{'' if changed else ' (sem mudança)'}"


def cursor(path: Path, uninstall: bool) -> str:
    data = _load(path)
    data.setdefault("version", 1)
    stop = data.setdefault("hooks", {}).setdefault("stop", [])
    kept = [h for h in stop if MARKER not in h.get("command", "")]
    if not uninstall:
        kept.append({"command": CURSOR_CMD, "timeout": 900})
    changed = kept != stop
    data["hooks"]["stop"] = kept
    if changed:
        _save(path, data)
    return f"{path}: {'removido' if uninstall else 'instalado'}{'' if changed else ' (sem mudança)'}"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--uninstall", action="store_true")
    ap.add_argument("--claude-settings", default=str(Path.home() / ".claude" / "settings.json"))
    ap.add_argument("--cursor-hooks", default=str(Path.home() / ".cursor" / "hooks.json"))
    args = ap.parse_args(argv)
    print(claude(Path(args.claude_settings), args.uninstall))
    print(cursor(Path(args.cursor_hooks), args.uninstall))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
