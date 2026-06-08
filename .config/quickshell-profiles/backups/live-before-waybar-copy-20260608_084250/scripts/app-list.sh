#!/usr/bin/env bash

python - <<'PY'
from pathlib import Path
import configparser
import json
import os
import re

desktop_dirs = [
    Path.home() / ".local/share/applications",
    Path("/usr/local/share/applications"),
    Path("/usr/share/applications"),
]

icon_dirs = [
    Path.home() / ".local/share/icons",
    Path.home() / ".icons",
    Path("/usr/share/icons"),
    Path("/usr/share/pixmaps"),
]

icon_exts = [".png", ".svg", ".xpm", ".jpg", ".jpeg"]

def clean_exec(cmd):
    if not cmd:
        return ""
    cmd = re.sub(r"\s+%[fFuUdDnNickvm]", "", cmd)
    cmd = cmd.replace("@@u", "").replace("@@", "")
    return cmd.strip()

def find_icon(icon):
    if not icon:
        return ""

    icon = icon.strip()

    # Absolute icon path
    if icon.startswith("/") and Path(icon).exists():
        return icon

    # Icon name with extension
    names = [icon]
    if not any(icon.endswith(ext) for ext in icon_exts):
        names += [icon + ext for ext in icon_exts]

    # Fast direct common locations
    for base in icon_dirs:
        for name in names:
            p = base / name
            if p.exists():
                return str(p)

    # Safe recursive search
    for base in icon_dirs:
        if not base.exists():
            continue
        try:
            for name in names:
                found = next(base.rglob(name), None)
                if found:
                    return str(found)
        except Exception:
            pass

    return ""

def parse_desktop(path):
    cp = configparser.ConfigParser(interpolation=None, strict=False)
    try:
        cp.read(path, encoding="utf-8")
    except Exception:
        return None

    if "Desktop Entry" not in cp:
        return None

    d = cp["Desktop Entry"]

    if d.get("NoDisplay", "").lower() == "true":
        return None
    if d.get("Hidden", "").lower() == "true":
        return None
    if d.get("Type", "") != "Application":
        return None

    name = d.get("Name", "").strip()
    exec_cmd = clean_exec(d.get("Exec", "").strip())
    icon = find_icon(d.get("Icon", "").strip())

    if not name or not exec_cmd:
        return None

    return {
        "name": name,
        "exec": exec_cmd,
        "icon": icon,
        "desktop": str(path),
    }

apps = []
seen = set()

for d in desktop_dirs:
    if not d.exists():
        continue
    for path in d.glob("*.desktop"):
        app = parse_desktop(path)
        if not app:
            continue
        key = app["name"].lower()
        if key in seen:
            continue
        seen.add(key)
        apps.append(app)

apps.sort(key=lambda x: x["name"].lower())

print(json.dumps(apps, ensure_ascii=False))
PY
