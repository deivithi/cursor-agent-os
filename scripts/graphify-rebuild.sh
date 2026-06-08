#!/bin/bash
# Graphify incremental rebuild — runs on session Stop
# Rebuilds the knowledge graph with only changed files (SHA256 cache)
# Non-blocking: runs in background, does not delay session exit

GRAPHIFY_PYTHON="$HOME/.graphify-env/Scripts/python.exe"
[ -x "$GRAPHIFY_PYTHON" ] || exit 0

GRAPH_JSON="${CLAUDE_PROJECT_DIR:-.}/graphify-out/graph.json"
[ -f "$GRAPH_JSON" ] || exit 0

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# Run incremental rebuild in background (detached)
"$GRAPHIFY_PYTHON" -c "
import json
from pathlib import Path
from graphify.detect import detect
from graphify.extract import extract
from graphify.build import build_from_json
from graphify.cluster import cluster
from graphify.export import to_json

result = detect(Path('.'))
code_files = [Path(f) for f in result.get('files',{}).get('code',[])]
if not code_files:
    exit(0)
ast = extract(code_files)
G = build_from_json(ast)
comms = cluster(G)
to_json(G, comms, 'graphify-out/graph.json')
" 2>/dev/null &

exit 0
