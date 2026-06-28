# Build + déploiement prod de l'app Flutter Web sur Netlify.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Build prod : URL OAuth web = site Netlify (pas localhost du .env dev).
$prodWebRedirect = 'https://madbeauty-app.netlify.app'
if (-not $env:SUPABASE_WEB_REDIRECT_URL -or $env:SUPABASE_WEB_REDIRECT_URL -match 'localhost|127\.0\.0\.1') {
  $env:SUPABASE_WEB_REDIRECT_URL = $prodWebRedirect
  Write-Host "SUPABASE_WEB_REDIRECT_URL -> $prodWebRedirect (deploy prod)"
}

& (Join-Path $root 'scripts\build_flutter_web_ci.ps1')

$siteId = $env:NETLIFY_APP_SITE_ID
if (-not $siteId) {
  $envPath = Join-Path $root '.env'
  if (Test-Path $envPath) {
    foreach ($line in Get-Content $envPath) {
      if ($line -match '^\s*NETLIFY_APP_SITE_ID\s*=\s*(.+)\s*$') {
        $siteId = $Matches[1].Trim().Trim('"').Trim("'")
        break
      }
    }
  }
}
if (-not $siteId) {
  throw 'NETLIFY_APP_SITE_ID manquant (variable d''environnement ou .env).'
}

npx --yes netlify-cli@26.1.0 deploy --prod `
  --dir=build/web `
  --site=$siteId `
  --no-build
