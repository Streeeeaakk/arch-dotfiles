#!/usr/bin/env bash

desktop_file="$1"

python - "$desktop_file" <<'PY'
from pathlib import Path
import subprocess
import sys
import re

path = Path(sys.argv[1])

if not path.exists():
    sys.exit(1)

data = {}
in_entry = False

for line in path.read_text(errors="ignore").splitlines():
    line = line.strip()

    if not line or line.startswith("#"):
        continue

    if line.startswith("[") and line.endswith("]"):
        in_entry = line == "[Desktop Entry]"
        continue

    if not in_entry or "=" not in line:
        continue

    key, value = line.split("=", 1)

    if key not in data:
        data[key] = value

cmd = data.get("Exec", "").strip()
terminal = data.get("Terminal", "").lower() == "true"

if not cmd:
    sys.exit(1)

cmd = cmd.replace("%%", "__PERCENT__")
cmd = re.sub(r"%[fFuUdDnNickvm]", "", cmd)
cmd = cmd.replace("__PERCENT__", "%").strip()

if terminal:
    subprocess.Popen(
        ["kitty", "-e", "sh", "-lc", cmd],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
else:
    subprocess.Popen(
        ["sh", "-lc", cmd],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
PY
