-- Admin lecture boutique (commandes + catalogue) — SECURITY DEFINER + is_admin_user.

create or replace function public.admin_list_boutique_orders(
  p_limit integer default 100,
  p_statut text default null,
  p_payment_status text default null,
  p_from_date timestamptz default null,
  p_to_date timestamptz default null,
  p_search text default null
)
returns table (
  id uuid,
  created_at timestamptz,
  statut text,
  payment_status text,
  amount_cents integer,
  currency text,
  fulfillment text,
  client_name text,
  prestataire_salon text,
  prestataire_id uuid,
  items_count integer,
  stripe_payment_intent_id text,
  paid_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    bc.id,
    bc.created_at,
    bc.statut,
    bc.payment_status,
    bc.amount_cents,
    bc.currency,
    bc.fulfillment,
    trim(concat_ws(' ', cup.prenom, cup.nom)) as client_name,
    coalesce(
      nullif(trim(pp.nom_affiche), ''),
      nullif(trim(pp.nom_salon), ''),
      'Salon'
    ) as prestataire_salon,
    bc.prestataire_id,
    (
      select count(*)::integer
      from public.boutique_commande_items bci
      where bci.commande_id = bc.id
    ) as items_count,
    bc.stripe_payment_intent_id,
    bc.paid_at
  from public.boutique_commandes bc
  inner join public.client_profiles cp on cp.id = bc.client_id
  left join public.user_profiles cup on cup.user_id = cp.user_id
  inner join public.prestataire_profiles pp on pp.id = bc.prestataire_id
  where public.is_admin_user(auth.uid())
    and (p_statut is null or trim(p_statut) = '' or bc.statut = p_statut)
    and (
      p_payment_status is null
      or trim(p_payment_status) = ''
      or bc.payment_status = p_payment_status
    )
    and (p_from_date is null or bc.created_at >= p_from_date)
    and (p_to_date is null or bc.created_at <= p_to_date)
    and (
      p_search is null
      or trim(p_search) = ''
      or pp.nom_salon ilike '%' || trim(p_search) || '%'
      or pp.nom_affiche ilike '%' || trim(p_search) || '%'
      or cup.prenom ilike '%' || trim(p_search) || '%'
      or cup.nom ilike '%' || trim(p_search) || '%'
    )
  order by bc.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

revoke all on function public.admin_list_boutique_orders(
  integer, text, text, timestamptz, timestamptz, text
) from public;
grant execute on function public.admin_list_boutique_orders(
  integer, text, text, timestamptz, timestamptz, text
) to authenticated;

create or replace function public.admin_list_boutique_catalog(
  p_limit integer default 200,
  p_search text default null
)
returns table (
  prestataire_id uuid,
  prestataire_salon text,
  ville text,
  produits_actifs integer,
  produits_total integer,
  packs_actifs integer,
  packs_total integer,
  commandes_ouvertes integer,
  commandes_total integer
)
language sql
security definer
set search_path = public
as $$
  select
    pp.id as prestataire_id,
    coalesce(
      nullif(trim(pp.nom_affiche), ''),
      nullif(trim(pp.nom_salon), ''),
      'Salon'
    ) as prestataire_salon,
    pp.ville,
    (
      select count(*)::integer
      from public.produits_boutique pb
      where pb.prestataire_id = pp.id and pb.is_actif = true
    ) as produits_actifs,
    (
      select count(*)::integer
      from public.produits_boutique pb
      where pb.prestataire_id = pp.id
    ) as produits_total,
    (
      select count(*)::integer
      from public.packs_offre po
      where po.prestataire_id = pp.id and po.is_actif = true
    ) as packs_actifs,
    (
      select count(*)::integer
      from public.packs_offre po
      where po.prestataire_id = pp.id
    ) as packs_total,
    (
      select count(*)::integer
      from public.boutique_commandes bc
      where bc.prestataire_id = pp.id
        and bc.statut in (
          'pay_on_site', 'paid', 'preparing', 'ready', 'pending_payment'
        )
    ) as commandes_ouvertes,
    (
      select count(*)::integer
      from public.boutique_commandes bc
      where bc.prestataire_id = pp.id
    ) as commandes_total
  from public.prestataire_profiles pp
  where public.is_admin_user(auth.uid())
    and (
      exists (
        select 1 from public.produits_boutique pb where pb.prestataire_id = pp.id
      )
      or exists (
        select 1 from public.packs_offre po where po.prestataire_id = pp.id
      )
      or exists (
        select 1 from public.boutique_commandes bc where bc.prestataire_id = pp.id
      )
    )
    and (
      p_search is null
      or trim(p_search) = ''
      or pp.nom_salon ilike '%' || trim(p_search) || '%'
      or pp.nom_affiche ilike '%' || trim(p_search) || '%'
      or pp.ville ilike '%' || trim(p_search) || '%'
    )
  order by commandes_ouvertes desc, produits_actifs desc, packs_actifs desc
  limit greatest(1, least(coalesce(p_limit, 200), 500));
$$;

revoke all on function public.admin_list_boutique_catalog(integer, text)
  from public;
grant execute on function public.admin_list_boutique_catalog(integer, text)
  to authenticated;
