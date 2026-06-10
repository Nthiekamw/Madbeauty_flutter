-- Essai catalogue prestataire : 5 jours de visibilité sans abonnement payant.

alter table public.prestataire_profiles
  add column if not exists catalog_trial_ends_at timestamptz;

comment on column public.prestataire_profiles.catalog_trial_ends_at is
  'Fin de l’essai gratuit catalogue (5 jours à la création du profil prestataire).';

create or replace function public.prestataire_is_in_catalog_trial(p_prestataire_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.prestataire_profiles p
    where p.id = p_prestataire_id
      and p.catalog_trial_ends_at is not null
      and p.catalog_trial_ends_at > now()
  );
$$;

create or replace function public.prestataire_has_active_subscription(p_prestataire_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.prestataire_profiles p
    where p.id = p_prestataire_id
      and (
        p.subscription_status in ('active', 'trialing')
        or (
          p.catalog_trial_ends_at is not null
          and p.catalog_trial_ends_at > now()
        )
      )
  );
$$;

create or replace function public.prestataire_is_catalog_visible(p_prestataire_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.prestataire_profiles p
    where p.id = p_prestataire_id
      and coalesce(p.is_hidden, false) = false
      and (
        p.subscription_status in ('active', 'trialing')
        or (
          p.catalog_trial_ends_at is not null
          and p.catalog_trial_ends_at > now()
        )
      )
  );
$$;

comment on function public.prestataire_is_in_catalog_trial(uuid) is
  'True pendant les 5 jours d’essai catalogue (sans abonnement Stripe).';

create or replace function public.prestataire_profiles_set_catalog_trial()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.catalog_trial_ends_at is null then
    new.catalog_trial_ends_at := now() + interval '5 days';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_prestataire_profiles_catalog_trial
  on public.prestataire_profiles;

create trigger trg_prestataire_profiles_catalog_trial
before insert on public.prestataire_profiles
for each row
execute function public.prestataire_profiles_set_catalog_trial();

-- Prestataires existants jamais abonnés : essai à partir de la migration.
update public.prestataire_profiles
set catalog_trial_ends_at = now() + interval '5 days'
where catalog_trial_ends_at is null
  and coalesce(subscription_status, 'none') = 'none'
  and stripe_subscription_id is null;
