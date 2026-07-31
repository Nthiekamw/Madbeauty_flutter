-- Wishlist produits + alertes, chat inquiry, litiges réservation (médiation).

-- =============================================================================
-- 1) Wishlist produits
-- =============================================================================

create table if not exists public.wishlist_produits (
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  produit_id uuid not null references public.produits_boutique (id) on delete cascade,
  created_at timestamptz not null default now(),
  alert_on_restock boolean not null default true,
  alert_on_price_drop boolean not null default true,
  last_seen_price numeric(12, 2) not null,
  primary key (client_id, produit_id)
);

create index if not exists idx_wishlist_produits_produit
  on public.wishlist_produits (produit_id);

comment on table public.wishlist_produits is
  'Wishlist client sur produits boutique + préférences d’alerte.';

alter table public.wishlist_produits enable row level security;

drop policy if exists "wishlist_produits_select_own" on public.wishlist_produits;
create policy "wishlist_produits_select_own"
  on public.wishlist_produits for select to authenticated
  using (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = wishlist_produits.client_id and cp.user_id = auth.uid()
    )
  );

drop policy if exists "wishlist_produits_insert_own" on public.wishlist_produits;
create policy "wishlist_produits_insert_own"
  on public.wishlist_produits for insert to authenticated
  with check (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = wishlist_produits.client_id and cp.user_id = auth.uid()
    )
  );

drop policy if exists "wishlist_produits_update_own" on public.wishlist_produits;
create policy "wishlist_produits_update_own"
  on public.wishlist_produits for update to authenticated
  using (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = wishlist_produits.client_id and cp.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = wishlist_produits.client_id and cp.user_id = auth.uid()
    )
  );

drop policy if exists "wishlist_produits_delete_own" on public.wishlist_produits;
create policy "wishlist_produits_delete_own"
  on public.wishlist_produits for delete to authenticated
  using (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = wishlist_produits.client_id and cp.user_id = auth.uid()
    )
  );

-- Push wishlist via Edge Function
create or replace function public.trigger_wishlist_product_updated_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_was_oos boolean;
  v_now_in_stock boolean;
  v_price_drop boolean;
begin
  if TG_OP <> 'UPDATE' then
    return NEW;
  end if;

  v_was_oos := (
    coalesce(OLD.stock_illimite, false) = false
    and coalesce(OLD.stock_qty, 0) <= 0
  );
  v_now_in_stock := (
    coalesce(NEW.stock_illimite, false) = true
    or coalesce(NEW.stock_qty, 0) > 0
  );
  v_price_drop := (
    NEW.prix is distinct from OLD.prix
    and NEW.prix < OLD.prix
  );

  if (v_was_oos and v_now_in_stock) or v_price_drop then
    perform private.notify_edge_function(
      'on_wishlist_product_updated',
      jsonb_build_object(
        'type', 'UPDATE',
        'table', 'produits_boutique',
        'schema', 'public',
        'record', to_jsonb(NEW),
        'old_record', to_jsonb(OLD),
        'restock', (v_was_oos and v_now_in_stock),
        'price_drop', v_price_drop
      )
    );
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_wishlist_product_updated_push on public.produits_boutique;
create trigger trg_wishlist_product_updated_push
after update of prix, stock_qty, stock_illimite on public.produits_boutique
for each row
execute function public.trigger_wishlist_product_updated_push();

-- =============================================================================
-- 2) Chat inquiry (hors réservation)
-- =============================================================================

alter table public.conversations
  add column if not exists kind text not null default 'booking';

alter table public.conversations
  drop constraint if exists conversations_kind_check;
alter table public.conversations
  add constraint conversations_kind_check
  check (kind in ('booking', 'inquiry'));

comment on column public.conversations.kind is
  'booking = lié RDV ; inquiry = devis / conseil sans réservation.';

-- Rate limit soft inquiry : max 30 messages / jour / client vers un presta
create or replace function public.trg_messages_inquiry_rate_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_kind text;
  v_count integer;
begin
  if NEW.booking_id is not null then
    return NEW;
  end if;

  select c.kind into v_kind
  from public.conversations c
  where c.id = NEW.conversation_id;

  if v_kind is distinct from 'inquiry' then
    return NEW;
  end if;

  select count(*)::integer into v_count
  from public.messages m
  where m.conversation_id = NEW.conversation_id
    and m.sender_id = NEW.sender_id
    and m.created_at >= (now() - interval '1 day');

  if coalesce(v_count, 0) >= 30 then
    raise exception 'inquiry_rate_limit'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_messages_inquiry_rate_limit on public.messages;
create trigger trg_messages_inquiry_rate_limit
before insert on public.messages
for each row
execute function public.trg_messages_inquiry_rate_limit();

