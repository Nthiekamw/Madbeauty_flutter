-- Permet au prestataire de voir l’identité des clientes avec lesquelles il a
-- une réservation ou une conversation (prénom, nom, photo — agenda, clients, chat).

-- ---------------------------------------------------------------------------
-- client_profiles : lire les fiches liées à ses réservations / conversations
-- ---------------------------------------------------------------------------

drop policy if exists "client_profiles_select_presta_booked" on public.client_profiles;

create policy "client_profiles_select_presta_booked"
on public.client_profiles for select
to authenticated
using (
  exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp
      on pp.id = r.prestataire_id
      and pp.user_id = auth.uid()
    where r.client_id = client_profiles.id
  )
  or exists (
    select 1
    from public.conversations conv
    inner join public.prestataire_profiles pp
      on pp.id = conv.prestataire_id
      and pp.user_id = auth.uid()
    where conv.client_id = client_profiles.id
  )
);

-- ---------------------------------------------------------------------------
-- user_profiles : identité (prénom, nom, avatar) des clientes liées
-- ---------------------------------------------------------------------------

drop policy if exists "user_profiles_select_presta_booked_clients" on public.user_profiles;

create policy "user_profiles_select_presta_booked_clients"
on public.user_profiles for select
to authenticated
using (
  exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp
      on pp.id = r.prestataire_id
      and pp.user_id = auth.uid()
    inner join public.client_profiles cp
      on cp.id = r.client_id
      and cp.user_id = user_profiles.user_id
  )
  or exists (
    select 1
    from public.conversations conv
    inner join public.prestataire_profiles pp
      on pp.id = conv.prestataire_id
      and pp.user_id = auth.uid()
    inner join public.client_profiles cp
      on cp.id = conv.client_id
      and cp.user_id = user_profiles.user_id
  )
);
