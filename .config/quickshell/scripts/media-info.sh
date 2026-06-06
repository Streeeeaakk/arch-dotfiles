#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

player = run(["playerctl", "-l"]).splitlines()
player = player[0] if player else ""

def meta(key):
    if not player:
        return ""
    return run(["playerctl", "-p", player, "metadata", key])

status = run(["playerctl", "-p", player, "status"]) if player else "Stopped"
title = meta("xesam:title")
artist = meta("xesam:artist")
album = meta("xesam:album")
art = meta("mpris:artUrl")

if art.startswith("file://"):
    art_url = art
elif art.startswith("/"):
    art_url = "file://" + art
else:
    art_url = art

print(json.dumps({
    "player": player or "No Player",
    "status": status or "Stopped",
    "title": title or "Nothing Playing",
    "artist": artist or "",
    "album": album or "",
    "art": art_url or ""
}))
PY
