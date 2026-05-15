-- Bucket public pour les photos de réalisations des prestataires.
-- Les fichiers sont rangés sous "<prestataire_id>/..." et seuls les
-- propriétaires du profil prestataire peuvent écrire dans leur dossier.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'realisation-photos',
  'realisation-photos',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "realisation_photos_select_public"
on storage.objects;
drop policy if exists "realisation_photos_insert_own_prestataire"
on storage.objects;
drop policy if exists "realisation_photos_update_own_prestataire"
on storage.objects;
drop policy if exists "realisation_photos_delete_own_prestataire"
on storage.objects;

create policy "realisation_photos_select_public"
on storage.objects for select
to public
using (bucket_id = 'realisation-photos');

create policy "realisation_photos_insert_own_prestataire"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'realisation-photos'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
);

create policy "realisation_photos_update_own_prestataire"
on storage.objects for update
to authenticated
using (
  bucket_id = 'realisation-photos'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
)
with check (
  bucket_id = 'realisation-photos'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
);

create policy "realisation_photos_delete_own_prestataire"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'realisation-photos'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
);
