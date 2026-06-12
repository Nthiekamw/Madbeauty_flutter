-- Vidéos dans les réalisations prestataire (galerie profil + fiche publique).

alter table public.photos_realisation
  add column if not exists media_type text not null default 'image';

alter table public.photos_realisation
  drop constraint if exists photos_realisation_media_type_check;

alter table public.photos_realisation
  add constraint photos_realisation_media_type_check
  check (media_type in ('image', 'video'));

comment on column public.photos_realisation.media_type is
  'Type de média : image ou video.';

-- Étend le bucket existant (images + vidéos, max 50 Mo).
update storage.buckets
set
  file_size_limit = 52428800,
  allowed_mime_types = array[
    'image/jpeg',
    'image/png',
    'image/webp',
    'video/mp4',
    'video/quicktime',
    'video/webm'
  ]
where id = 'realisation-photos';
