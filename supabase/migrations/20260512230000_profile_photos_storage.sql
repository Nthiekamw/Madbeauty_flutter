-- Bucket public pour les photos de profil prestataire/client.
-- Les fichiers sont rangés sous "<auth.uid()>/..." pour autoriser chaque user
-- à écrire uniquement dans son dossier.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-photos',
  'profile-photos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "profile_photos_select_public"
on storage.objects;
drop policy if exists "profile_photos_insert_own_folder"
on storage.objects;
drop policy if exists "profile_photos_update_own_folder"
on storage.objects;
drop policy if exists "profile_photos_delete_own_folder"
on storage.objects;

create policy "profile_photos_select_public"
on storage.objects for select
to public
using (bucket_id = 'profile-photos');

create policy "profile_photos_insert_own_folder"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "profile_photos_update_own_folder"
on storage.objects for update
to authenticated
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "profile_photos_delete_own_folder"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
