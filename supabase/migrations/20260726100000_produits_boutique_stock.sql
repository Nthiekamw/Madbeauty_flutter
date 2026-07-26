-- Stock produits boutique : colonnes, décrément à la commande, restauration à l’annulation.

-- ---------------------------------------------------------------------------
-- 1) Colonnes stock
-- ---------------------------------------------------------------------------
alter table public.produits_boutique
  add column if not exists stock_illimite boolean not null default false,
  add column if not exists stock_qty integer not null default 0;

alter table public.produits_boutique
  drop constraint if exists produits_boutique_stock_qty_nonneg;

alter table public.produits_boutique
  add constraint produits_boutique_stock_qty_nonneg check (stock_qty >= 0);

comment on column public.produits_boutique.stock_illimite is
  'Si true, le stock n’est pas suivi (toujours commandable).';
comment on column public.produits_boutique.stock_qty is
  'Quantité disponible quand stock_illimite = false.';

-- Produits déjà en vitrine : pas de rupture soudaine.
update public.produits_boutique
set stock_illimite = true;

-- Flag idempotent restauration stock sur commande annulée.
alter table public.boutique_commandes
  add column if not exists stock_restored boolean not null default false;

comment on column public.boutique_commandes.stock_restored is
  'True après restauration du stock suite à canceled (évite double crédit).';

-- ---------------------------------------------------------------------------
-- 2) Helper disponibilité
-- ---------------------------------------------------------------------------
create or replace function public.boutique_produit_stock_available(
  p_illimite boolean,
  p_qty integer
)
returns integer
language sql
immutable
as $$
  select case
    when coalesce(p_illimite, false) then null
    else greatest(coalesce(p_qty, 0), 0)
  end;
$$;

comment on function public.boutique_produit_stock_available(boolean, integer) is
  'Null = illimité ; sinon quantité restante (>= 0).';

-- ---------------------------------------------------------------------------
-- 3) Restauration stock à l’annulation
-- ---------------------------------------------------------------------------
create or replace function public.boutique_commandes_restore_stock()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
begin
  if new.statut is distinct from 'canceled' then
    return new;
  end if;
  if old.statut = 'canceled' then
    return new;
  end if;
  if coalesce(new.stock_restored, false) then
    return new;
  end if;

  for r in
    select
      i.produit_id,
      i.quantite
    from public.boutique_commande_items i
    where i.commande_id = new.id
      and i.produit_id is not null
  loop
    update public.produits_boutique p
    set
      stock_qty = p.stock_qty + r.quantite,
      updated_at = now()
    where p.id = r.produit_id
      and coalesce(p.stock_illimite, false) = false;
  end loop;

  new.stock_restored := true;
  return new;
end;
$$;

drop trigger if exists trg_boutique_commandes_restore_stock on public.boutique_commandes;
create trigger trg_boutique_commandes_restore_stock
before update of statut on public.boutique_commandes
for each row
execute function public.boutique_commandes_restore_stock();

