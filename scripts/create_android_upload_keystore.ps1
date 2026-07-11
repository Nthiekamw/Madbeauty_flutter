# Crée le keystore Play Store (release) + android/key.properties (gitignored).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $root 'android'
$appDir = Join-Path $androidDir 'app'
$keystorePath = Join-Path $appDir 'upload-keystore.jks'
$keyPropsPath = Join-Path $androidDir 'key.properties'

if (Test-Path $keystorePath) {
  Write-Host "Keystore déjà présent: $keystorePath"
  if (-not (Test-Path $keyPropsPath)) {
    throw "key.properties manquant alors que le keystore existe. Recréez-le ou restaurez une sauvegarde."
  }
  exit 0
}

$keytoolCmd = Get-Command keytool -ErrorAction SilentlyContinue
$keytoolPath = if ($keytoolCmd) { $keytoolCmd.Source } else { $null }
if (-not $keytoolPath) {
  $candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Android\Sdk\jbr\bin\keytool.exe'),
    (Join-Path $env:ProgramFiles 'Android\Android Studio\jbr\bin\keytool.exe')
  )
  if ($env:JAVA_HOME) {
    $candidates += (Join-Path $env:JAVA_HOME 'bin\keytool.exe')
  }
  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      $keytoolPath = $candidate
      break
    }
  }
}
if (-not $keytoolPath) {
  throw 'keytool introuvable. Installez le JDK ou Android Studio.'
}

# Mot de passe généré localement — sauvegardez-le (gestionnaire de mots de passe).
$password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })

$dname = 'CN=MadBeauty, OU=Mobile, O=MadBeauty, L=Paris, ST=IDF, C=FR'
& $keytoolPath -genkeypair -v `
  -keystore $keystorePath `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload `
  -storepass $password `
  -keypass $password `
  -dname $dname

$keyProps = @(
  "storePassword=$password",
  "keyPassword=$password",
  'keyAlias=upload',
  'storeFile=upload-keystore.jks'
)
Set-Content -Path $keyPropsPath -Value $keyProps -Encoding Ascii

Write-Host ''
Write-Host 'OK: keystore release créé.'
Write-Host "  Keystore : $keystorePath"
Write-Host "  Config   : $keyPropsPath"
Write-Host ''
Write-Host 'IMPORTANT — sauvegardez ces fichiers + le mot de passe (perte = impossible de mettre à jour l''app sur le Play Store).'
Write-Host "Mot de passe (copiez-le maintenant): $password"
