"""Régénère les icônes iOS (AppIcon.appiconset) depuis web/icons/Icon-512.png.

App Store exige une icône marketing 1024×1024 **sans transparence**
(ni canal alpha) — voir HIG App Icons.
"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "web" / "icons" / "Icon-512.png"
APP_ICON_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS = APP_ICON_DIR / "Contents.json"

# Fond opaque MadBeauty (aligné coins logo / brandLogoBackground).
OPAQUE_BG = (13, 13, 13)


def pixel_size(entry: dict) -> int:
    base = float(entry["size"].split("x")[0])
    scale = int(str(entry.get("scale", "1x")).replace("x", ""))
    if base == 83.5:
        return round(base * scale)
    return int(base * scale)


def flatten_opaque(image: Image.Image, background: tuple[int, int, int]) -> Image.Image:
    """Compose sur fond opaque et retire le canal alpha (RGB uniquement)."""
    rgba = image.convert("RGBA")
    canvas = Image.new("RGB", rgba.size, background)
    canvas.paste(rgba, mask=rgba.split()[3])
    return canvas


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"Source introuvable: {SOURCE}")

    with CONTENTS.open(encoding="utf-8") as handle:
        manifest = json.load(handle)

    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (512, 512):
        source = source.resize((512, 512), Image.Resampling.LANCZOS)

    # Déduit un fond depuis le coin (souvent déjà opaque) si opaque.
    corner = source.getpixel((0, 0))
    bg = (corner[0], corner[1], corner[2]) if corner[3] == 255 else OPAQUE_BG

    for entry in manifest["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        size = pixel_size(entry)
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        opaque = flatten_opaque(resized, bg)
        target = APP_ICON_DIR / filename
        opaque.save(target, format="PNG", optimize=True)
        print(f"Wrote {target.name} ({size}x{size}, RGB)")

    print(f"Done — source: {SOURCE} bg={bg}")


if __name__ == "__main__":
    main()
