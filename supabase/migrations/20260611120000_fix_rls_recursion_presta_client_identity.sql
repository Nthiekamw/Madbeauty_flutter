-- Corrige la récursion RLS 42P17 introduite par client_profiles_select_presta_booked :
-- la politique lisait reservations, dont la politique relit client_profiles → boucle infinie.
-- Les helpers SECURITY DEFINER contournent RLS pour les jointures de vérification.

create or replace function public.prestataire_has_booking_with_client(p_client_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp
      on pp.id = r.prestataire_id
      and pp.user_id = auth.uid()
    where r.client_id = p_client_id
  );
$$;

create or replace function public.prestataire_has_conversation_with_client(p_client_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.conversations conv
    inner join public.prestataire_profiles pp
      on pp.id = conv.prestataire_id
      and pp.user_id = auth.uid()
    where conv.client_id = p_client_id
  );
$$;

create or replace function public.prestataire_can_read_client_profile(p_client_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    public.prestataire_has_booking_with_client(p_client_id)
    or public.prestataire_has_conversation_with_client(p_client_id);
$$;

create or replace function public.prestataire_can_read_client_user(p_target_user_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp
      on pp.id = r.prestataire_id
      and pp.user_id = auth.uid()
    inner join public.client_profiles cp
      on cp.id = r.client_id
      and cp.user_id = p_target_user_id
  )
  or exists (
    select 1
    from public.conversations conv
    inner join public.prestataire_profiles pp
      on pp.id = conv.prestataire_id
      and pp.user_id = auth.uid()
    inner join public.client_profiles cp
      on cp.id = conv.client_id
      and cp.user_id = p_target_user_id
  );
$$;

revoke all on function public.prestataire_has_booking_with_client(uuid) from public;
revoke all on function public.prestataire_has_conversation_with_client(uuid) from public;
revoke all on function public.prestataire_can_read_client_profile(uuid) from public;
revoke all on function public.prestataire_can_read_client_user(uuid) from public;

grant execute on function public.prestataire_has_booking_with_client(uuid) to authenticated;
grant execute on function public.prestataire_has_conversation_with_client(uuid) to authenticated;
grant execute on function public.prestataire_can_read_client_profile(uuid) to authenticated;
grant execute on function public.prestataire_can_read_client_user(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- client_profiles
-- ---------------------------------------------------------------------------

drop policy if exists "client_profiles_select_presta_booked" on public.client_profiles;

create policy "client_profiles_select_presta_booked"
on public.client_profiles for select
to authenticated
using (public.prestataire_can_read_client_profile(id));

-- ---------------------------------------------------------------------------
-- user_profiles
-- ---------------------------------------------------------------------------

drop policy if exists "user_profiles_select_presta_booked_clients" on public.user_profiles;

create policy "user_profiles_select_presta_booked_clients"
on public.user_profiles for select
to authenticated
using (public.prestataire_can_read_client_user(user_id));
