# Déploiement local du back-office admin sur Netlify (même logique que le pipeline CI).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

node (Join-Path $root 'scripts\generate_web_admin_config.js')
npx netlify-cli deploy --prod
