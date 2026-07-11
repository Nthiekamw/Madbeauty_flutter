-- Catalogue + carte : visibilité uniquement si profil professionnellement complet.

create or replace function public.prestataire_is_professionally_complete(p_prestataire_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.prestataire_profiles p
    join public.user_profiles up on up.user_id = p.user_id
    where p.id = p_prestataire_id
      and coalesce(trim(p.nom_salon), '') <> ''
      and coalesce(trim(p.ville), '') <> ''
      and coalesce(trim(p.adresse), '') <> ''
      and coalesce(trim(p.code_postal), '') <> ''
      and p.lieu_travail is not null
      and coalesce(trim(p.description), '') <> ''
      and coalesce(trim(up.avatar_url), '') <> ''
      and exists (
        select 1
        from public.prestataire_specialites ps
        where ps.prestataire_id = p.id
      )
      and exists (
        select 1
        from public.services_beaute s
        where s.prestataire_id = p.id
          and coalesce(s.is_actif, true) = true
          and coalesce(trim(s.nom), '') <> ''
          and s.categorie_id is not null
          and coalesce(s.prix, 0) >= 1
          and coalesce(s.duree_minutes, 0) > 0
      )
  );
$$;

comment on function public.prestataire_is_professionally_complete(uuid) is
  'True si le profil prestataire remplit les critères catalogue (vitrine, adresse, services valides, avatar).';

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
    join public.user_profiles up on up.user_id = p.user_id
    where p.id = p_prestataire_id
      and coalesce(p.is_hidden, false) = false
      and coalesce(up.is_banned, false) = false
      and public.prestataire_is_professionally_complete(p.id)
      and (
        p.subscription_status in ('active', 'trialing')
        or (
          p.catalog_trial_ends_at is not null
          and p.catalog_trial_ends_at > now()
        )
      )
  );
$$;

comment on function public.prestataire_is_catalog_visible(uuid) is
  'True si le profil est publiable (complet, non banni, abonnement ou essai catalogue).';

create or replace function public.prestataire_is_map_visible(p_prestataire_id uuid)
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
      and public.prestataire_is_catalog_visible(p.id)
      and p.latitude is not null
      and p.longitude is not null
  );
$$;

comment on function public.prestataire_is_map_visible(uuid) is
  'True si le prestataire est visible catalogue avec coordonnées (pin carte).';

grant execute on function public.prestataire_is_professionally_complete(uuid) to anon, authenticated;
grant execute on function public.prestataire_is_map_visible(uuid) to anon, authenticated;
