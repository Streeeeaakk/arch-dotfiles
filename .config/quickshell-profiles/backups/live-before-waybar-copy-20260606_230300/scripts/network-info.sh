#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

def clean(s):
    return (s or "").strip()

device = ""
connection = "Disconnected"
state = "disconnected"
ip = "-"
gateway = "-"
signal = "0"

status = run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"])
for line in status.splitlines():
    parts = line.split(":", 3)
    if len(parts) < 4:
        continue

    dev, typ, st, conn = parts

    if typ == "wifi":
        device = dev
        state = st
        connection = conn if conn and conn != "--" else "Disconnected"
        break

if device:
    details = run(["nmcli", "-t", "-f", "IP4.ADDRESS,IP4.GATEWAY", "device", "show", device])
    for line in details.splitlines():
        if line.startswith("IP4.ADDRESS"):
            ip = line.split(":", 1)[1].strip()
        elif line.startswith("IP4.GATEWAY"):
            gateway = line.split(":", 1)[1].strip()

    wifi = run(["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "ifname", device, "--rescan", "no"])
else:
    wifi = run(["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"])

networks = []
seen = set()

for line in wifi.splitlines():
    parts = line.split(":")
    if len(parts) < 4:
        continue

    active = clean(parts[0])
    ssid = clean(parts[1])
    sig = clean(parts[2])
    security = clean(":".join(parts[3:]))

    if not ssid or ssid in seen:
        continue

    seen.add(ssid)

    if active == "yes":
        connection = ssid
        signal = sig

    networks.append({
        "active": active == "yes",
        "ssid": ssid,
        "signal": sig or "0",
        "security": security or "open"
    })

networks.sort(key=lambda x: (not x["active"], -int(x["signal"]) if x["signal"].isdigit() else 0))
networks = networks[:6]

print(json.dumps({
    "device": device or "-",
    "connection": connection,
    "state": state,
    "ip": ip,
    "gateway": gateway,
    "signal": signal,
    "networks": networks
}))
PY
