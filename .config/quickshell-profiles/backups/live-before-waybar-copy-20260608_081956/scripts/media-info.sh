#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

players = run(["playerctl", "-l"]).splitlines()
player = ""

for p in players:
    status = run(["playerctl", "-p", p, "status"])
    if status == "Playing":
        player = p
        break

if not player and players:
    player = players[0]

def meta(key):
    if not player:
        return ""
    return run(["playerctl", "-p", player, "metadata", key])

status = run(["playerctl", "-p", player, "status"]) if player else "Stopped"
title = meta("xesam:title")
artist = meta("xesam:artist")
album = meta("xesam:album")
art = meta("mpris:artUrl")
length_raw = meta("mpris:length")

position = run(["playerctl", "-p", player, "position"]) if player else "0"

try:
    pos = float(position)
except Exception:
    pos = 0

try:
    # mpris:length is microseconds
    length = int(length_raw) / 1000000
except Exception:
    length = 0

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
    "art": art_url or "",
    "position": pos,
    "length": length
}))
PY
