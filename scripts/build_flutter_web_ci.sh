#!/usr/bin/env bash
# Build release Flutter Web pour Netlify (variables d'environnement requises).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

: "${SUPABASE_URL:?SUPABASE_URL manquant}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY manquant}"

ENV_BUILD="$ROOT/.env.build"
{
  printf 'SUPABASE_URL=%s\n' "$SUPABASE_URL"
  printf 'SUPABASE_ANON_KEY=%s\n' "$SUPABASE_ANON_KEY"
  if [ -n "${STRIPE_PUBLISHABLE_KEY:-}" ]; then
    printf 'STRIPE_PUBLISHABLE_KEY=%s\n' "$STRIPE_PUBLISHABLE_KEY"
  fi
  if [ -n "${SUPABASE_WEB_REDIRECT_URL:-}" ]; then
    printf 'SUPABASE_WEB_REDIRECT_URL=%s\n' "$SUPABASE_WEB_REDIRECT_URL"
  fi
  if [ -n "${SUPABASE_EMAIL_REDIRECT_URL:-}" ]; then
    printf 'SUPABASE_EMAIL_REDIRECT_URL=%s\n' "$SUPABASE_EMAIL_REDIRECT_URL"
  fi
  if [ -n "${SHARE_BASE_URL:-}" ]; then
    printf 'SHARE_BASE_URL=%s\n' "$SHARE_BASE_URL"
  fi
} >"$ENV_BUILD"

cleanup() {
  rm -f "$ENV_BUILD"
}
trap cleanup EXIT

flutter pub get
flutter build web --release --dart-define-from-file="$ENV_BUILD"

echo "OK: build/web prêt pour Netlify."
