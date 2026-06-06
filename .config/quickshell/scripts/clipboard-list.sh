#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess
import hashlib
from pathlib import Path

CACHE = Path.home() / ".cache/quickshell/clipboard"
CACHE.mkdir(parents=True, exist_ok=True)

def run(cmd, input_text=None, binary=False):
    try:
        out = subprocess.check_output(
            cmd,
            input=input_text.encode() if input_text is not None else None,
            stderr=subprocess.DEVNULL
        )
        return out if binary else out.decode(errors="ignore").strip()
    except Exception:
        return b"" if binary else ""

raw = run(["cliphist", "list"])
items = []

def image_ext(line):
    low = line.lower()

    if "image/jpeg" in low or "image/jpg" in low or " jpg " in low or " jpeg " in low:
        return ".jpg"

    if "image/webp" in low or " webp " in low:
        return ".webp"

    if "image/bmp" in low or " bmp " in low:
        return ".bmp"

    if "image/gif" in low or " gif " in low:
        return ".gif"

    if "image/png" in low or " png " in low or "binary data" in low:
        return ".png"

    return ""

for line in raw.splitlines()[:80]:
    if not line.strip():
        continue

    parts = line.split("\t", 1)
    if len(parts) == 2:
        cid, preview = parts
    else:
        cid, preview = "", line

    preview_clean = preview.replace("\n", " ").strip()
    ext = image_ext(line)
    is_image = ext != ""
    icon_path = ""

    if is_image:
        h = hashlib.sha1(line.encode()).hexdigest()
        out_file = CACHE / f"{h}{ext}"

        if not out_file.exists() or out_file.stat().st_size == 0:
            data = run(["cliphist", "decode"], input_text=line + "\n", binary=True)
            if data:
                out_file.write_bytes(data)

        if out_file.exists() and out_file.stat().st_size > 0:
            icon_path = "file://" + str(out_file)

        preview_clean = preview_clean or "Image from clipboard"

    items.append({
        "id": cid,
        "name": preview_clean[:120],
        "comment": "Image" if is_image else "Clipboard text",
        "icon": icon_path,
        "isImage": is_image,
        "path": line
    })

print(json.dumps(items, ensure_ascii=False))
PY
