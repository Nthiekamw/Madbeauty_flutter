-- Verrouillage catalogue + réservations : abonnement actif requis pour la visibilité publique.

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
      and p.subscription_status in ('active', 'trialing')
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
      and p.subscription_status in ('active', 'trialing')
  );
$$;

comment on function public.prestataire_has_active_subscription(uuid) is
  'True si le prestataire a un abonnement actif ou en essai.';
comment on function public.prestataire_is_catalog_visible(uuid) is
  'True si le profil est publiable dans le catalogue client.';

-- Catalogue : lecture publique limitée aux prestataires abonnés.
drop policy if exists "prestataire_profiles_select_anon" on public.prestataire_profiles;
create policy "prestataire_profiles_select_anon"
on public.prestataire_profiles for select to anon
using (public.prestataire_is_catalog_visible(id));

drop policy if exists "prestataire_profiles_select_authenticated" on public.prestataire_profiles;
create policy "prestataire_profiles_select_authenticated"
on public.prestataire_profiles for select to authenticated
using (
  user_id = auth.uid()
  or public.prestataire_is_catalog_visible(id)
);

drop policy if exists "prestataire_specialites_select_anon" on public.prestataire_specialites;
create policy "prestataire_specialites_select_anon"
on public.prestataire_specialites for select to anon
using (public.prestataire_is_catalog_visible(prestataire_id));

drop policy if exists "prestataire_specialites_select_authenticated" on public.prestataire_specialites;
create policy "prestataire_specialites_select_authenticated"
on public.prestataire_specialites for select to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = prestataire_specialites.prestataire_id
      and (
        p.user_id = auth.uid()
        or public.prestataire_is_catalog_visible(p.id)
      )
  )
);

drop policy if exists "services_beaute_select_anon" on public.services_beaute;
create policy "services_beaute_select_anon"
on public.services_beaute for select to anon
using (
  coalesce(is_actif, true)
  and public.prestataire_is_catalog_visible(prestataire_id)
);

drop policy if exists "services_beaute_select_authenticated" on public.services_beaute;
create policy "services_beaute_select_authenticated"
on public.services_beaute for select to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = services_beaute.prestataire_id
      and (
        p.user_id = auth.uid()
        or (
          coalesce(services_beaute.is_actif, true)
          and public.prestataire_is_catalog_visible(p.id)
        )
      )
  )
);

-- Réservation cliente : uniquement vers un prestataire visible catalogue.
drop policy if exists "reservations_insert_client" on public.reservations;
create policy "reservations_insert_client"
on public.reservations for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id
      and c.user_id = auth.uid()
  )
  and public.prestataire_is_catalog_visible(reservations.prestataire_id)
);

-- Prestataire : confirmer / refuser uniquement si abonné actif.
drop policy if exists "photos_realisation_select_anon" on public.photos_realisation;
create policy "photos_realisation_select_anon"
on public.photos_realisation for select to anon
using (public.prestataire_is_catalog_visible(prestataire_id));

drop policy if exists "reservations_update_participant" on public.reservations;
create policy "reservations_update_participant"
on public.reservations for update to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id
      and c.user_id = auth.uid()
  )
  or (
    exists (
      select 1 from public.prestataire_profiles p
      where p.id = reservations.prestataire_id
        and p.user_id = auth.uid()
    )
    and public.prestataire_has_active_subscription(reservations.prestataire_id)
  )
)
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id
      and c.user_id = auth.uid()
  )
  or (
    exists (
      select 1 from public.prestataire_profiles p
      where p.id = reservations.prestataire_id
        and p.user_id = auth.uid()
    )
    and public.prestataire_has_active_subscription(reservations.prestataire_id)
  )
);
