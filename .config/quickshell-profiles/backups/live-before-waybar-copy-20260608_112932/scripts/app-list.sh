#!/usr/bin/env bash

python - <<'PY'
from pathlib import Path
import configparser
import json
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

    if icon.startswith("/"):
        p = Path(icon)
        return str(p) if p.exists() else ""

    names = [icon]
    if not any(icon.endswith(ext) for ext in icon_exts):
        names += [icon + ext for ext in icon_exts]

    for base in icon_dirs:
        if not base.exists():
            continue

        for name in names:
            direct = base / name
            if direct.exists():
                return str(direct)

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

    if d.get("Type", "") != "Application":
        return None
    if d.get("NoDisplay", "").lower() == "true":
        return None
    if d.get("Hidden", "").lower() == "true":
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
        "path": str(path),
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
