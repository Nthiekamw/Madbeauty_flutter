-- MadBeauty — schéma métier (profils client/prestataire, catalogue, réservations, avis, messagerie).
-- Prérequis : 20260508113500_auth_profiles_and_roles (app_role, user_roles, trigger auth).
-- Remplace public.profiles par public.user_profiles (colonnes alignées avec les modèles Dart).

-- ---------------------------------------------------------------------------
-- 1) user_profiles (USER_PROFILES) + migration depuis l’ancienne table profiles
-- ---------------------------------------------------------------------------

create table public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  nom text,
  prenom text,
  avatar_url text,
  telephone text,
  updated_at timestamptz not null default now(),
  constraint user_profiles_user_id_key unique (user_id)
);

create trigger trg_user_profiles_updated_at
before update on public.user_profiles
for each row
execute procedure public.set_updated_at();

insert into public.user_profiles (user_id, nom, prenom, updated_at)
select
  p.user_id,
  p.full_name,
  null::text,
  p.updated_at
from public.profiles p;

drop trigger if exists trg_profiles_updated_at on public.profiles;

drop table public.profiles;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_profiles (user_id, nom, prenom, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', null),
    null,
    now()
  )
  on conflict (user_id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, 'client')
  on conflict (user_id, role) do nothing;

  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 2) Profils client / prestataire
-- ---------------------------------------------------------------------------

create table public.client_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  adresse text,
  created_at timestamptz not null default now(),
  constraint client_profiles_user_id_key unique (user_id)
);

create table public.prestataire_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  nom_salon text,
  bio text,
  ville text,
  latitude double precision,
  longitude double precision,
  note_moyenne double precision,
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  constraint prestataire_profiles_user_id_key unique (user_id)
);

create index idx_prestataire_profiles_ville on public.prestataire_profiles (ville);

-- ---------------------------------------------------------------------------
-- 3) Catalogue
-- ---------------------------------------------------------------------------

create table public.categories_service (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  icone text
);

create table public.prestataire_specialites (
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  categorie_id uuid not null references public.categories_service (id) on delete cascade,
  primary key (prestataire_id, categorie_id)
);

create table public.services_beaute (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  nom text not null,
  duree_minutes integer not null check (duree_minutes > 0),
  prix numeric(12, 2) not null check (prix >= 0),
  is_actif boolean not null default true
);

create index idx_services_beaute_prestataire on public.services_beaute (prestataire_id);

-- ---------------------------------------------------------------------------
-- 4) Réservations & avis & portfolio & favoris
-- ---------------------------------------------------------------------------

create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  service_id uuid not null references public.services_beaute (id) on delete restrict,
  date_heure timestamptz not null,
  statut text not null default 'en_attente',
  notes_client text,
  created_at timestamptz not null default now()
);

create index idx_reservations_date on public.reservations (date_heure);
create index idx_reservations_client on public.reservations (client_id);
create index idx_reservations_prestataire on public.reservations (prestataire_id);

create table public.avis (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  reservation_id uuid not null references public.reservations (id) on delete cascade,
  note integer not null check (note >= 1 and note <= 5),
  commentaire text,
  created_at timestamptz not null default now(),
  constraint avis_reservation_id_key unique (reservation_id)
);

create table public.photos_realisation (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  url text not null,
  caption text,
  categorie_id uuid references public.categories_service (id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.favoris (
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (client_id, prestataire_id)
);

-- ---------------------------------------------------------------------------
-- 5) Messagerie
-- ---------------------------------------------------------------------------

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  last_message_at timestamptz,
  constraint conversations_client_prestataire_key unique (client_id, prestataire_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  contenu text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_messages_conversation on public.messages (conversation_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 6) RLS
-- ---------------------------------------------------------------------------

alter table public.user_profiles enable row level security;
alter table public.client_profiles enable row level security;
alter table public.prestataire_profiles enable row level security;
alter table public.categories_service enable row level security;
alter table public.prestataire_specialites enable row level security;
alter table public.services_beaute enable row level security;
alter table public.reservations enable row level security;
alter table public.avis enable row level security;
alter table public.photos_realisation enable row level security;
alter table public.favoris enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

-- user_profiles (remplace les anciennes policies "profiles_*")
create policy "user_profiles_select_own"
on public.user_profiles for select to authenticated
using (auth.uid() = user_id);

create policy "user_profiles_insert_own"
on public.user_profiles for insert to authenticated
with check (auth.uid() = user_id);

create policy "user_profiles_update_own"
on public.user_profiles for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- client_profiles
create policy "client_profiles_select_own"
on public.client_profiles for select to authenticated
using (auth.uid() = user_id);

create policy "client_profiles_insert_own"
on public.client_profiles for insert to authenticated
with check (auth.uid() = user_id);

create policy "client_profiles_update_own"
on public.client_profiles for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- prestataire_profiles : lecture pour utilisateurs connectés (recherche / fiches)
create policy "prestataire_profiles_select_authenticated"
on public.prestataire_profiles for select to authenticated
using (true);

create policy "prestataire_profiles_insert_own"
on public.prestataire_profiles for insert to authenticated
with check (auth.uid() = user_id);

create policy "prestataire_profiles_update_own"
on public.prestataire_profiles for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- categories : lecture large ; écriture réservée au service_role (seed / admin backend)
create policy "categories_service_select_authenticated"
on public.categories_service for select to authenticated
using (true);

create policy "categories_service_all_service_role"
on public.categories_service for all to service_role
using (true)
with check (true);

-- prestataire_specialites
create policy "prestataire_specialites_select_authenticated"
on public.prestataire_specialites for select to authenticated
using (true);

create policy "prestataire_specialites_write_own"
on public.prestataire_specialites for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = prestataire_specialites.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = prestataire_specialites.prestataire_id
      and p.user_id = auth.uid()
  )
);