-- INSERT messages sans booking si conversation inquiry et participant
drop policy if exists "messages_insert_inquiry_participant" on public.messages;
create policy "messages_insert_inquiry_participant"
  on public.messages for insert to authenticated
  with check (
    sender_id = auth.uid()
    and booking_id is null
    and conversation_id is not null
    and exists (
      select 1
      from public.conversations c
      where c.id = messages.conversation_id
        and c.kind = 'inquiry'
        and (
          exists (
            select 1 from public.client_profiles cp
            where cp.id = c.client_id and cp.user_id = auth.uid()
          )
          or exists (
            select 1 from public.prestataire_profiles pp
            where pp.id = c.prestataire_id and pp.user_id = auth.uid()
          )
        )
    )
  );

-- =============================================================================
-- 3) Litiges réservation (médiation admin)
-- =============================================================================

create table if not exists public.booking_disputes (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null references public.reservations (id) on delete cascade,
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  opened_by text not null,
  reason text not null,
  status text not null default 'open',
  amount_cents integer,
  summary text,
  admin_notes text,
  resolution text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid references auth.users (id) on delete set null,
  constraint booking_disputes_opened_by_check
    check (opened_by in ('client', 'prestataire')),
  constraint booking_disputes_reason_check
    check (reason in ('no_show', 'deposit', 'quality', 'refund', 'other')),
  constraint booking_disputes_status_check
    check (status in (
      'open',
      'under_review',
      'resolved_favor_client',
      'resolved_favor_presta',
      'closed'
    ))
);

create unique index if not exists idx_booking_disputes_one_open
  on public.booking_disputes (reservation_id)
  where status in ('open', 'under_review');

create index if not exists idx_booking_disputes_status_created
  on public.booking_disputes (status, created_at desc);

create index if not exists idx_booking_disputes_client
  on public.booking_disputes (client_id, created_at desc);

create index if not exists idx_booking_disputes_presta
  on public.booking_disputes (prestataire_id, created_at desc);

comment on table public.booking_disputes is
  'Litiges réservation (acompte / no-show / qualité) — médiation admin.';

create table if not exists public.dispute_messages (
  id uuid primary key default gen_random_uuid(),
  dispute_id uuid not null references public.booking_disputes (id) on delete cascade,
  sender_user_id uuid not null references auth.users (id) on delete cascade,
  sender_role text not null,
  body text not null,
  created_at timestamptz not null default now(),
  constraint dispute_messages_sender_role_check
    check (sender_role in ('client', 'prestataire', 'admin')),
  constraint dispute_messages_body_len check (char_length(trim(body)) between 1 and 4000)
);

create index if not exists idx_dispute_messages_dispute_created
  on public.dispute_messages (dispute_id, created_at asc);

alter table public.booking_disputes enable row level security;
alter table public.dispute_messages enable row level security;

-- Helpers admin
create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.user_roles ur
    where ur.user_id = auth.uid() and ur.role = 'admin'
  );
$$;

drop policy if exists "booking_disputes_select_participants" on public.booking_disputes;
create policy "booking_disputes_select_participants"
  on public.booking_disputes for select to authenticated
  using (
    public.is_admin_user()
    or exists (
      select 1 from public.client_profiles cp
      where cp.id = booking_disputes.client_id and cp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.prestataire_profiles pp
      where pp.id = booking_disputes.prestataire_id and pp.user_id = auth.uid()
    )
  );

drop policy if exists "booking_disputes_insert_participants" on public.booking_disputes;
create policy "booking_disputes_insert_participants"
  on public.booking_disputes for insert to authenticated
  with check (
    (
      opened_by = 'client'
      and exists (
        select 1 from public.client_profiles cp
        where cp.id = client_id and cp.user_id = auth.uid()
      )
    )
    or (
      opened_by = 'prestataire'
      and exists (
        select 1 from public.prestataire_profiles pp
        where pp.id = prestataire_id and pp.user_id = auth.uid()
      )
    )
  );

drop policy if exists "booking_disputes_update_admin" on public.booking_disputes;
create policy "booking_disputes_update_admin"
  on public.booking_disputes for update to authenticated
  using (public.is_admin_user())
  with check (public.is_admin_user());

drop policy if exists "dispute_messages_select_participants" on public.dispute_messages;
create policy "dispute_messages_select_participants"
  on public.dispute_messages for select to authenticated
  using (
    exists (
      select 1 from public.booking_disputes d
      where d.id = dispute_messages.dispute_id
        and (
          public.is_admin_user()
          or exists (
            select 1 from public.client_profiles cp
            where cp.id = d.client_id and cp.user_id = auth.uid()
          )
          or exists (
            select 1 from public.prestataire_profiles pp
            where pp.id = d.prestataire_id and pp.user_id = auth.uid()
          )
        )
    )
  );

