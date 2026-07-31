# process_scheduled_pushes

Traite la file `scheduled_pushes` (aftercare J+1, rappels rebook 4/6 semaines).

## Déploiement

```bash
npx supabase functions deploy process_scheduled_pushes --no-verify-jwt
```

JWT désactivé : appel depuis **pg_cron** (via `private.notify_edge_function` / pg_net), pas depuis les clients.

## Cron (versionné)

Migration `20260731130000_process_scheduled_pushes_cron.sql` :

- extension `pg_cron`
- job `process-scheduled-pushes` toutes les **15 minutes**
- appel `private.invoke_process_scheduled_pushes()` → `POST {functions_base}/process_scheduled_pushes`

Prérequis : `private.webhook_config.functions_base` renseigné (script `supabase/setup_push_notifications.ps1`).

Vérifier le job :

```sql
select jobid, jobname, schedule, active from cron.job
where jobname = 'process-scheduled-pushes';
```

Secrets requis : mêmes que les autres push (`FIREBASE_SERVICE_ACCOUNT_JSON`, etc.).
