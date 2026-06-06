#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

raw = run(["cliphist", "list"])
items = []

for line in raw.splitlines()[:80]:
    if not line.strip():
        continue

    parts = line.split("\t", 1)
    if len(parts) == 2:
        cid, text = parts
    else:
        cid, text = "", line

    text = text.replace("\n", " ").strip()

    items.append({
        "id": cid,
        "name": text[:120],
        "comment": "Clipboard history",
        "icon": "",
        "path": line
    })

print(json.dumps(items))
PY
