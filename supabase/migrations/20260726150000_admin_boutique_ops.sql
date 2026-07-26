-- Admin : mutations boutique (statut / réception / avis) + list enrichie.

-- ---------------------------------------------------------------------------
-- 1) Liste commandes enrichie (pack + avis)
-- ---------------------------------------------------------------------------
drop function if exists public.admin_list_boutique_orders(
  integer, text, text, timestamptz, timestamptz, text
);

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
  paid_at timestamptz,
  pack_id uuid,
  reservation_id uuid,
  notes_client text,
  has_avis boolean
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
    bc.paid_at,
    bc.pack_id,
    bc.reservation_id,
    bc.notes_client,
    exists (
      select 1 from public.avis_boutique ab where ab.commande_id = bc.id
    ) as has_avis
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

-- ---------------------------------------------------------------------------
-- 2) Forcer un statut (litiges / support)
-- ---------------------------------------------------------------------------
create or replace function public.admin_set_boutique_order_statut(
  p_commande_id uuid,
  p_statut text,
  p_reason text default null
)
returns public.boutique_commandes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.boutique_commandes;
  v_prev text;
  v_statut text := lower(trim(coalesce(p_statut, '')));
  v_reason text := nullif(trim(coalesce(p_reason, '')), '');
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis.';
  end if;

  if v_statut not in (
    'pending_payment',
    'pay_on_site',
    'paid',
    'preparing',
    'ready',
    'completed',
    'canceled'
  ) then
    raise exception 'Statut invalide.';
  end if;

  if v_reason is null or char_length(v_reason) < 3 then
    raise exception 'Un motif (min. 3 caractères) est obligatoire.';
  end if;

  select * into v_row
  from public.boutique_commandes
  where id = p_commande_id
  for update;

  if not found then
    raise exception 'Commande introuvable.';
  end if;

  v_prev := v_row.statut;

  update public.boutique_commandes
  set
    statut = v_statut,
    payment_status = case
      when v_statut = 'completed' then 'paid'
      when v_statut = 'canceled' then payment_status
      else payment_status
    end,
    paid_at = case
      when v_statut = 'completed' then coalesce(paid_at, now())
      else paid_at
    end,
    updated_at = now()
  where id = p_commande_id
  returning * into v_row;

  perform public.admin_write_audit_log(
    'boutique_order_set_statut',
    'boutique_commandes',
    p_commande_id::text,
    jsonb_build_object(
      'from', v_prev,
      'to', v_statut,
      'reason', v_reason
    )
  );

  return v_row;
end;
$$;

revoke all on function public.admin_set_boutique_order_statut(uuid, text, text)
  from public;
grant execute on function public.admin_set_boutique_order_statut(uuid, text, text)
  to authenticated;

comment on function public.admin_set_boutique_order_statut(uuid, text, text) is
  'Admin : force le statut d’une commande boutique (audit + motif obligatoire).';

-- ---------------------------------------------------------------------------
-- 3) Confirmer réception pour le client (ready → completed)
-- ---------------------------------------------------------------------------
create or replace function public.admin_confirm_boutique_receipt(
  p_commande_id uuid,
  p_reason text default null
)
returns public.boutique_commandes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.boutique_commandes;
  v_prev text;
  v_reason text := nullif(trim(coalesce(p_reason, '')), '');
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis.';
  end if;

  if v_reason is null or char_length(v_reason) < 3 then
    raise exception 'Un motif (min. 3 caractères) est obligatoire.';
  end if;

  select * into v_row
  from public.boutique_commandes
  where id = p_commande_id
  for update;

  if not found then
    raise exception 'Commande introuvable.';
  end if;

  if v_row.statut = 'completed' then
    return v_row;
  end if;

  if v_row.statut not in ('ready', 'preparing', 'paid', 'pay_on_site') then
    raise exception 'Statut incompatible pour confirmer la réception (%).', v_row.statut;
  end if;

  v_prev := v_row.statut;

  update public.boutique_commandes
  set
    statut = 'completed',
    payment_status = 'paid',
    paid_at = coalesce(paid_at, now()),
    updated_at = now()
  where id = p_commande_id
  returning * into v_row;

  perform public.admin_write_audit_log(
    'boutique_order_confirm_receipt',
    'boutique_commandes',
    p_commande_id::text,
    jsonb_build_object('reason', v_reason, 'previous_statut', v_prev)
  );

  return v_row;
