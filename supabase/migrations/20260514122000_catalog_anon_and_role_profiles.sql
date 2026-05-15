-- Lecture publique du catalogue + création automatique des profils métier.
-- Les données privées (réservations, favoris, conversations, messages) restent
-- réservées aux participants authentifiés.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_profiles (user_id, nom, prenom, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', null),
    null,
    now()
  )
  on conflict (user_id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, 'client')
  on conflict (user_id, role) do nothing;

  insert into public.client_profiles (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create or replace function public.ensure_profile_for_user_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role = 'client' then
    insert into public.client_profiles (user_id)
    values (new.user_id)
    on conflict (user_id) do nothing;
  elsif new.role = 'prestataire' then
    insert into public.prestataire_profiles (user_id)
    values (new.user_id)
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_user_roles_ensure_profile on public.user_roles;

create trigger trg_user_roles_ensure_profile
after insert on public.user_roles
for each row
execute procedure public.ensure_profile_for_user_role();

insert into public.client_profiles (user_id)
select user_id
from public.user_roles
where role = 'client'
on conflict (user_id) do nothing;

insert into public.prestataire_profiles (user_id)
select user_id
from public.user_roles
where role = 'prestataire'
on conflict (user_id) do nothing;

-- Catalogue public (anon) : lecture uniquement des données nécessaires à la
-- découverte avant connexion. Les écritures restent couvertes par les policies
-- authenticated existantes.

drop policy if exists "user_profiles_select_linked_prestataire_anon"
on public.user_profiles;
drop policy if exists "prestataire_profiles_select_anon"
on public.prestataire_profiles;
drop policy if exists "categories_service_select_anon"
on public.categories_service;
drop policy if exists "prestataire_specialites_select_anon"
on public.prestataire_specialites;
drop policy if exists "services_beaute_select_anon"
on public.services_beaute;
drop policy if exists "avis_select_anon"
on public.avis;
drop policy if exists "photos_realisation_select_anon"
on public.photos_realisation;

create policy "user_profiles_select_linked_prestataire_anon"
on public.user_profiles for select
to anon
using (
  exists (
    select 1
    from public.prestataire_profiles pp
    where pp.user_id = user_profiles.user_id
  )
);

create policy "prestataire_profiles_select_anon"
on public.prestataire_profiles for select
to anon
using (true);

create policy "categories_service_select_anon"
on public.categories_service for select
to anon
using (true);

create policy "prestataire_specialites_select_anon"
on public.prestataire_specialites for select
to anon
using (true);

create policy "services_beaute_select_anon"
on public.services_beaute for select
to anon
using (true);

create policy "avis_select_anon"
on public.avis for select
to anon
using (true);

create policy "photos_realisation_select_anon"
on public.photos_realisation for select
to anon
using (true);
