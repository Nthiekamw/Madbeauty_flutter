# Synchronise les prix d'abonnement MadBeauty vers Stripe (+ secrets Supabase).
# Usage :
#   $env:STRIPE_SECRET_KEY = "sk_test_..."
#   .\scripts\stripe_sync_subscription_prices.ps1
#   .\scripts\stripe_sync_subscription_prices.ps1 -ApplySecrets
#   .\scripts\stripe_sync_subscription_prices.ps1 -ApplySecrets -ArchiveOld
#   .\scripts\stripe_sync_subscription_prices.ps1 -MigrateSubscribers -Yes   # prudent
#   .\scripts\stripe_sync_subscription_prices.ps1 -DryRun

param(
  [switch]$ApplySecrets,
  [switch]$ArchiveOld,
  [switch]$MigrateSubscribers,
  [switch]$Yes,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not $env:STRIPE_SECRET_KEY) {
  Write-Host "STRIPE_SECRET_KEY non défini." -ForegroundColor Yellow
  $secure = Read-Host "Colle ta clé secrète Stripe (sk_test_… / sk_live_…)" -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try {
    $env:STRIPE_SECRET_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

$nodeArgs = @('scripts/stripe_sync_subscription_prices.mjs')
if ($ApplySecrets) { $nodeArgs += '--apply-secrets' }
if ($ArchiveOld) { $nodeArgs += '--archive-old' }
if ($MigrateSubscribers) { $nodeArgs += '--migrate-subscribers' }
if ($Yes) { $nodeArgs += '--yes' }
if ($DryRun) { $nodeArgs += '--dry-run' }

node @nodeArgs
