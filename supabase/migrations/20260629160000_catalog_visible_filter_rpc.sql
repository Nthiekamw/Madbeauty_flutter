-- Filtre catalogue fiable côté client : RPC security definer + backfill is_hidden.

create or replace function public.filter_catalog_visible_prestataire_ids(p_ids uuid[])
returns uuid[]
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    array_agg(id order by ord),
    '{}'::uuid[]
  )
  from (
    select t.id, t.ord
    from unnest(p_ids) with ordinality as t(id, ord)
    where public.prestataire_is_catalog_visible(t.id)
  ) visible;
$$;

comment on function public.filter_catalog_visible_prestataire_ids(uuid[]) is
  'Retourne les ids prestataire visibles catalogue (abonnement, non banni, non masqué).';

grant execute on function public.filter_catalog_visible_prestataire_ids(uuid[]) to anon, authenticated;

-- Prestataires déjà bannis avant la mise à jour admin_ban_user : masquer le profil catalogue.
update public.prestataire_profiles p
set is_hidden = true
from public.user_profiles up
where up.user_id = p.user_id
  and coalesce(up.is_banned, false) = true
  and coalesce(p.is_hidden, false) = false;

create or replace function public.admin_unban_user(
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  update public.user_profiles
  set is_banned = false,
      banned_at = null,
      banned_by = null,
      ban_reason = null
  where user_id = p_user_id;

  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;

  update public.prestataire_profiles
  set is_hidden = false
  where user_id = p_user_id;

  perform public.admin_write_audit_log(
    'unban_user',
    'user',
    p_user_id::text,
    jsonb_build_object('catalog_hidden', false)
  );
end;
$$;
