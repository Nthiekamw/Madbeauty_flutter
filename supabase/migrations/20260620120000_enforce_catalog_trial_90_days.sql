-- Aligner l’essai catalogue sur 3 mois (90 j) partout, y compris si une valeur obsolète (ex. 5 j) était en base.

insert into public.platform_settings (key, value)
values ('catalog_trial', jsonb_build_object('days', 90))
on conflict (key) do update
set
  value = jsonb_build_object('days', 90),
  updated_at = now()
where coalesce((public.platform_settings.value->>'days')::integer, 0) <> 90;

-- Profils encore en essai catalogue court (héritage ~5 j) sans abonnement Stripe.
update public.prestataire_profiles p
set catalog_trial_ends_at = now() + make_interval(days => public.platform_catalog_trial_days())
where coalesce(p.subscription_status, 'none') not in ('active', 'trialing', 'past_due')
  and p.stripe_subscription_id is null
  and p.catalog_trial_ends_at is not null
  and p.catalog_trial_ends_at > now()
  and p.catalog_trial_ends_at < now() + interval '8 days';
