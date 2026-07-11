# Régénère favicon + icônes PWA web depuis assets/images/logo.png
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

python -c @"
from PIL import Image, ImageDraw
from pathlib import Path

root = Path(r'$root')
raw = Image.open(root / 'assets/images/logo.png').convert('RGBA')

BRAND_BG = (44, 24, 16, 255)

def crop_to_content(img: Image.Image) -> Image.Image:
    px = img.load()
    w, h = img.size
    min_x, min_y, max_x, max_y = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            if max(r, g, b) > 45:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x <= min_x or max_y <= min_y:
        return img
    pad = max(2, int(min(w, h) * 0.01))
    return img.crop((
        max(0, min_x - pad),
        max(0, min_y - pad),
        min(w, max_x + pad),
        min(h, max_y + pad),
    ))

src = crop_to_content(raw)

def make_icon(size: int, *, fill_ratio: float, rounded: bool = False) -> Image.Image:
    canvas = Image.new('RGBA', (size, size), BRAND_BG)
    inner = int(size * fill_ratio)
    w, h = src.size
    scale = min(inner / w, inner / h)
    nw, nh = int(w * scale), int(h * scale)
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (size - nw) // 2
    y = (size - nh) // 2
    canvas.paste(resized, (x, y), resized)
    if rounded:
        mask = Image.new('L', (size, size), 0)
        draw = ImageDraw.Draw(mask)
        radius = int(size * 0.22)
        draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
        rounded_canvas = Image.new('RGBA', (size, size), BRAND_BG)
        rounded_canvas.paste(canvas, (0, 0), mask)
        return rounded_canvas
    return canvas

outputs = {
    root / 'web/favicon.png': (64, 0.94, False),
    root / 'web/icons/Icon-192.png': (192, 0.92, False),
    root / 'web/icons/Icon-512.png': (512, 0.92, False),
    root / 'web/icons/Icon-maskable-192.png': (192, 0.80, False),
    root / 'web/icons/Icon-maskable-512.png': (512, 0.80, False),
    root / 'web/icons/apple-touch-icon.png': (180, 0.92, True),
    root / 'web/icons/Icon-notification-192.png': (192, 0.90, False),
    root / 'web/icons/Icon-badge-72.png': (72, 0.88, False),
    root / 'web/images/logo.png': (512, 0.92, False),
}

for path, (size, fill_ratio, rounded) in outputs.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    make_icon(size, fill_ratio=fill_ratio, rounded=rounded).save(
        path, format='PNG', optimize=True
    )
    print('OK', path.name)
"@

Write-Host 'OK: icônes web MadBeauty synchronisées.'
