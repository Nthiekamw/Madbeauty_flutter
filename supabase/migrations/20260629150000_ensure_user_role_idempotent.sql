-- Attribution idempotente d'un rôle (inscription, save profil prestataire, etc.).

create or replace function public.ensure_user_role(p_role public.app_role)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Utilisateur non connecté';
  end if;

  insert into public.user_roles (user_id, role)
  values (v_uid, p_role)
  on conflict (user_id, role) do nothing;
end;
$$;

grant execute on function public.ensure_user_role(public.app_role) to authenticated;
