-- Lecture des profils identité des prestataires par tout utilisateur connecté
-- (avatar / nom pour le catalogue client — sans ouvrir toute la table user_profiles).

drop policy if exists "user_profiles_select_linked_prestataire" on public.user_profiles;

create policy "user_profiles_select_linked_prestataire"
on public.user_profiles for select
to authenticated
using (
  exists (
    select 1
    from public.prestataire_profiles pp
    where pp.user_id = user_profiles.user_id
  )
);
