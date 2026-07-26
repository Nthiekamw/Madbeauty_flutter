-- Checkout pack unifié : pack_id + duration sur reservations,
-- snapshot items, commande boutique liée, RPC create_pack_booking.

-- ---------------------------------------------------------------------------
-- 1) Colonnes reservations
-- ---------------------------------------------------------------------------
alter table public.reservations
  add column if not exists pack_id uuid
    references public.packs_offre (id) on delete restrict,
  add column if not exists duration_minutes integer;

comment on column public.reservations.pack_id is
  'Pack réservé (null = service unitaire).';
comment on column public.reservations.duration_minutes is
  'Durée bloquée du créneau (minutes). Pack = somme des services.';

-- Backfill durée depuis le service (défaut 30).
update public.reservations r
set duration_minutes = coalesce(
  (
    select greatest(coalesce(s.duree_minutes, 30), 1)
    from public.services_beaute s
    where s.id = r.service_id
  ),
  30
)
where r.duration_minutes is null;

alter table public.reservations
  alter column duration_minutes set default 30;

alter table public.reservations
  alter column duration_minutes set not null;

alter table public.reservations
  drop constraint if exists reservations_duration_minutes_pos;

alter table public.reservations
  add constraint reservations_duration_minutes_pos
  check (duration_minutes > 0 and duration_minutes <= 24 * 60);

create index if not exists idx_reservations_pack
  on public.reservations (pack_id)
  where pack_id is not null;

create index if not exists idx_reservations_presta_interval
  on public.reservations (prestataire_id, date_heure)
  where statut not in ('annulee', 'cancelled');

-- ---------------------------------------------------------------------------
-- 2) Snapshot items pack
-- ---------------------------------------------------------------------------
create table if not exists public.reservation_pack_items (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null
    references public.reservations (id) on delete cascade,
  item_type text not null,
  service_id uuid references public.services_beaute (id) on delete set null,
  produit_id uuid references public.produits_boutique (id) on delete set null,
  quantite integer not null default 1,
  label text not null,
  unit_price_cents integer not null default 0,
  sort_order integer not null default 0,
  constraint reservation_pack_items_type_check check (
    item_type in ('service', 'produit')
  ),
  constraint reservation_pack_items_qty_pos check (quantite > 0),
  constraint reservation_pack_items_price_nonneg check (unit_price_cents >= 0),
  constraint reservation_pack_items_ref_check check (
    (item_type = 'service' and service_id is not null and produit_id is null)
    or (item_type = 'produit' and produit_id is not null and service_id is null)
  )
);

create index if not exists idx_reservation_pack_items_reservation
  on public.reservation_pack_items (reservation_id, sort_order);

comment on table public.reservation_pack_items is
  'Snapshot des lignes d’un pack au moment de la réservation.';

alter table public.reservation_pack_items enable row level security;

drop policy if exists reservation_pack_items_select_participant
  on public.reservation_pack_items;
create policy reservation_pack_items_select_participant
on public.reservation_pack_items for select to authenticated
using (
  exists (
    select 1
    from public.reservations r
    left join public.client_profiles c on c.id = r.client_id
    left join public.prestataire_profiles p on p.id = r.prestataire_id
    where r.id = reservation_pack_items.reservation_id
      and (c.user_id = auth.uid() or p.user_id = auth.uid())
  )
);

-- Inserts via security definer RPC only.
revoke insert, update, delete on public.reservation_pack_items from authenticated, anon;

-- ---------------------------------------------------------------------------
-- 3) Lien boutique_commandes ↔ reservation / pack
-- ---------------------------------------------------------------------------
alter table public.boutique_commandes
  add column if not exists reservation_id uuid
    references public.reservations (id) on delete set null,
  add column if not exists pack_id uuid
    references public.packs_offre (id) on delete set null;

create unique index if not exists boutique_commandes_reservation_id_uidx
  on public.boutique_commandes (reservation_id)
  where reservation_id is not null;

