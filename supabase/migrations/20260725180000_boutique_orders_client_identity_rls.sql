-- Autorise le prestataire à lire le profil client lié à une commande boutique
-- (même pattern SECURITY DEFINER que réservations / conversations).

create or replace function public.prestataire_has_boutique_order_with_client(
  p_client_id uuid
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.boutique_commandes bc
    inner join public.prestataire_profiles pp
      on pp.id = bc.prestataire_id
      and pp.user_id = auth.uid()
    where bc.client_id = p_client_id
  );
$$;

revoke all on function public.prestataire_has_boutique_order_with_client(uuid)
  from public;
grant execute on function public.prestataire_has_boutique_order_with_client(uuid)
  to authenticated;

create or replace function public.prestataire_can_read_client_profile(p_client_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select
    public.prestataire_has_booking_with_client(p_client_id)
    or public.prestataire_has_conversation_with_client(p_client_id)
    or public.prestataire_has_boutique_order_with_client(p_client_id);
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
  )
  or exists (
    select 1
    from public.boutique_commandes bc
    inner join public.prestataire_profiles pp
      on pp.id = bc.prestataire_id
      and pp.user_id = auth.uid()
    inner join public.client_profiles cp
      on cp.id = bc.client_id
      and cp.user_id = p_target_user_id
  );
$$;