-- ---------------------------------------------------------------------------
-- 4) RPC création commande + décrément atomique
-- ---------------------------------------------------------------------------
-- Payload JSON attendu :
-- {
--   "prestataire_id": "uuid",
--   "pay_on_site": true|false,
--   "notes_client": "...",
--   "items": [ { "produit_id": "uuid", "quantite": 1 }, ... ]
-- }
create or replace function public.create_boutique_commande_from_cart(
  p_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_client_id uuid;
  v_presta_id uuid;
  v_pay_on_site boolean;
  v_notes text;
  v_items jsonb;
  v_item jsonb;
  v_produit_id uuid;
  v_qty integer;
  v_prod record;
  v_amount_cents integer := 0;
  v_statut text;
  v_payment_status text;
  v_commande_id uuid;
  v_item_rows jsonb := '[]'::jsonb;
  v_prix_cents integer;
  v_ids uuid[] := array[]::uuid[];
begin
  if v_user_id is null then
    raise exception 'Connecte-toi pour commander.';
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = v_user_id
  limit 1;

  if v_client_id is null then
    raise exception 'Profil client manquant.';
  end if;

  v_presta_id := nullif(trim(p_payload ->> 'prestataire_id'), '')::uuid;
  v_pay_on_site := coalesce((p_payload ->> 'pay_on_site')::boolean, true);
  v_notes := nullif(trim(p_payload ->> 'notes_client'), '');
  v_items := coalesce(p_payload -> 'items', '[]'::jsonb);

  if v_presta_id is null then
    raise exception 'Panier invalide.';
  end if;
  if jsonb_typeof(v_items) <> 'array' or jsonb_array_length(v_items) = 0 then
    raise exception 'Panier invalide.';
  end if;

  -- Expire pending abandonnés du client (passe par trigger restore si déjà décrémenté).
  perform public.expire_own_stale_boutique_pending_orders(interval '2 hours');

  -- Collecte ids + lock
  for v_item in select value from jsonb_array_elements(v_items) as t(value)
  loop
    v_produit_id := nullif(trim(v_item ->> 'produit_id'), '')::uuid;
    if v_produit_id is null then
      raise exception 'Produit invalide dans le panier.';
    end if;
    v_ids := array_append(v_ids, v_produit_id);
  end loop;

  -- Verrouille les lignes produit (ordre stable pour éviter deadlocks).
  perform p.id
  from public.produits_boutique p
  where p.id = any (v_ids)
  order by p.id
  for update;

  for v_item in select value from jsonb_array_elements(v_items) as t(value)
  loop
    v_produit_id := (v_item ->> 'produit_id')::uuid;
    v_qty := greatest(coalesce((v_item ->> 'quantite')::integer, 1), 1);

    select
      p.id,
      p.prestataire_id,
      p.nom,
      p.conditionnement,
      p.prix,
      p.is_actif,
      p.stock_illimite,
      p.stock_qty
    into v_prod
    from public.produits_boutique p
    where p.id = v_produit_id;

    if not found then
      raise exception 'Un produit du panier n’est plus disponible.';
    end if;
    if v_prod.prestataire_id is distinct from v_presta_id then
      raise exception 'Panier multi-salon interdit.';
    end if;
    if coalesce(v_prod.is_actif, false) = false then
      raise exception 'Le produit « % » n’est plus disponible.', v_prod.nom;
    end if;
    if coalesce(v_prod.stock_illimite, false) = false
       and coalesce(v_prod.stock_qty, 0) < v_qty then
      raise exception 'Stock insuffisant pour « % ».', v_prod.nom;
    end if;

    v_prix_cents := round(coalesce(v_prod.prix, 0) * 100)::integer;
    if v_prix_cents < 0 then
      raise exception 'Prix invalide pour « % ».', v_prod.nom;
    end if;
    v_amount_cents := v_amount_cents + (v_prix_cents * v_qty);

    v_item_rows := v_item_rows || jsonb_build_array(
      jsonb_build_object(
        'produit_id', v_produit_id,
        'nom_snapshot', v_prod.nom,
        'conditionnement_snapshot', v_prod.conditionnement,
        'prix_cents', v_prix_cents,
        'quantite', v_qty
      )
    );

    if coalesce(v_prod.stock_illimite, false) = false then
      update public.produits_boutique
      set
        stock_qty = stock_qty - v_qty,
        updated_at = now()
      where id = v_produit_id;
    end if;
  end loop;

  if v_amount_cents <= 0 then
    raise exception 'Montant de commande invalide.';
  end if;

  if v_pay_on_site then
    v_statut := 'pay_on_site';
    v_payment_status := 'unpaid';
  else
    v_statut := 'pending_payment';
    v_payment_status := 'pending';
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
    stock_restored
  )
  values (
    v_client_id,
    v_presta_id,
    v_statut,
    v_payment_status,
    v_amount_cents,
    'eur',
    'pickup',
    v_notes,
    false
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
    (elem ->> 'produit_id')::uuid,
    elem ->> 'nom_snapshot',
    nullif(elem ->> 'conditionnement_snapshot', ''),
    (elem ->> 'prix_cents')::integer,
    (elem ->> 'quantite')::integer
  from jsonb_array_elements(v_item_rows) as elem;

  return jsonb_build_object(
    'commande_id', v_commande_id,
    'amount_cents', v_amount_cents,
    'statut', v_statut
  );
end;
$$;

revoke all on function public.create_boutique_commande_from_cart(jsonb) from public;
grant execute on function public.create_boutique_commande_from_cart(jsonb) to authenticated;

comment on function public.create_boutique_commande_from_cart(jsonb) is
  'Crée une commande boutique et décrémente le stock de façon atomique.';

-- ---------------------------------------------------------------------------
-- 5) Expire pending : s’assurer que canceled déclenche le restore
-- ---------------------------------------------------------------------------
create or replace function public.expire_stale_boutique_pending_orders(
  p_max_age interval default interval '2 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
begin
  update public.boutique_commandes
  set
    statut = 'canceled',
    payment_status = 'failed',
    updated_at = now()
  where statut = 'pending_payment'
    and payment_status in ('pending', 'unpaid')
    and created_at < (now() - p_max_age)
    and coalesce(stock_restored, false) = false;
  get diagnostics n = row_count;
  return n;
end;
$$;

create or replace function public.expire_own_stale_boutique_pending_orders(
  p_max_age interval default interval '2 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
  v_client_id uuid;
begin
  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    return 0;
  end if;

  update public.boutique_commandes
  set
    statut = 'canceled',
    payment_status = 'failed',
    updated_at = now()
  where client_id = v_client_id
    and statut = 'pending_payment'
    and payment_status in ('pending', 'unpaid')
    and created_at < (now() - p_max_age);
  get diagnostics n = row_count;
  return n;
end;
$$;