comment on column public.boutique_commandes.reservation_id is
  'Réservation pack liée (produits inclus dans prix_pack).';
comment on column public.boutique_commandes.pack_id is
  'Pack d’origine si commande créée via checkout pack.';

-- Autoriser amount_cents = 0 (inclus dans le pack).
alter table public.boutique_commandes
  drop constraint if exists boutique_commandes_amount_pos;

alter table public.boutique_commandes
  add constraint boutique_commandes_amount_nonneg check (amount_cents >= 0);

-- ---------------------------------------------------------------------------
-- 4) Helpers disponibilité / chevauchement
-- ---------------------------------------------------------------------------
create or replace function public.reservation_is_active_statut(p_statut text)
returns boolean
language sql
immutable
as $$
  select lower(replace(coalesce(p_statut, ''), 'é', 'e')) in (
    'en_attente', 'pending', 'confirmee', 'confirmed'
  );
$$;

create or replace function public.count_overlapping_reservations(
  p_prestataire_id uuid,
  p_start timestamptz,
  p_duration_minutes integer,
  p_exclude_reservation_id uuid default null
)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.reservations r
  where r.prestataire_id = p_prestataire_id
    and public.reservation_is_active_statut(r.statut)
    and (p_exclude_reservation_id is null or r.id <> p_exclude_reservation_id)
    and r.date_heure < (p_start + make_interval(mins => greatest(p_duration_minutes, 1)))
    and (r.date_heure + make_interval(mins => greatest(coalesce(r.duration_minutes, 30), 1)))
        > p_start;
$$;

revoke all on function public.count_overlapping_reservations(uuid, timestamptz, integer, uuid)
from public;
grant execute on function public.count_overlapping_reservations(uuid, timestamptz, integer, uuid)
to authenticated, service_role;

create or replace function public.slot_fits_disponibilite(
  p_prestataire_id uuid,
  p_start timestamptz,
  p_duration_minutes integer
)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_dow integer;
  v_start_t time;
  v_end_t time;
  v_found boolean := false;
begin
  -- jour_semaine PG : 0 = dimanche … 6 = samedi (aligné Date.getDay / disponibilites).
  v_dow := extract(dow from p_start)::integer;
  v_start_t := p_start::time;
  v_end_t := (p_start + make_interval(mins => greatest(p_duration_minutes, 1)))::time;

  -- Si la durée traverse minuit, refuser (créneaux journaliers).
  if (p_start::date)
       <> ((p_start + make_interval(mins => greatest(p_duration_minutes, 1)))::date)
  then
    return false;
  end if;

  select exists (
    select 1
    from public.disponibilites d
    where d.prestataire_id = p_prestataire_id
      and d.jour_semaine = v_dow
      and d.heure_debut <= v_start_t
      and d.heure_fin >= v_end_t
  ) into v_found;

  return coalesce(v_found, false);
end;
$$;

revoke all on function public.slot_fits_disponibilite(uuid, timestamptz, integer)
from public;
grant execute on function public.slot_fits_disponibilite(uuid, timestamptz, integer)
to authenticated, service_role;

-- Capacité au début du créneau (réutilise logique existante simplifiée).
create or replace function public.slot_capacity_at(
  p_prestataire_id uuid,
  p_at timestamptz
)
returns integer
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_dow integer := extract(dow from p_at)::integer;
  v_t time := p_at::time;
  v_cap integer;
begin
  select o.capacite_simultanee into v_cap
  from public.disponibilite_capacity_overrides o
  where o.prestataire_id = p_prestataire_id
    and o.jour_semaine = v_dow
    and o.heure_debut <= v_t
    and o.heure_fin > v_t
  limit 1;

  if v_cap is not null and v_cap > 0 then
    return v_cap;
  end if;

  select d.capacite_simultanee into v_cap
  from public.disponibilites d
  where d.prestataire_id = p_prestataire_id
    and d.jour_semaine = v_dow
    and d.heure_debut <= v_t
    and d.heure_fin > v_t
  limit 1;

  return coalesce(v_cap, 1);
