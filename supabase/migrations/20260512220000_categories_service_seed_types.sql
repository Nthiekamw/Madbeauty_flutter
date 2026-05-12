-- Catégories : coiffure (dont tresses, locks, soins, coupe) + manucure, pédicure, maquillage.
insert into public.categories_service (id, nom, icone)
values
  ('a0000001-0001-4000-8000-000000000001', 'Coiffure afro', 'hair'),
  ('a0000001-0001-4000-8000-000000000002', 'Manucure', 'nails'),
  ('a0000001-0001-4000-8000-000000000003', 'Maquillage', 'face'),
  ('a0000001-0001-4000-8000-000000000004', 'Pédicure', 'spa'),
  ('a0000001-0001-4000-8000-000000000005', 'Coupe', 'hair'),
  ('a0000001-0001-4000-8000-000000000006', 'Locks', 'hair'),
  ('a0000001-0001-4000-8000-000000000007', 'Soin capillaire', 'hair'),
  ('a0000001-0001-4000-8000-000000000008', 'Tresses', 'hair')
on conflict (id) do nothing;
