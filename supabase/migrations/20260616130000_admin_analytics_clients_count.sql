-- Analytics admin : compteur de clients.

create or replace function public.admin_get_analytics_summary()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'users_total', (select count(*)::int from public.user_profiles),
    'users_banned', (
      select count(*)::int from public.user_profiles where is_banned = true
    ),
    'clients_total', (select count(*)::int from public.client_profiles),
    'prestataires_total', (select count(*)::int from public.prestataire_profiles),
    'prestataires_verified', (
      select count(*)::int from public.prestataire_profiles where is_verified = true
    ),
    'verification_pending', (
      select count(*)::int
      from public.prestataire_profiles
      where is_verified = false
        and verification_requested_at is not null
    ),
    'reports_pending', (
      select count(*)::int
      from public.content_reports
      where reviewed_at is null
    ),
    'bugs_pending', (
      select count(*)::int
      from public.bug_reports
      where status in ('pending', 'in_progress')
    ),
    'reservations_total', (select count(*)::int from public.reservations),
    'reservations_this_month', (
      select count(*)::int
      from public.reservations
      where date_heure >= date_trunc('month', now())
    ),
    'revenue_captured_cents', (
      select coalesce(sum(amount_cents), 0)::bigint
      from public.reservations
      where payment_status = 'captured'
    ),
    'revenue_this_month_cents', (
      select coalesce(sum(amount_cents), 0)::bigint
      from public.reservations
      where payment_status = 'captured'
        and paid_at >= date_trunc('month', now())
    )
  )
  where public.is_admin_user(auth.uid());
$$;