end;
$$;

revoke all on function public.slot_capacity_at(uuid, timestamptz) from public;
grant execute on function public.slot_capacity_at(uuid, timestamptz)
to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5) Annulation réservation pack → annule commande boutique liée
-- ---------------------------------------------------------------------------
create or replace function public.reservations_cancel_linked_boutique_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.reservation_is_active_statut(old.statut)
     and not public.reservation_is_active_statut(new.statut)
     and lower(replace(coalesce(new.statut, ''), 'é', 'e')) in ('annulee', 'cancelled')
  then
    update public.boutique_commandes
    set
      statut = 'canceled',
      updated_at = now()
    where reservation_id = new.id
      and statut not in ('canceled', 'completed');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_reservations_cancel_linked_boutique_order
  on public.reservations;
create trigger trg_reservations_cancel_linked_boutique_order
after update of statut on public.reservations
for each row
execute function public.reservations_cancel_linked_boutique_order();

-- ---------------------------------------------------------------------------
-- 6) RPC create_pack_booking
-- ---------------------------------------------------------------------------
-- Payload :
-- {
--   "pack_id": "uuid",
--   "date_heure": "ISO timestamptz",
--   "payment_mode": "on_site"|"deposit_20",
--   "notes_client": "...",
--   "stripe_payment_intent_id": "...",
--   "amount_cents": 0,
--   "service_price_cents": 0,
--   "platform_fee_cents": 0,
--   "prestataire_amount_cents": 0,
--   "original_service_price_cents": 0,
--   "referral_discount_percent": 0,
--   "payment_status": "authorized"|null,
--   "client_id": "uuid"  -- optionnel (service_role / Edge)
-- }
create or replace function public.create_pack_booking(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_client_id uuid;
  v_pack_id uuid;
  v_date_heure timestamptz;
  v_payment_mode text;
  v_notes text;
  v_pi text;
  v_pack record;
  v_item record;
  v_first_service_id uuid;
  v_duration integer := 0;
  v_service_count integer := 0;
  v_prod_count integer := 0;
  v_capacity integer;
  v_overlap integer;
  v_prix_pack_cents integer;
  v_service_price_cents integer;
  v_platform_fee_cents integer;
  v_prestataire_amount_cents integer;
  v_amount_cents integer;
  v_original_cents integer;
  v_referral_pct integer;
  v_payment_status text;
  v_reservation_id uuid;
  v_commande_id uuid;
  v_sort integer := 0;
  v_prod_ids uuid[] := array[]::uuid[];
  v_statut_cmd text;
  v_pay_status_cmd text;
  v_existing_pi uuid;
begin
  v_pack_id := nullif(trim(p_payload ->> 'pack_id'), '')::uuid;
  v_date_heure := nullif(trim(p_payload ->> 'date_heure'), '')::timestamptz;
  v_payment_mode := nullif(trim(p_payload ->> 'payment_mode'), '');
  v_notes := nullif(trim(p_payload ->> 'notes_client'), '');
  v_pi := nullif(trim(p_payload ->> 'stripe_payment_intent_id'), '');

  if v_pack_id is null or v_date_heure is null then
    raise exception 'Paramètres pack invalides.';
  end if;
  if v_payment_mode is null or v_payment_mode not in ('on_site', 'deposit_20') then
    raise exception 'Mode de paiement invalide.';
  end if;

  -- Idempotence Stripe
  if v_pi is not null then
    select r.id into v_existing_pi
    from public.reservations r
    where r.stripe_payment_intent_id = v_pi
    limit 1;
    if v_existing_pi is not null then
      select bc.id into v_commande_id
      from public.boutique_commandes bc
      where bc.reservation_id = v_existing_pi
      limit 1;
      return jsonb_build_object(
        'reservation_id', v_existing_pi,
        'commande_id', v_commande_id,
        'already_created', true
      );
    end if;
  end if;

  -- Client : auth.uid() ou client_id fourni (Edge service_role)
  if p_payload ? 'client_id' and nullif(trim(p_payload ->> 'client_id'), '') is not null then
    v_client_id := (p_payload ->> 'client_id')::uuid;
  elsif v_user_id is not null then
    select c.id into v_client_id
    from public.client_profiles c
    where c.user_id = v_user_id
    limit 1;
  end if;

  if v_client_id is null then
    raise exception 'Connecte-toi pour réserver ce pack.';
  end if;

  select
    po.id,
    po.prestataire_id,
    po.titre,
    po.prix_pack,
    po.is_actif,
    po.starts_at,
    po.ends_at
  into v_pack
  from public.packs_offre po
  where po.id = v_pack_id
  for update;

  if not found then
    raise exception 'Pack introuvable.';
  end if;
  if coalesce(v_pack.is_actif, false) = false then
    raise exception 'Ce pack n’est plus disponible.';
  end if;
  if v_pack.starts_at is not null and v_pack.starts_at > now() then
    raise exception 'Ce pack n’est pas encore disponible.';
  end if;
  if v_pack.ends_at is not null and v_pack.ends_at < now() then
    raise exception 'Cette offre a expiré.';
  end if;

  -- Interdiction de réserver son propre salon
  if exists (
    select 1 from public.prestataire_profiles p
    where p.id = v_pack.prestataire_id
      and p.user_id = (
        select c.user_id from public.client_profiles c where c.id = v_client_id
      )
  ) then
    raise exception 'Réservation sur son propre profil interdite.';
  end if;

  -- Agrège items + durée
  for v_item in
    select
      pi.item_type,
      pi.service_id,
      pi.produit_id,
      pi.quantite,
      pi.sort_order,
      s.nom as service_nom,
      s.duree_minutes,
      s.prix as service_prix,
      s.is_actif as service_actif,
      s.prestataire_id as service_presta,
      p.nom as produit_nom,
      p.prix as produit_prix,
      p.is_actif as produit_actif,
      p.prestataire_id as produit_presta,
      p.stock_illimite,
      p.stock_qty,
      p.conditionnement
    from public.pack_items pi
    left join public.services_beaute s on s.id = pi.service_id
    left join public.produits_boutique p on p.id = pi.produit_id
    where pi.pack_id = v_pack_id
    order by pi.sort_order, pi.id
  loop
    if v_item.item_type = 'service' then
      if v_item.service_id is null or coalesce(v_item.service_actif, false) = false then
        raise exception 'Un service du pack n’est plus disponible.';
      end if;
      if v_item.service_presta is distinct from v_pack.prestataire_id then
        raise exception 'Pack invalide (service).';
      end if;
      v_service_count := v_service_count + 1;
      v_duration := v_duration
        + (greatest(coalesce(v_item.duree_minutes, 30), 1) * greatest(v_item.quantite, 1));
      if v_first_service_id is null then
        v_first_service_id := v_item.service_id;
      end if;
    elsif v_item.item_type = 'produit' then
      if v_item.produit_id is null or coalesce(v_item.produit_actif, false) = false then
        raise exception 'Un produit du pack n’est plus disponible.';
      end if;
      if v_item.produit_presta is distinct from v_pack.prestataire_id then
        raise exception 'Pack invalide (produit).';
      end if;
      v_prod_count := v_prod_count + 1;
      v_prod_ids := array_append(v_prod_ids, v_item.produit_id);
    end if;
  end loop;

  if v_service_count < 1 then
    raise exception 'Ce pack ne contient aucun service réservable.';
  end if;
  if v_duration < 1 then
    raise exception 'Durée du pack invalide.';
  end if;

  -- Créneau
  if not public.slot_fits_disponibilite(
    v_pack.prestataire_id, v_date_heure, v_duration
  ) then
    raise exception 'Ce créneau ne couvre pas toute la durée du pack.';
  end if;

  -- Indisponibilités
  if exists (
    select 1
    from public.indisponibilites i
    where i.prestataire_id = v_pack.prestataire_id
      and i.date_debut < (v_date_heure + make_interval(mins => v_duration))
      and i.date_fin > v_date_heure
  ) then
    raise exception 'Créneau indisponible (indisponibilité).';
  end if;

  v_capacity := public.slot_capacity_at(v_pack.prestataire_id, v_date_heure);
  v_overlap := public.count_overlapping_reservations(
    v_pack.prestataire_id, v_date_heure, v_duration, null
  );
  if v_overlap >= v_capacity then
    raise exception 'Créneau indisponible.';
  end if;

  -- Stock produits
  if cardinality(v_prod_ids) > 0 then
    perform p.id
    from public.produits_boutique p
    where p.id = any (v_prod_ids)
    order by p.id
    for update;

    for v_item in
      select
        pi.produit_id,
        pi.quantite,
        p.nom,
        p.stock_illimite,
        p.stock_qty,
        p.is_actif
      from public.pack_items pi
      join public.produits_boutique p on p.id = pi.produit_id
      where pi.pack_id = v_pack_id
        and pi.item_type = 'produit'
    loop
      if coalesce(v_item.is_actif, false) = false then
        raise exception 'Le produit « % » n’est plus disponible.', v_item.nom;
      end if;
      if coalesce(v_item.stock_illimite, false) = false
         and coalesce(v_item.stock_qty, 0) < greatest(v_item.quantite, 1) then
        raise exception 'Stock insuffisant pour « % ».', v_item.nom;
      end if;
    end loop;
  end if;

  v_prix_pack_cents := round(coalesce(v_pack.prix_pack, 0) * 100)::integer;
  if v_prix_pack_cents < 0 then
    raise exception 'Prix du pack invalide.';
  end if;

  v_service_price_cents := coalesce(
    (p_payload ->> 'service_price_cents')::integer,
    v_prix_pack_cents
  );
  v_platform_fee_cents := coalesce((p_payload ->> 'platform_fee_cents')::integer, 0);
  v_prestataire_amount_cents := coalesce(
    (p_payload ->> 'prestataire_amount_cents')::integer,
    case when v_payment_mode = 'on_site' then 0 else null end
  );
  v_amount_cents := nullif((p_payload ->> 'amount_cents')::integer, null);
  v_original_cents := nullif((p_payload ->> 'original_service_price_cents')::integer, null);
  v_referral_pct := nullif((p_payload ->> 'referral_discount_percent')::integer, null);
  v_payment_status := nullif(trim(p_payload ->> 'payment_status'), '');

  if v_payment_mode = 'on_site' then
    v_prestataire_amount_cents := 0;
  end if;

  insert into public.reservations (
    client_id,
    prestataire_id,
    service_id,
    pack_id,
    duration_minutes,
    date_heure,
    statut,
    notes_client,
    amount_cents,
    currency,
    stripe_payment_intent_id,
    payment_status,
    paid_at,
    payment_mode,
    platform_fee_cents,
    service_price_cents,
    prestataire_amount_cents,
    original_service_price_cents,
    referral_discount_percent
  )
  values (
    v_client_id,
    v_pack.prestataire_id,
    v_first_service_id,
    v_pack_id,
    v_duration,
    date_trunc('minute', v_date_heure),
    'en_attente',
    v_notes,
    v_amount_cents,
    'eur',
    v_pi,
    v_payment_status,
    case when v_pi is not null then now() else null end,
    v_payment_mode,
    v_platform_fee_cents,
    v_service_price_cents,
    v_prestataire_amount_cents,
    v_original_cents,
    v_referral_pct
  )
  returning id into v_reservation_id;

  -- Snapshot
  for v_item in
    select
      pi.item_type,
      pi.service_id,
      pi.produit_id,
      pi.quantite,
      pi.sort_order,
      s.nom as service_nom,
      s.prix as service_prix,
      p.nom as produit_nom,
      p.prix as produit_prix
    from public.pack_items pi
    left join public.services_beaute s on s.id = pi.service_id
    left join public.produits_boutique p on p.id = pi.produit_id
    where pi.pack_id = v_pack_id
    order by pi.sort_order, pi.id
  loop
    v_sort := v_sort + 1;
    insert into public.reservation_pack_items (
      reservation_id,
      item_type,
      service_id,
      produit_id,
      quantite,
      label,
      unit_price_cents,
      sort_order
    )
    values (
      v_reservation_id,
      v_item.item_type,
      case when v_item.item_type = 'service' then v_item.service_id else null end,
      case when v_item.item_type = 'produit' then v_item.produit_id else null end,
      greatest(v_item.quantite, 1),
      case
        when v_item.item_type = 'service' then coalesce(v_item.service_nom, 'Service')
        else coalesce(v_item.produit_nom, 'Produit')
      end,
      case
        when v_item.item_type = 'service'
          then round(coalesce(v_item.service_prix, 0) * 100)::integer
        else round(coalesce(v_item.produit_prix, 0) * 100)::integer
      end,
      coalesce(v_item.sort_order, v_sort)
    );
  end loop;

  -- Commande boutique liée (produits inclus)
  if v_prod_count > 0 then
    if v_payment_mode = 'on_site' then
      v_statut_cmd := 'pay_on_site';
      v_pay_status_cmd := 'unpaid';
    else
      v_statut_cmd := 'paid';
      v_pay_status_cmd := 'paid';
    end if;

    insert into public.boutique_commandes (
      client_id,
      prestataire_id,
      statut,
      payment_status,
      amount_cents,
      currency,
      fulfillment,
      notes_client,
      stock_restored,
      reservation_id,
      pack_id,
      paid_at
    )
    values (
      v_client_id,
      v_pack.prestataire_id,
      v_statut_cmd,
      v_pay_status_cmd,
      0,
      'eur',
      'pickup',
      coalesce(v_notes, 'Inclus dans le pack « ' || v_pack.titre || ' »'),
      false,
      v_reservation_id,
      v_pack_id,
      case when v_payment_mode = 'deposit_20' then now() else null end
    )
    returning id into v_commande_id;

    insert into public.boutique_commande_items (
      commande_id,
      produit_id,
      nom_snapshot,
      conditionnement_snapshot,
      prix_cents,
      quantite
    )
    select
      v_commande_id,
      pi.produit_id,
      p.nom,
      p.conditionnement,
      0,
      greatest(pi.quantite, 1)
    from public.pack_items pi
    join public.produits_boutique p on p.id = pi.produit_id
    where pi.pack_id = v_pack_id
      and pi.item_type = 'produit';

    update public.produits_boutique p
    set
      stock_qty = p.stock_qty - sub.qty,
      updated_at = now()
    from (
      select pi.produit_id, sum(greatest(pi.quantite, 1))::integer as qty
      from public.pack_items pi
      where pi.pack_id = v_pack_id
        and pi.item_type = 'produit'
      group by pi.produit_id
    ) sub
    where p.id = sub.produit_id
      and coalesce(p.stock_illimite, false) = false;
  end if;

  return jsonb_build_object(
    'reservation_id', v_reservation_id,
    'commande_id', v_commande_id,
    'duration_minutes', v_duration,
    'already_created', false
  );
end;
$$;

revoke all on function public.create_pack_booking(jsonb) from public;
grant execute on function public.create_pack_booking(jsonb)
to authenticated, service_role;

comment on function public.create_pack_booking(jsonb) is
  'Réservation pack atomique : créneau durée cumulée + stock produits + snapshot.';