end;
$$;

revoke all on function public.admin_confirm_boutique_receipt(uuid, text)
  from public;
grant execute on function public.admin_confirm_boutique_receipt(uuid, text)
  to authenticated;

comment on function public.admin_confirm_boutique_receipt(uuid, text) is
  'Admin : confirme la réception produit à la place du client (support / litige).';

-- ---------------------------------------------------------------------------
-- 4) Liste + suppression avis boutique
-- ---------------------------------------------------------------------------
create or replace function public.admin_list_avis_boutique(
  p_limit integer default 100,
  p_search text default null
)
returns table (
  id uuid,
  created_at timestamptz,
  note integer,
  commentaire text,
  commande_id uuid,
  client_name text,
  prestataire_salon text,
  prestataire_id uuid,
  commande_statut text
)
language sql
security definer
set search_path = public
as $$
  select
    ab.id,
    ab.created_at,
    ab.note,
    ab.commentaire,
    ab.commande_id,
    trim(concat_ws(' ', cup.prenom, cup.nom)) as client_name,
    coalesce(
      nullif(trim(pp.nom_affiche), ''),
      nullif(trim(pp.nom_salon), ''),
      'Salon'
    ) as prestataire_salon,
    ab.prestataire_id,
    bc.statut as commande_statut
  from public.avis_boutique ab
  inner join public.boutique_commandes bc on bc.id = ab.commande_id
  inner join public.client_profiles cp on cp.id = ab.client_id
  left join public.user_profiles cup on cup.user_id = cp.user_id
  inner join public.prestataire_profiles pp on pp.id = ab.prestataire_id
  where public.is_admin_user(auth.uid())
    and (
      p_search is null
      or trim(p_search) = ''
      or pp.nom_salon ilike '%' || trim(p_search) || '%'
      or pp.nom_affiche ilike '%' || trim(p_search) || '%'
      or cup.prenom ilike '%' || trim(p_search) || '%'
      or cup.nom ilike '%' || trim(p_search) || '%'
      or coalesce(ab.commentaire, '') ilike '%' || trim(p_search) || '%'
    )
  order by ab.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

revoke all on function public.admin_list_avis_boutique(integer, text) from public;
grant execute on function public.admin_list_avis_boutique(integer, text)
  to authenticated;

create or replace function public.admin_delete_avis_boutique(
  p_avis_id uuid,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_commande_id uuid;
  v_reason text := nullif(trim(coalesce(p_reason, '')), '');
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis.';
  end if;

  if v_reason is null or char_length(v_reason) < 3 then
    raise exception 'Un motif (min. 3 caractères) est obligatoire.';
  end if;

  select commande_id into v_commande_id
  from public.avis_boutique
  where id = p_avis_id;

  if v_commande_id is null then
    raise exception 'Avis introuvable.';
  end if;

  delete from public.avis_boutique where id = p_avis_id;

  perform public.admin_write_audit_log(
    'boutique_avis_delete',
    'avis_boutique',
    p_avis_id::text,
    jsonb_build_object(
      'commande_id', v_commande_id,
      'reason', v_reason
    )
  );
end;
$$;

revoke all on function public.admin_delete_avis_boutique(uuid, text) from public;
grant execute on function public.admin_delete_avis_boutique(uuid, text)
  to authenticated;

comment on function public.admin_delete_avis_boutique(uuid, text) is
  'Admin : supprime un avis boutique (modération / litige).';
