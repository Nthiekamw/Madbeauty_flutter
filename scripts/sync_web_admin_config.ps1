# Génère web/admin/config.js depuis .env (SUPABASE_URL, SUPABASE_ANON_KEY).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
node (Join-Path $root 'scripts\generate_web_admin_config.js')
