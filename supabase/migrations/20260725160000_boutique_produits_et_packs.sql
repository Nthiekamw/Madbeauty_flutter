-- Boutique produits + packs/offres (services et/ou produits).
-- Le prestataire crée des packs composés : 2+ services, 2+ produits, ou mixte.

-- ---------------------------------------------------------------------------
-- Produits boutique
-- ---------------------------------------------------------------------------

create table public.produits_boutique (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  nom text not null,
  description text,
  conditionnement text,
  categorie text not null default 'autre',
  prix numeric(12, 2) not null default 0,
  image_url text,
  is_actif boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint produits_boutique_nom_len check (
    char_length(trim(nom)) between 1 and 120
  ),
  constraint produits_boutique_prix_nonneg check (prix >= 0),
  constraint produits_boutique_categorie_check check (
    categorie in ('cheveux', 'visage', 'corps', 'accessoires', 'autre')
  )
);

create index idx_produits_boutique_prestataire
  on public.produits_boutique (prestataire_id, is_actif);

create index idx_produits_boutique_categorie
  on public.produits_boutique (prestataire_id, categorie)
  where is_actif;

comment on table public.produits_boutique is
  'Produits physiques vendus par un prestataire (onglet Boutique).';

comment on column public.produits_boutique.conditionnement is
  'Conditionnement affiché (ex. 250 ml, 1 pièce).';

-- ---------------------------------------------------------------------------
-- Packs / offres
-- ---------------------------------------------------------------------------

create table public.packs_offre (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  titre text not null,
  description text,
  image_url text,
  prix_pack numeric(12, 2) not null,
  is_offre_du_jour boolean not null default false,
  -- Brouillon jusqu’à composition (≥ 2 items) puis activation explicite.
  is_actif boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint packs_offre_titre_len check (
    char_length(trim(titre)) between 1 and 120
  ),
  constraint packs_offre_prix_nonneg check (prix_pack >= 0),
  constraint packs_offre_dates_check check (
    ends_at is null or starts_at is null or ends_at > starts_at
  )
);

create index idx_packs_offre_prestataire
  on public.packs_offre (prestataire_id, is_actif);

create index idx_packs_offre_promo
  on public.packs_offre (prestataire_id, is_offre_du_jour)
  where is_actif and is_offre_du_jour;

comment on table public.packs_offre is
  'Packs / offres créés par le prestataire (services et/ou produits boutique).';

create table public.pack_items (
  id uuid primary key default gen_random_uuid(),
  pack_id uuid not null references public.packs_offre (id) on delete cascade,
  item_type text not null,
  service_id uuid references public.services_beaute (id) on delete restrict,
  produit_id uuid references public.produits_boutique (id) on delete restrict,
  quantite integer not null default 1,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint pack_items_type_check check (item_type in ('service', 'produit')),
  constraint pack_items_quantite_pos check (quantite > 0),
  constraint pack_items_ref_check check (
    (
      item_type = 'service'
      and service_id is not null
      and produit_id is null
    )
    or (
      item_type = 'produit'
      and produit_id is not null
      and service_id is null
    )
  ),
  constraint pack_items_unique_service unique (pack_id, service_id),
  constraint pack_items_unique_produit unique (pack_id, produit_id)
);

create index idx_pack_items_pack
  on public.pack_items (pack_id, sort_order);

comment on table public.pack_items is
  'Lignes d’un pack : service beauté ou produit boutique.';

-- Empêche d’activer un pack avec moins de 2 items (après composition).
create or replace function public.packs_offre_require_min_items()
returns trigger
language plpgsql
as $$
declare
  v_count integer;
begin
  -- À l’INSERT : on laisse créer le brouillon ; l’activation se valide ensuite.
  if tg_op = 'INSERT' then
    return new;
  end if;

  if new.is_actif then
    select count(*)::integer into v_count
    from public.pack_items
    where pack_id = new.id;
    if coalesce(v_count, 0) < 2 then
      raise exception
        'Un pack actif doit contenir au moins 2 éléments (services et/ou produits).';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_packs_offre_require_min_items
before insert or update of is_actif on public.packs_offre
for each row
execute function public.packs_offre_require_min_items();

-- Désactive le pack si un retrait d’item le laisse sous le seuil.
create or replace function public.pack_items_enforce_min_on_delete()
returns trigger
language plpgsql
as $$
declare
  v_count integer;
begin
  select count(*)::integer into v_count
  from public.pack_items
  where pack_id = old.pack_id;

  if coalesce(v_count, 0) < 2 then
    update public.packs_offre
    set is_actif = false
    where id = old.pack_id
      and is_actif = true;
  end if;

  return old;
end;
$$;

