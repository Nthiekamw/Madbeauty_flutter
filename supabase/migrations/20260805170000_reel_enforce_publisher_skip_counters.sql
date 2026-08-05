-- Fix interactions Reel (like / commentaire / vues) :
-- le trigger reel_posts_enforce_publisher s'exécutait aussi sur les UPDATE
-- de compteurs (likes_count, comments_count, views_count) déclenchés par
-- des clients → exception « reel_posts: prestataire non propriétaire ».

create or replace function public.reel_posts_enforce_publisher()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Compteurs / timestamps mis à jour par triggers likes|comments|views :
  -- ne pas exiger que l'auteur de l'interaction soit le prestataire.
  if tg_op = 'UPDATE'
     and new.prestataire_id is not distinct from old.prestataire_id
     and new.status is not distinct from old.status
     and new.media_url is not distinct from old.media_url
     and new.media_type is not distinct from old.media_type
     and new.caption is not distinct from old.caption
  then
    return new;
  end if;

  if not exists (
    select 1
    from public.prestataire_profiles p
    where p.id = new.prestataire_id
      and p.user_id = auth.uid()
  ) then
    raise exception 'reel_posts: prestataire non propriétaire';
  end if;

  if new.status = 'published'
     and not public.prestataire_is_catalog_visible(new.prestataire_id) then
    raise exception 'reel_posts: prestataire non validé pour publier';
  end if;

  return new;
end;
$$;

comment on function public.reel_posts_enforce_publisher() is
  'Contrôle propriétaire + visibilité catalogue à la publication ; '
  'ignore les UPDATE de compteurs (likes/comments/views).';
