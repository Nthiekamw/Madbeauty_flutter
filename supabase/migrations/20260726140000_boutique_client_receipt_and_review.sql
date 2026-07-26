-- Client confirme réception commande boutique + avis produits (1 avis / commande).

-- ---------------------------------------------------------------------------
-- 1) RPC : client confirme réception (ready → completed)
-- ---------------------------------------------------------------------------
create or replace function public.client_confirm_boutique_receipt(p_commande_id uuid)
returns public.boutique_commandes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_client_id uuid;
  v_row public.boutique_commandes;
begin
  if v_uid is null then
    raise exception 'Non authentifié.';
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = v_uid
  limit 1;

  if v_client_id is null then
    raise exception 'Profil client introuvable.';
  end if;

  select * into v_row
  from public.boutique_commandes bc
  where bc.id = p_commande_id
  for update;

  if not found then
    raise exception 'Commande introuvable.';
  end if;

  if v_row.client_id <> v_client_id then
    raise exception 'Tu ne peux confirmer que tes propres commandes.';
  end if;

  if v_row.statut = 'completed' then
    return v_row;
  end if;

  if v_row.statut <> 'ready' then
    raise exception 'La commande doit être prête avant confirmation de réception.';
  end if;

  update public.boutique_commandes
  set
    statut = 'completed',
    payment_status = 'paid',
    paid_at = coalesce(paid_at, now()),
    updated_at = now()
  where id = p_commande_id
  returning * into v_row;

  return v_row;
end;
$$;

revoke all on function public.client_confirm_boutique_receipt(uuid) from public;
grant execute on function public.client_confirm_boutique_receipt(uuid) to authenticated;

comment on function public.client_confirm_boutique_receipt(uuid) is
  'Client : confirme réception produit (ready → completed). Idempotent si déjà completed.';

-- ---------------------------------------------------------------------------
-- 2) Table avis_boutique (1 avis par commande)
-- ---------------------------------------------------------------------------
create table if not exists public.avis_boutique (
  id uuid primary key default gen_random_uuid(),
  commande_id uuid not null references public.boutique_commandes (id) on delete cascade,
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  note integer not null check (note between 1 and 5),
  commentaire text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint avis_boutique_commande_id_key unique (commande_id)
);

create index if not exists avis_boutique_prestataire_created_idx
  on public.avis_boutique (prestataire_id, created_at desc);

create index if not exists avis_boutique_client_created_idx
  on public.avis_boutique (client_id, created_at desc);

comment on table public.avis_boutique is
  'Avis client après confirmation de réception d’une commande boutique.';

create or replace function public.set_updated_at_avis_boutique()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_avis_boutique_updated_at on public.avis_boutique;
create trigger trg_avis_boutique_updated_at
before update on public.avis_boutique
for each row
execute function public.set_updated_at_avis_boutique();

create or replace function public.avis_boutique_check_before_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cmd public.boutique_commandes;
begin
  select * into v_cmd
  from public.boutique_commandes
  where id = new.commande_id;

  if not found then
    raise exception 'Commande introuvable.';
  end if;

  if v_cmd.statut <> 'completed' then
    raise exception 'La commande doit être terminée (réception confirmée) pour laisser un avis.';
  end if;

  if v_cmd.client_id <> new.client_id then
    raise exception 'Seul le client de la commande peut laisser un avis.';
  end if;

  new.prestataire_id := v_cmd.prestataire_id;
  return new;
end;
$$;

drop trigger if exists trg_avis_boutique_check_before_insert on public.avis_boutique;
create trigger trg_avis_boutique_check_before_insert
before insert on public.avis_boutique
for each row
execute function public.avis_boutique_check_before_insert();

alter table public.avis_boutique enable row level security;

drop policy if exists "avis_boutique_select_authenticated" on public.avis_boutique;
create policy "avis_boutique_select_authenticated"
on public.avis_boutique for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = avis_boutique.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = avis_boutique.prestataire_id and p.user_id = auth.uid()
  )
);

drop policy if exists "avis_boutique_select_anon" on public.avis_boutique;
create policy "avis_boutique_select_anon"
on public.avis_boutique for select to anon
using (true);

drop policy if exists "avis_boutique_insert_own_client" on public.avis_boutique;
create policy "avis_boutique_insert_own_client"
on public.avis_boutique for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = avis_boutique.client_id and c.user_id = auth.uid()
  )
);

-- ---------------------------------------------------------------------------
-- 3) RPC création avis boutique (garde-fous + client_id auto)
-- ---------------------------------------------------------------------------
create or replace function public.create_avis_boutique(p_payload jsonb)
returns public.avis_boutique
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_client_id uuid;
  v_commande_id uuid;
  v_prestataire_id uuid;
  v_note integer;
  v_commentaire text;
  v_statut text;
  v_row public.avis_boutique;
begin
  if v_uid is null then
    raise exception 'Non authentifié.';
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = v_uid
  limit 1;

  if v_client_id is null then
    raise exception 'Profil client introuvable.';
  end if;

  v_commande_id := nullif(trim(coalesce(p_payload->>'commande_id', '')), '')::uuid;
  v_note := (p_payload->>'note')::integer;
  v_commentaire := nullif(trim(coalesce(p_payload->>'commentaire', '')), '');

  if v_commande_id is null then
    raise exception 'commande_id requis.';
  end if;

  if v_note is null or v_note < 1 or v_note > 5 then
    raise exception 'La note doit être entre 1 et 5.';
  end if;

  select bc.prestataire_id, bc.statut
  into v_prestataire_id, v_statut
  from public.boutique_commandes bc
  where bc.id = v_commande_id
    and bc.client_id = v_client_id;

  if v_prestataire_id is null then
    raise exception 'Commande introuvable.';
  end if;

  if v_statut <> 'completed' then
    raise exception 'La commande doit être terminée (réception confirmée) pour laisser un avis.';
  end if;

  insert into public.avis_boutique (
    commande_id,
    client_id,
    prestataire_id,
    note,
    commentaire
  )
  values (
    v_commande_id,
    v_client_id,
    v_prestataire_id,
    v_note,
    v_commentaire
  )
  returning * into v_row;

  return v_row;
end;
$$;

revoke all on function public.create_avis_boutique(jsonb) from public;
grant execute on function public.create_avis_boutique(jsonb) to authenticated;

comment on function public.create_avis_boutique(jsonb) is
  'Client : publie un avis boutique après réception confirmée (1 avis / commande).';
