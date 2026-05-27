-- Lie chaque conversation à une réservation (un fil par RDV).

alter table public.conversations
  add column if not exists reservation_id uuid references public.reservations (id) on delete cascade;

alter table public.conversations
  drop constraint if exists conversations_client_prestataire_key;

create unique index if not exists conversations_reservation_id_uidx
  on public.conversations (reservation_id)
  where reservation_id is not null;

create index if not exists idx_conversations_client_last
  on public.conversations (client_id, last_message_at desc nulls last);

create index if not exists idx_conversations_prestataire_last
  on public.conversations (prestataire_id, last_message_at desc nulls last);
