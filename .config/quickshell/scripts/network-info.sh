#!/usr/bin/env bash

python - <<'PY'
import json
import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

device = "-"
connection = "Disconnected"
state = "disconnected"
ip = "-"
gateway = "-"
signal = "0"
networks = []

status = run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device", "status"])

# Prefer connected ethernet, fallback to connected wifi
chosen = None
wifi_device = None

for line in status.splitlines():
    parts = line.split(":", 3)
    if len(parts) < 4:
        continue

    dev, typ, st, conn = parts

    if typ == "wifi":
        wifi_device = dev

    if st == "connected" and typ == "ethernet":
        chosen = (dev, typ, st, conn)
        break

    if st == "connected" and typ == "wifi" and chosen is None:
        chosen = (dev, typ, st, conn)

if chosen:
    device, typ, state, connection = chosen
    if not connection or connection == "--":
        connection = "Connected"

    details = run(["nmcli", "-t", "-f", "IP4.ADDRESS,IP4.GATEWAY", "device", "show", device])
    for line in details.splitlines():
        if line.startswith("IP4.ADDRESS"):
            ip = line.split(":", 1)[1].strip().split("/")[0]
        elif line.startswith("IP4.GATEWAY"):
            gateway = line.split(":", 1)[1].strip()

    if typ == "ethernet":
        connection = "LAN"
        signal = "100"

# Wi-Fi list for popup, only if wifi exists
wifi_cmd = ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"]
if wifi_device:
    wifi_cmd = ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "ifname", wifi_device, "--rescan", "no"]

wifi = run(wifi_cmd)
seen = set()

for line in wifi.splitlines():
    parts = line.split(":")
    if len(parts) < 4:
        continue

    active = parts[0].strip()
    ssid = parts[1].strip()
    sig = parts[2].strip()
    security = ":".join(parts[3:]).strip()

    if not ssid or ssid in seen:
        continue

    seen.add(ssid)

    networks.append({
        "active": active == "yes",
        "ssid": ssid,
        "signal": sig or "0",
        "security": security or "open"
    })

networks.sort(key=lambda x: (not x["active"], -int(x["signal"]) if x["signal"].isdigit() else 0))
networks = networks[:6]

print(json.dumps({
    "device": device,
    "connection": connection,
    "state": state,
    "ip": ip,
    "gateway": gateway,
    "signal": signal,
    "networks": networks
}))
PY
