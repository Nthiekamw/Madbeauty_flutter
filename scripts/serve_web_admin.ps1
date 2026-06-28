# Serveur local du back-office admin (web-admin/) sur le port 8080.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

node (Join-Path $root 'scripts\generate_web_admin_config.js')

$port = 8080
if ($args.Count -gt 0) { $port = [int]$args[0] }

Write-Host "Admin MadBeauty : http://localhost:$port/admin/shell.html (ou index.html)"
Write-Host "Ctrl+C pour arrêter."

npx --yes http-server@14.1.1 (Join-Path $root 'web-admin') -p $port -c-1
