# Déploiement local du back-office admin sur Netlify (même logique que le pipeline CI).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

node (Join-Path $root 'scripts\generate_web_admin_config.js')
npx --yes netlify-cli@26.1.0 deploy --prod --config=netlify.toml
