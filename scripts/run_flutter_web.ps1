# Lance l'app MadBeauty dans Chrome (Flutter Web) avec les variables .env.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$envFile = Join-Path $root '.env'
if (Test-Path $envFile) {
  flutter run -d chrome --web-port=7357 --dart-define-from-file=$envFile @args
} else {
  Write-Warning '.env introuvable — lancement sans dart-define-from-file.'
  flutter run -d chrome @args
}
