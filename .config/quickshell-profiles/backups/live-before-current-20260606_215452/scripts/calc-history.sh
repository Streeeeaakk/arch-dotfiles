#!/usr/bin/env bash

python - <<'PY'
import json
from pathlib import Path

hist = Path.home() / ".cache/quickshell/calc-history.jsonl"
items = []

if hist.exists():
    rows = hist.read_text(encoding="utf-8", errors="ignore").splitlines()

    for line in reversed(rows[-80:]):
        try:
            row = json.loads(line)
        except Exception:
            continue

        expr = row.get("expr", "")
        result = row.get("result", "")

        if not expr or not result:
            continue

        items.append({
            "id": "",
            "name": f"{expr} = {result}",
            "comment": "Calculation history",
            "icon": "",
            "isImage": False,
            "path": result
        })

print(json.dumps(items, ensure_ascii=False))
PY
