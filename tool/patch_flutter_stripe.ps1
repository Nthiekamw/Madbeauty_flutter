# Correctif flutter_stripe 12.6.0 (pub.dev) : @internal sans import meta.
# À lancer après `flutter pub get` si la build échoue sur « Undefined name internal ».
$ErrorActionPreference = 'Stop'
$cacheRoot = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
$targets = Get-ChildItem -Path $cacheRoot -Filter 'stripe.dart' -Recurse -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -match 'flutter_stripe-12\.[46]\.0\\lib\\src\\stripe\.dart$' }

if (-not $targets) {
  Write-Host 'Aucun flutter_stripe 12.4/12.6 trouvé dans le cache Pub.'
  exit 1
}

$old = @"
import 'package:flutter/foundation.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
"@

$new = @"
import 'package:flutter/foundation.dart' hide internal;
import 'package:meta/meta.dart';
import 'package:stripe_platform_interface/stripe_platform_interface.dart';
"@

foreach ($file in $targets) {
  $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
  if ($content -match 'package:meta/meta\.dart') {
    Write-Host "Déjà corrigé : $($file.FullName)"
    continue
  }
  if (-not $content.Contains($old.Trim())) {
    Write-Host "Format inattendu, ignoré : $($file.FullName)"
    continue
  }
  $content = $content.Replace($old, $new)
  Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Corrigé : $($file.FullName)"
}

Write-Host 'Terminé. Relancez : flutter run --dart-define-from-file=.env'
