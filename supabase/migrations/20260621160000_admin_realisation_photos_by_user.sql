-- Galerie admin : tri par prestataire pour regroupement côté app.

create or replace function public.admin_list_realisation_photos(
  p_limit integer default 200,
  p_offset integer default 0,
  p_search text default null
)
returns table (
  id uuid,
  prestataire_id uuid,
  prestataire_user_id uuid,
  prestataire_label text,
  owner_email text,
  url text,
  caption text,
  media_type text,
  created_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    pr.id,
    pr.prestataire_id,
    pp.user_id as prestataire_user_id,
    coalesce(
      nullif(trim(pp.nom_salon), ''),
      nullif(trim(concat_ws(' ', up.prenom, up.nom)), ''),
      'Prestataire'
    ) as prestataire_label,
    u.email::text as owner_email,
    pr.url,
    pr.caption,
    pr.media_type,
    pr.created_at
  from public.photos_realisation pr
  inner join public.prestataire_profiles pp on pp.id = pr.prestataire_id
  inner join public.user_profiles up on up.user_id = pp.user_id
  left join auth.users u on u.id = pp.user_id
  where public.is_admin_user(auth.uid())
    and (
      p_search is null
      or trim(p_search) = ''
      or coalesce(pp.nom_salon, '') ilike '%' || trim(p_search) || '%'
      or coalesce(up.prenom, '') ilike '%' || trim(p_search) || '%'
      or coalesce(up.nom, '') ilike '%' || trim(p_search) || '%'
      or u.email ilike '%' || trim(p_search) || '%'
    )
  order by
    coalesce(
      nullif(trim(pp.nom_salon), ''),
      nullif(trim(concat_ws(' ', up.prenom, up.nom)), ''),
      'Prestataire'
    ) asc,
    pp.user_id asc,
    pr.created_at desc
  limit greatest(1, least(coalesce(p_limit, 200), 200))
  offset greatest(coalesce(p_offset, 0), 0);
$$;
