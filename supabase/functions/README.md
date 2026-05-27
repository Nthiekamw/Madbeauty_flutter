# Edge Functions MadBeauty — notifications push (FCM)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_booking_created` | `INSERT reservations` | prestataire |
| `on_booking_updated` | `UPDATE reservations` | cliente (statut) |
| `on_message_created` | `INSERT messages` | autre participant du booking |

Partagé : `supabase/functions/_shared/booking_notify.ts`

## Déploiement

```bash
npx supabase functions deploy on_booking_created --no-verify-jwt
npx supabase functions deploy on_booking_updated --no-verify-jwt
npx supabase functions deploy on_message_created --no-verify-jwt
```

## Dépendances locales (test)

Pour valider avant déploiement :

```bash
npx supabase functions serve
```

## Documentation projet

Voir à la racine du dépôt Flutter : **`docs/BOOKING_PUSH_NOTIFICATIONS.md`**.
