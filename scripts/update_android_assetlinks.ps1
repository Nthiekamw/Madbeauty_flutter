# Met à jour web/well-known/assetlinks.json pour Android App Links.
# Empreinte : Play Console → Intégrité de l'appli → Signature d'appli → SHA-256.
param(
  [Parameter(Mandatory = $true)]
  [string[]]$Sha256
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root 'web\well-known'
$outFile = Join-Path $outDir 'assetlinks.json'

function Normalize-Sha256([string]$value) {
  $clean = ($value -replace '\s', '').ToUpperInvariant()
  if ($clean -notmatch '^[0-9A-F:]{32,}$' -and $clean -notmatch '^[0-9A-F]{64}$') {
    throw "Empreinte SHA-256 invalide: $value"
  }
  if ($clean -notmatch ':') {
    # AA BB… → AA:BB:…
    $clean = (($clean -replace '..', '$0:').TrimEnd(':'))
  }
  return $clean
}

$fps = @($Sha256 | ForEach-Object { Normalize-Sha256 $_ } | Select-Object -Unique)
if ($fps.Count -eq 0) {
  throw 'Au moins une empreinte SHA-256 est requise.'
}

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$fpsJson = ($fps | ForEach-Object { '        "{0}"' -f $_ }) -join ",`n"
$json = @"
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.madbeauty.madbeauty",
      "sha256_cert_fingerprints": [
$fpsJson
      ]
    }
  }
]
"@

Set-Content -Path $outFile -Value $json.TrimEnd() -Encoding utf8NoBOM
Write-Host "OK: $outFile"
Write-Host "Empreintes:"
$fps | ForEach-Object { Write-Host "  - $_" }
Write-Host ""
Write-Host "Ensuite: déployer l'app web (scripts/deploy_app_netlify.ps1)"
Write-Host "puis vérifier https://madbeauty.pro/.well-known/assetlinks.json"
