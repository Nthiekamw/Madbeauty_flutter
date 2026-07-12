# Déploiement local du back-office admin sur Netlify (même logique que le pipeline CI).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

node (Join-Path $root 'scripts\generate_web_admin_config.js')

if (-not $env:NETLIFY_SITE_ID) {
  $env:NETLIFY_SITE_ID = '8a6bc2a3-80df-46de-a1be-0c15efcc8551'
}

npx --yes netlify-cli@26.1.0 deploy --prod --dir=web-admin --no-build
