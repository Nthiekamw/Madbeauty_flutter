# Déploie les Edge Functions push + secrets + config pg_net (remplace les webhooks dashboard).
# Usage (depuis la racine du repo) :
#   .\supabase\setup_push_notifications.ps1
# Optionnel : placer le JSON compte de service Firebase dans
#   supabase\firebase-service-account.json

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $RepoRoot

function Read-DotEnvValue([string]$Key) {
    $envFile = Join-Path $RepoRoot ".env"
    if (-not (Test-Path $envFile)) { return $null }
    foreach ($line in Get-Content $envFile) {
        if ($line -match "^\s*$Key\s*=\s*(.+)\s*$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

$supabaseUrl = Read-DotEnvValue "SUPABASE_URL"
if ([string]::IsNullOrWhiteSpace($supabaseUrl)) {
    Write-Error "SUPABASE_URL manquant dans .env"
}
$functionsBase = ($supabaseUrl.TrimEnd('/')) + "/functions/v1"

# Secret partagé triggers SQL ↔ Edge Functions
$webhookSecret = [guid]::NewGuid().ToString("N") + [guid]::NewGuid().ToString("N")

Write-Host "==> Migration base (triggers pg_net)..."
npx supabase db push --yes

Write-Host "==> Configuration private.webhook_config..."
$configSql = @"
insert into private.webhook_config (key, value, updated_at)
values
  ('functions_base', '$functionsBase', now()),
  ('booking_webhook_secret', '$webhookSecret', now())
on conflict (key) do update
  set value = excluded.value,
      updated_at = excluded.updated_at;
"@
$configFile = Join-Path $env:TEMP "madbeauty_webhook_config.sql"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($configFile, $configSql, $utf8NoBom)
npx supabase db query --linked -f $configFile
Remove-Item $configFile -Force

Write-Host "==> Secrets Supabase (BOOKING_WEBHOOK_SECRET + Firebase)..."
$secretsEnvFile = Join-Path $env:TEMP "madbeauty_supabase_secrets.env"
$secretLines = @("BOOKING_WEBHOOK_SECRET=$webhookSecret")

$firebaseJsonPath = Join-Path $PSScriptRoot "firebase-service-account.json"
if (Test-Path $firebaseJsonPath) {
    Write-Host "    + FIREBASE_SERVICE_ACCOUNT_JSON (fichier local)"
    $jsonObj = Get-Content $firebaseJsonPath -Raw | ConvertFrom-Json
    $compressed = ($jsonObj | ConvertTo-Json -Compress -Depth 10)
    $escaped = $compressed -replace "'", "''"
    $secretLines += "FIREBASE_SERVICE_ACCOUNT_JSON='$escaped'"
} else {
    Write-Warning @"
Fichier supabase\firebase-service-account.json introuvable.
Télécharge-le depuis Firebase Console → Paramètres projet → Comptes de service → Générer une clé,
puis relance ce script.
"@
}

$utf8NoBomSecrets = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($secretsEnvFile, ($secretLines -join "`n"), $utf8NoBomSecrets)
npx supabase secrets set --env-file $secretsEnvFile
Remove-Item $secretsEnvFile -Force

Write-Host "==> Déploiement Edge Functions..."
$functions = @(
    "on_booking_created",
    "on_booking_updated",
    "on_message_created"
)
foreach ($fn in $functions) {
    npx supabase functions deploy $fn --no-verify-jwt
}

Write-Host ""
Write-Host "Terminé. Les triggers SQL remplacent les Database Webhooks du dashboard."
Write-Host "Vérifie user_profiles.fcm_token après connexion à l'app, puis teste une réservation."
