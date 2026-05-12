-- Données de dev (après `supabase db reset`).
-- Exécuté avec des droits superuser : les RLS sur categories_service n’empêchent pas le seed.

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

-- Exemple : créer un profil client pour l’utilisateur de test (remplacer l’UUID par auth.users.id réel).
-- insert into public.client_profiles (user_id) values ('<USER_UUID>');

-- Exemple : créer un profil prestataire géolocalisé (remplacer user_id par un UUID réel `auth.users`).
-- insert into public.prestataire_profiles (user_id, nom_salon, ville, latitude, longitude, note_moyenne)
-- values ('<USER_UUID>', 'Salon démo', 'Montreuil', 48.8534, 2.4488, 4.6);

