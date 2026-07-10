# Déploiement local du site vitrine (website/) sur Netlify — même logique que le pipeline CI.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$siteId = $env:NETLIFY_WEBSITE_SITE_ID
if (-not $siteId) {
  $envPath = Join-Path $root '.env'
  if (Test-Path $envPath) {
    foreach ($line in Get-Content $envPath) {
      if ($line -match '^\s*NETLIFY_WEBSITE_SITE_ID\s*=\s*(.+)\s*$') {
        $siteId = $Matches[1].Trim().Trim('"').Trim("'")
        break
      }
    }
  }
}
if (-not $siteId) {
  throw 'NETLIFY_WEBSITE_SITE_ID manquant (variable d''environnement ou .env).'
}

$env:NETLIFY_SITE_ID = $siteId
npx --yes netlify-cli@26.1.0 deploy --prod --config=website/netlify.toml
