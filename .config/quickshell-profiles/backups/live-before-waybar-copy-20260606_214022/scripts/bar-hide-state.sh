#!/usr/bin/env bash

MANUAL="/tmp/quickshell-bar-hidden"
BAR_H=56

python - "$MANUAL" "$BAR_H" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

manual_file = Path(sys.argv[1])
bar_h = int(sys.argv[2])

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

hidden = set()

try:
    monitors = json.loads(run(["hyprctl", "monitors", "-j"]) or "[]")
    clients = json.loads(run(["hyprctl", "clients", "-j"]) or "[]")
except Exception:
    monitors = []
    clients = []

# Map monitor id/index to monitor name
monitor_by_id = {}
for i, mon in enumerate(monitors):
    name = mon.get("name", "")
    mid = mon.get("id", i)

    if name:
        monitor_by_id[str(mid)] = name
        monitor_by_id[str(i)] = name

# Manual fullscreen state
if manual_file.exists():
    parts = manual_file.read_text(errors="ignore").strip().split("\t")
    if len(parts) >= 2 and parts[1] == "1":
        mon = parts[0]
        hidden.add(monitor_by_id.get(mon, mon))

for c in clients:
    # Only floating windows
    if not c.get("floating", False):
        continue

    if c.get("hidden", False):
        continue

    mon_raw = str(c.get("monitor", ""))
    mon_name = monitor_by_id.get(mon_raw, mon_raw)

    at = c.get("at", [9999, 9999])
    size = c.get("size", [0, 0])

    y = int(at[1])
    h = int(size[1])

    # Hide if floating window touches/overlaps top bar area
    if mon_name and h > 0 and y <= bar_h:
        hidden.add(mon_name)

print("|" + "|".join(sorted(hidden)) + "|" if hidden else "")
PY
