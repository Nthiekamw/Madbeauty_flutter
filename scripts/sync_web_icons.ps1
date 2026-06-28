# Régénère favicon + icônes PWA web depuis assets/images/logo.png
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

python -c @"
from PIL import Image
from pathlib import Path

root = Path(r'$root')
src = Image.open(root / 'assets/images/logo.png').convert('RGBA')

def make_icon(size: int, maskable: bool = False) -> Image.Image:
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    inner = int(size * 0.82) if maskable else int(size * 0.98)
    w, h = src.size
    scale = min(inner / w, inner / h)
    nw, nh = int(w * scale), int(h * scale)
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (size - nw) // 2
    y = (size - nh) // 2
    canvas.paste(resized, (x, y), resized)
    return canvas

outputs = {
    root / 'web/favicon.png': (64, False),
    root / 'web/icons/Icon-192.png': (192, False),
    root / 'web/icons/Icon-512.png': (512, False),
    root / 'web/icons/Icon-maskable-192.png': (192, True),
    root / 'web/icons/Icon-maskable-512.png': (512, True),
    root / 'web/images/logo.png': (512, False),
}

for path, (size, maskable) in outputs.items():
    path.parent.mkdir(parents=True, exist_ok=True)
    make_icon(size, maskable).save(path, format='PNG', optimize=True)
    print('OK', path.name)
"@

Write-Host 'OK: icônes web MadBeauty synchronisées.'
