# Build release Flutter Web (lit .env ou variables d'environnement).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$envFile = Join-Path $root '.env'
$buildFile = Join-Path $root '.env.build'

function Import-DotEnv([string]$path) {
  $vars = @{}
  if (-not (Test-Path $path)) { return $vars }
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#') -or -not $line.Contains('=')) { return }
    $idx = $line.IndexOf('=')
    $key = $line.Substring(0, $idx).Trim()
    $val = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
    $vars[$key] = $val
  }
  return $vars
}

$fromFile = Import-DotEnv $envFile
$url = $env:SUPABASE_URL; if (-not $url) { $url = $fromFile['SUPABASE_URL'] }
$key = $env:SUPABASE_ANON_KEY; if (-not $key) { $key = $fromFile['SUPABASE_ANON_KEY'] }
if (-not $url -or -not $key) {
  throw 'SUPABASE_URL et SUPABASE_ANON_KEY requis (.env ou variables d''environnement).'
}

$lines = @(
  "SUPABASE_URL=$url",
  "SUPABASE_ANON_KEY=$key"
)
foreach ($name in @(
    'STRIPE_PUBLISHABLE_KEY',
    'SUPABASE_WEB_REDIRECT_URL',
    'SUPABASE_EMAIL_REDIRECT_URL',
    'SHARE_BASE_URL'
  )) {
  $val = (Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value
  if (-not $val) { $val = $fromFile[$name] }
  if ($val) { $lines += "$name=$val" }
}
Set-Content -Path $buildFile -Value $lines -Encoding utf8

try {
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw 'flutter pub get a échoué.' }

  flutter build web --release --dart-define-from-file=$buildFile
  if ($LASTEXITCODE -ne 0) { throw 'flutter build web a échoué.' }

  Write-Host 'OK: build/web prêt pour Netlify.'
} finally {
  if (Test-Path $buildFile) { Remove-Item $buildFile -Force }
}
