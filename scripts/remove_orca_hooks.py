#!/usr/bin/env python3
"""Remove os hooks do Orca (app desinstalado) do Claude Code e do Cursor.

O Orca só usa o hook quando o agente roda dentro do terminal dele (variáveis ORCA_*).
Fora disso, cada evento abre um cmd.exe que sai sem fazer nada.

  py -3 remove_orca_hooks.py            # remove (backup *.bak-orca)
  py -3 remove_orca_hooks.py --dry-run  # só mostra o que sairia
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

MARKER = ".orca"


def _is_orca(cmd: str) -> bool:
    return MARKER in cmd.replace("\\", "/").lower()


def clean_claude(data: dict) -> int:
    removed = 0
    hooks = data.get("hooks", {})
    for event in list(hooks):
        kept_groups = []
        for grp in hooks[event]:
            inner = [h for h in grp.get("hooks", []) if not _is_orca(h.get("command", ""))]
            removed += len(grp.get("hooks", [])) - len(inner)
            if inner:
                kept_groups.append({**grp, "hooks": inner})
        if kept_groups:
            hooks[event] = kept_groups
        else:
            del hooks[event]
    return removed


def clean_cursor(data: dict) -> int:
    removed = 0
    hooks = data.get("hooks", {})
    for event in list(hooks):
        kept = [h for h in hooks[event] if not _is_orca(h.get("command", ""))]
        removed += len(hooks[event]) - len(kept)
        if kept:
            hooks[event] = kept
        else:
            del hooks[event]
    return removed


def process(path: Path, cleaner, dry_run: bool) -> str:
    if not path.exists():
        return f"{path}: não existe"
    data = json.loads(path.read_text(encoding="utf-8"))
    removed = cleaner(data)
    if removed and not dry_run:
        shutil.copy2(path, path.with_name(path.name + ".bak-orca"))
        path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    verb = "sairiam" if dry_run else "removidos"
    return f"{path}: {removed} hook(s) do Orca {verb}"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--claude-settings", default=str(Path.home() / ".claude" / "settings.json"))
    ap.add_argument("--cursor-hooks", default=str(Path.home() / ".cursor" / "hooks.json"))
    args = ap.parse_args(argv)
    print(process(Path(args.claude_settings), clean_claude, args.dry_run))
    print(process(Path(args.cursor_hooks), clean_cursor, args.dry_run))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
