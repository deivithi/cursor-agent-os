#!/bin/bash
# Validate JSON output against a JSON Schema
# Usage: bash validate-output.sh <output.json> <schema.json>
# Requires: Python 3 with jsonschema (pip install jsonschema)

OUTPUT_FILE="${1:-}"
SCHEMA_FILE="${2:-}"

if [ -z "$OUTPUT_FILE" ] || [ -z "$SCHEMA_FILE" ]; then
    echo "Usage: validate-output.sh <output.json> <schema.json>"
    exit 1
fi

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "ERROR: Output file not found: $OUTPUT_FILE"
    exit 1
fi

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "ERROR: Schema file not found: $SCHEMA_FILE"
    exit 1
fi

# Validate using Python jsonschema
"C:/Users/PC/.browser-use-env/Scripts/python.exe" -c "
import json, sys
try:
    from jsonschema import validate, ValidationError
except ImportError:
    print('ERROR: jsonschema not installed. Run: pip install jsonschema')
    sys.exit(2)

with open('$OUTPUT_FILE') as f:
    data = json.load(f)
with open('$SCHEMA_FILE') as f:
    schema = json.load(f)

try:
    validate(instance=data, schema=schema)
    print('VALID: Output matches schema')
    sys.exit(0)
except ValidationError as e:
    print(f'INVALID: {e.message}')
    print(f'Path: {\".\".join(str(p) for p in e.path)}')
    sys.exit(1)
" 2>&1
