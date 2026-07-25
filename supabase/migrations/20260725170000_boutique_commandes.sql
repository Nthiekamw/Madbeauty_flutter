-- Commandes boutique (produits) — panier client → commande → paiement Stripe (Web) ou sur place.

create table public.boutique_commandes (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete restrict,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete restrict,
  statut text not null default 'pending_payment',
  payment_status text not null default 'unpaid',
  amount_cents integer not null,
  currency text not null default 'eur',
  stripe_payment_intent_id text unique,
  fulfillment text not null default 'pickup',
  notes_client text,
  created_at timestamptz not null default now(),
  paid_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint boutique_commandes_statut_check check (
    statut in (
      'pending_payment',
      'paid',
      'preparing',
      'ready',
      'completed',
      'canceled',
      'pay_on_site'
    )
  ),
  constraint boutique_commandes_payment_status_check check (
    payment_status in ('unpaid', 'pending', 'paid', 'failed', 'refunded')
  ),
  constraint boutique_commandes_fulfillment_check check (
    fulfillment in ('pickup', 'hand_delivery')
  ),
  constraint boutique_commandes_amount_pos check (amount_cents > 0)
);

create index idx_boutique_commandes_client
  on public.boutique_commandes (client_id, created_at desc);

create index idx_boutique_commandes_prestataire
  on public.boutique_commandes (prestataire_id, created_at desc);

create table public.boutique_commande_items (
  id uuid primary key default gen_random_uuid(),
  commande_id uuid not null references public.boutique_commandes (id) on delete cascade,
  produit_id uuid references public.produits_boutique (id) on delete set null,
  nom_snapshot text not null,
  conditionnement_snapshot text,
  prix_cents integer not null,
  quantite integer not null default 1,
  created_at timestamptz not null default now(),
  constraint boutique_commande_items_qty_pos check (quantite > 0),
  constraint boutique_commande_items_prix_nonneg check (prix_cents >= 0)
);

create index idx_boutique_commande_items_commande
  on public.boutique_commande_items (commande_id);

comment on table public.boutique_commandes is
  'Commandes de produits boutique (paiement Stripe Web ou à régler sur place).';

create or replace function public.set_updated_at_boutique_commandes()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_boutique_commandes_updated_at
before update on public.boutique_commandes
for each row
execute function public.set_updated_at_boutique_commandes();

alter table public.boutique_commandes enable row level security;
alter table public.boutique_commande_items enable row level security;

-- Client : ses commandes
create policy "boutique_commandes_select_own_client"
on public.boutique_commandes for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = boutique_commandes.client_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = boutique_commandes.prestataire_id
      and p.user_id = auth.uid()
  )
);

create policy "boutique_commandes_insert_own_client"
on public.boutique_commandes for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = boutique_commandes.client_id
      and c.user_id = auth.uid()
  )
);

create policy "boutique_commandes_update_own_or_presta"
on public.boutique_commandes for update to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = boutique_commandes.client_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = boutique_commandes.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = boutique_commandes.client_id
      and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = boutique_commandes.prestataire_id
      and p.user_id = auth.uid()
  )
);

create policy "boutique_commande_items_select_participant"
on public.boutique_commande_items for select to authenticated
using (
  exists (
    select 1
    from public.boutique_commandes bc
    join public.client_profiles c on c.id = bc.client_id
    left join public.prestataire_profiles p on p.id = bc.prestataire_id
    where bc.id = boutique_commande_items.commande_id
      and (c.user_id = auth.uid() or p.user_id = auth.uid())
  )
);

create policy "boutique_commande_items_insert_own_client"
on public.boutique_commande_items for insert to authenticated
with check (
  exists (
    select 1
    from public.boutique_commandes bc
    join public.client_profiles c on c.id = bc.client_id
    where bc.id = boutique_commande_items.commande_id
      and c.user_id = auth.uid()
  )
);
