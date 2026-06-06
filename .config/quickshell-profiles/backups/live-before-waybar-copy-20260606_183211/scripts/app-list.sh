#!/usr/bin/env bash

python - <<'PY'
from pathlib import Path
import json
import os

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

icon_exts = [".png", ".svg", ".xpm", ".webp"]

apps = []
seen = set()

def resolve_icon(icon):
    if not icon:
        return ""

    icon = icon.strip()

    p = Path(icon)
    if p.is_absolute() and p.exists():
        return "file://" + str(p)

    # Direct pixmaps fallback
    for ext in icon_exts:
        p = Path("/usr/share/pixmaps") / (icon if icon.endswith(ext) else icon + ext)
        if p.exists():
            return "file://" + str(p)

    # Theme icon lookup
    names = [icon]
    if "." in icon:
        names.append(icon.split(".")[0])

    for base in icon_dirs:
        if not base.exists():
            continue

        for name in names:
            for ext in icon_exts:
                matches = list(base.rglob(name + ext))
                if matches:
                    matches.sort(key=lambda x: (len(str(x)), str(x)))
                    return "file://" + str(matches[0])

    return ""

def parse_desktop(path):
    data = {}
    in_entry = False

    try:
        lines = path.read_text(errors="ignore").splitlines()
    except Exception:
        return None

    for line in lines:
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

    if data.get("Type") != "Application":
        return None

    if data.get("NoDisplay", "").lower() == "true":
        return None

    if data.get("Hidden", "").lower() == "true":
        return None

    name = data.get("Name", "").strip()
    exec_cmd = data.get("Exec", "").strip()

    if not name or not exec_cmd:
        return None

    icon_name = data.get("Icon", "").strip()

    return {
        "name": name,
        "comment": data.get("Comment", "").strip(),
        "icon": resolve_icon(icon_name),
        "iconName": icon_name,
        "path": str(path),
    }

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