drop policy if exists "dispute_messages_insert_participants" on public.dispute_messages;
create policy "dispute_messages_insert_participants"
  on public.dispute_messages for insert to authenticated
  with check (
    sender_user_id = auth.uid()
    and exists (
      select 1 from public.booking_disputes d
      where d.id = dispute_id
        and d.status in ('open', 'under_review')
        and (
          public.is_admin_user()
          or (
            sender_role = 'client'
            and exists (
              select 1 from public.client_profiles cp
              where cp.id = d.client_id and cp.user_id = auth.uid()
            )
          )
          or (
            sender_role = 'prestataire'
            and exists (
              select 1 from public.prestataire_profiles pp
              where pp.id = d.prestataire_id and pp.user_id = auth.uid()
            )
          )
        )
    )
  );

-- RPC ouverture litige (valide éligibilité)
create or replace function public.open_booking_dispute(
  p_reservation_id uuid,
  p_reason text,
  p_summary text default null
)
returns public.booking_disputes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_res public.reservations%rowtype;
  v_opened_by text;
  v_client_ok boolean;
  v_presta_ok boolean;
  v_row public.booking_disputes;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'P0001';
  end if;

  if p_reason is null or p_reason not in ('no_show', 'deposit', 'quality', 'refund', 'other') then
    raise exception 'invalid_dispute_reason' using errcode = 'P0001';
  end if;

  select * into v_res from public.reservations where id = p_reservation_id;
  if not found then
    raise exception 'reservation_not_found' using errcode = 'P0001';
  end if;

  if v_res.statut not in ('confirmee', 'terminee', 'annulee') then
    raise exception 'dispute_not_eligible' using errcode = 'P0001';
  end if;

  select exists (
    select 1 from public.client_profiles cp
    where cp.id = v_res.client_id and cp.user_id = v_uid
  ) into v_client_ok;

  select exists (
    select 1 from public.prestataire_profiles pp
    where pp.id = v_res.prestataire_id and pp.user_id = v_uid
  ) into v_presta_ok;

  if v_client_ok then
    v_opened_by := 'client';
  elsif v_presta_ok then
    v_opened_by := 'prestataire';
  else
    raise exception 'forbidden' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from public.booking_disputes d
    where d.reservation_id = p_reservation_id
      and d.status in ('open', 'under_review')
  ) then
    raise exception 'dispute_already_open' using errcode = 'P0001';
  end if;

  insert into public.booking_disputes (
    reservation_id,
    client_id,
    prestataire_id,
    opened_by,
    reason,
    status,
    amount_cents,
    summary
  ) values (
    v_res.id,
    v_res.client_id,
    v_res.prestataire_id,
    v_opened_by,
    p_reason,
    'open',
    coalesce(v_res.amount_cents, v_res.service_price_cents),
    nullif(trim(p_summary), '')
  )
  returning * into v_row;

  perform private.notify_edge_function(
    'on_dispute_updated',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'booking_disputes',
      'schema', 'public',
      'record', to_jsonb(v_row),
      'old_record', null
    )
  );

  return v_row;
end;
$$;

revoke all on function public.open_booking_dispute(uuid, text, text) from public;
grant execute on function public.open_booking_dispute(uuid, text, text) to authenticated;

create or replace function public.resolve_booking_dispute(
  p_dispute_id uuid,
  p_status text,
  p_admin_notes text default null,
  p_resolution text default null
)
returns public.booking_disputes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.booking_disputes;
  v_old public.booking_disputes;
begin
  if not public.is_admin_user() then
    raise exception 'forbidden' using errcode = 'P0001';
  end if;

  if p_status not in (
    'under_review',
    'resolved_favor_client',
    'resolved_favor_presta',
    'closed'
  ) then
    raise exception 'invalid_dispute_status' using errcode = 'P0001';
  end if;

  select * into v_old from public.booking_disputes where id = p_dispute_id for update;
  if not found then
    raise exception 'dispute_not_found' using errcode = 'P0001';
  end if;

  update public.booking_disputes
  set
    status = p_status,
    admin_notes = coalesce(nullif(trim(p_admin_notes), ''), admin_notes),
    resolution = coalesce(nullif(trim(p_resolution), ''), resolution),
    updated_at = now(),
    resolved_at = case
      when p_status in ('resolved_favor_client', 'resolved_favor_presta', 'closed')
        then now()
      else resolved_at
    end,
    resolved_by = case
      when p_status in ('resolved_favor_client', 'resolved_favor_presta', 'closed')
        then auth.uid()
      else resolved_by
    end
  where id = p_dispute_id
  returning * into v_row;

  perform private.notify_edge_function(
    'on_dispute_updated',
    jsonb_build_object(
      'type', 'UPDATE',
      'table', 'booking_disputes',
      'schema', 'public',
      'record', to_jsonb(v_row),
      'old_record', to_jsonb(v_old)
    )
  );

  return v_row;
end;
$$;

revoke all on function public.resolve_booking_dispute(uuid, text, text, text) from public;
grant execute on function public.resolve_booking_dispute(uuid, text, text, text) to authenticated;
