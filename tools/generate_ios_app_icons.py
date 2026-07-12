"""Régénère les icônes iOS (AppIcon.appiconset) depuis web/icons/Icon-512.png."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "web" / "icons" / "Icon-512.png"
APP_ICON_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS = APP_ICON_DIR / "Contents.json"


def pixel_size(entry: dict) -> int:
    base = float(entry["size"].split("x")[0])
    scale = int(str(entry.get("scale", "1x")).replace("x", ""))
    if base == 83.5:
        return round(base * scale)
    return int(base * scale)


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"Source introuvable: {SOURCE}")

    with CONTENTS.open(encoding="utf-8") as handle:
        manifest = json.load(handle)

    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (512, 512):
        source = source.resize((512, 512), Image.Resampling.LANCZOS)

    for entry in manifest["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        size = pixel_size(entry)
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        target = APP_ICON_DIR / filename
        resized.save(target, format="PNG", optimize=True)
        print(f"Wrote {target.name} ({size}x{size})")

    print(f"Done — source: {SOURCE}")


if __name__ == "__main__":
    main()
