"""Rend le fond noir du logo transparent (splash / fond sombre)."""
from pathlib import Path

from PIL import Image

LOGO = Path(__file__).resolve().parents[1] / "assets" / "images" / "logo.png"
# Pixels très sombres → transparent (fond noir du fichier source).
LUMINANCE_THRESHOLD = 42


def main() -> None:
    img = Image.open(LOGO).convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if max(r, g, b) <= LUMINANCE_THRESHOLD:
                pixels[x, y] = (r, g, b, 0)
    img.save(LOGO, format="PNG", optimize=True)
    print(f"Updated {LOGO} ({w}x{h})")


if __name__ == "__main__":
    main()