create trigger trg_pack_items_enforce_min_on_delete
after delete on public.pack_items
for each row
execute function public.pack_items_enforce_min_on_delete();

-- Les items d’un pack doivent appartenir au même prestataire.
create or replace function public.pack_items_same_prestataire()
returns trigger
language plpgsql
as $$
declare
  v_pack_prestataire uuid;
  v_item_prestataire uuid;
begin
  select prestataire_id into v_pack_prestataire
  from public.packs_offre
  where id = new.pack_id;

  if new.item_type = 'service' then
    select prestataire_id into v_item_prestataire
    from public.services_beaute
    where id = new.service_id;
  else
    select prestataire_id into v_item_prestataire
    from public.produits_boutique
    where id = new.produit_id;
  end if;

  if v_pack_prestataire is null or v_item_prestataire is null
     or v_pack_prestataire <> v_item_prestataire then
    raise exception
      'Les éléments d’un pack doivent appartenir au même prestataire.';
  end if;

  return new;
end;
$$;

create trigger trg_pack_items_same_prestataire
before insert or update on public.pack_items
for each row
execute function public.pack_items_same_prestataire();

-- updated_at
create or replace function public.set_updated_at_boutique()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_produits_boutique_updated_at
before update on public.produits_boutique
for each row
execute function public.set_updated_at_boutique();

create trigger trg_packs_offre_updated_at
before update on public.packs_offre
for each row
execute function public.set_updated_at_boutique();

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.produits_boutique enable row level security;
alter table public.packs_offre enable row level security;
alter table public.pack_items enable row level security;

-- Produits : lecture publique si catalogue visible + actif
create policy "produits_boutique_select_anon"
on public.produits_boutique for select to anon
using (
  coalesce(is_actif, true)
  and public.prestataire_is_catalog_visible(prestataire_id)
);

create policy "produits_boutique_select_authenticated"
on public.produits_boutique for select to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = produits_boutique.prestataire_id
      and (
        p.user_id = auth.uid()
        or (
          coalesce(produits_boutique.is_actif, true)
          and public.prestataire_is_catalog_visible(p.id)
        )
      )
  )
);

create policy "produits_boutique_write_own"
on public.produits_boutique for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = produits_boutique.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = produits_boutique.prestataire_id
      and p.user_id = auth.uid()
  )
);

-- Packs
create policy "packs_offre_select_anon"
on public.packs_offre for select to anon
using (
  coalesce(is_actif, true)
  and public.prestataire_is_catalog_visible(prestataire_id)
  and (starts_at is null or starts_at <= now())
  and (ends_at is null or ends_at >= now())
);

create policy "packs_offre_select_authenticated"
on public.packs_offre for select to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = packs_offre.prestataire_id
      and (
        p.user_id = auth.uid()
        or (
          coalesce(packs_offre.is_actif, true)
          and public.prestataire_is_catalog_visible(p.id)
          and (packs_offre.starts_at is null or packs_offre.starts_at <= now())
          and (packs_offre.ends_at is null or packs_offre.ends_at >= now())
        )
      )
  )
);

create policy "packs_offre_write_own"
on public.packs_offre for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = packs_offre.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = packs_offre.prestataire_id
      and p.user_id = auth.uid()
  )
);

-- Pack items : lecture si pack lisible ; écriture si propriétaire du pack
create policy "pack_items_select_anon"
on public.pack_items for select to anon
using (
  exists (
    select 1 from public.packs_offre po
    where po.id = pack_items.pack_id
      and coalesce(po.is_actif, true)
      and public.prestataire_is_catalog_visible(po.prestataire_id)
      and (po.starts_at is null or po.starts_at <= now())
      and (po.ends_at is null or po.ends_at >= now())
  )
);

create policy "pack_items_select_authenticated"
on public.pack_items for select to authenticated
using (
  exists (
    select 1
    from public.packs_offre po
    join public.prestataire_profiles p on p.id = po.prestataire_id
    where po.id = pack_items.pack_id
      and (
        p.user_id = auth.uid()
        or (
          coalesce(po.is_actif, true)
          and public.prestataire_is_catalog_visible(p.id)
          and (po.starts_at is null or po.starts_at <= now())
          and (po.ends_at is null or po.ends_at >= now())
        )
      )
  )
);

create policy "pack_items_write_own"
on public.pack_items for all to authenticated
using (
  exists (
    select 1
    from public.packs_offre po
    join public.prestataire_profiles p on p.id = po.prestataire_id
    where po.id = pack_items.pack_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.packs_offre po
    join public.prestataire_profiles p on p.id = po.prestataire_id
    where po.id = pack_items.pack_id
      and p.user_id = auth.uid()
  )
);
