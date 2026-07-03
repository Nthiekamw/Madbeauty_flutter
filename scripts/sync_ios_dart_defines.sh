#!/usr/bin/env bash
# Injecte les variables .env dans ios/Flutter/Generated.xcconfig (DART_DEFINES)
# pour que Xcode / Archive utilisent la même config que `flutter run`.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Fichier .env introuvable. Copiez .env.example vers .env puis éditez les valeurs." >&2
  exit 1
fi

flutter build ios --config-only --dart-define-from-file=.env
echo "OK — DART_DEFINES synchronisés dans ios/Flutter/Generated.xcconfig"