-- services_beaute
create policy "services_beaute_select_authenticated"
on public.services_beaute for select to authenticated
using (true);

create policy "services_beaute_write_own"
on public.services_beaute for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = services_beaute.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = services_beaute.prestataire_id
      and p.user_id = auth.uid()
  )
);

-- reservations
create policy "reservations_select_participant"
on public.reservations for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = reservations.prestataire_id and p.user_id = auth.uid()
  )
);

create policy "reservations_insert_client"
on public.reservations for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id and c.user_id = auth.uid()
  )
);

create policy "reservations_update_participant"
on public.reservations for update to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = reservations.prestataire_id and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reservations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = reservations.prestataire_id and p.user_id = auth.uid()
  )
);

-- avis
create policy "avis_select_authenticated"
on public.avis for select to authenticated
using (true);

create policy "avis_insert_own_client"
on public.avis for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = avis.client_id and c.user_id = auth.uid()
  )
);

-- photos_realisation
create policy "photos_realisation_select_authenticated"
on public.photos_realisation for select to authenticated
using (true);

create policy "photos_realisation_write_own"
on public.photos_realisation for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = photos_realisation.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = photos_realisation.prestataire_id
      and p.user_id = auth.uid()
  )
);

-- favoris
create policy "favoris_select_own"
on public.favoris for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = favoris.client_id and c.user_id = auth.uid()
  )
);

create policy "favoris_write_own"
on public.favoris for all to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = favoris.client_id and c.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = favoris.client_id and c.user_id = auth.uid()
  )
);

-- conversations
create policy "conversations_select_participant"
on public.conversations for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = conversations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = conversations.prestataire_id and p.user_id = auth.uid()
  )
);

create policy "conversations_insert_participant"
on public.conversations for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = conversations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = conversations.prestataire_id and p.user_id = auth.uid()
  )
);

create policy "conversations_update_participant"
on public.conversations for update to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = conversations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = conversations.prestataire_id and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = conversations.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = conversations.prestataire_id and p.user_id = auth.uid()
  )
);

-- messages
create policy "messages_select_participant"
on public.messages for select to authenticated
using (
  exists (
    select 1 from public.conversations conv
    join public.client_profiles c on c.id = conv.client_id
    where conv.id = messages.conversation_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.conversations conv
    join public.prestataire_profiles p on p.id = conv.prestataire_id
    where conv.id = messages.conversation_id
      and p.user_id = auth.uid()
  )
);

create policy "messages_insert_sender"
on public.messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and (
    exists (
      select 1 from public.conversations conv
      join public.client_profiles c on c.id = conv.client_id
      where conv.id = messages.conversation_id
        and c.user_id = auth.uid()
    )
    or exists (
      select 1 from public.conversations conv
      join public.prestataire_profiles p on p.id = conv.prestataire_id
      where conv.id = messages.conversation_id
        and p.user_id = auth.uid()
    )
  )
);

create policy "messages_update_participant"
on public.messages for update to authenticated
using (
  exists (
    select 1 from public.conversations conv
    join public.client_profiles c on c.id = conv.client_id
    where conv.id = messages.conversation_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.conversations conv
    join public.prestataire_profiles p on p.id = conv.prestataire_id
    where conv.id = messages.conversation_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.conversations conv
    join public.client_profiles c on c.id = conv.client_id
    where conv.id = messages.conversation_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.conversations conv
    join public.prestataire_profiles p on p.id = conv.prestataire_id
    where conv.id = messages.conversation_id
      and p.user_id = auth.uid()
  )
);
