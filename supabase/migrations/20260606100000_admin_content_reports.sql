-- Back-office admin : liste et modération des signalements + colonnes de suivi.

alter table public.content_reports
  add column if not exists reviewed_at timestamptz,
  add column if not exists reviewed_by uuid references auth.users (id);

create index if not exists idx_content_reports_unreviewed
  on public.content_reports (created_at desc)
  where reviewed_at is null;

create or replace function public.admin_list_content_reports(
  p_only_pending boolean default true,
  p_limit integer default 100
)
returns table (
  id uuid,
  reporter_user_id uuid,
  reporter_email text,
  reporter_display_name text,
  target_type text,
  target_id text,
  target_label text,
  reason text,
  details text,
  created_at timestamptz,
  reviewed_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    cr.id,
    cr.reporter_user_id,
    u.email::text as reporter_email,
    trim(concat_ws(' ', up.prenom, up.nom)) as reporter_display_name,
    cr.target_type,
    cr.target_id,
    case cr.target_type
      when 'prestataire_profile' then coalesce(
        nullif(trim(pp.nom_salon), ''),
        trim(concat_ws(' ', tpp.prenom, tpp.nom)),
        cr.target_id
      )
      when 'conversation' then 'Conversation ' || left(cr.target_id, 8)
      when 'message' then 'Message ' || left(cr.target_id, 8)
      else cr.target_id
    end as target_label,
    cr.reason,
    cr.details,
    cr.created_at,
    cr.reviewed_at
  from public.content_reports cr
  left join auth.users u on u.id = cr.reporter_user_id
  left join public.user_profiles up on up.user_id = cr.reporter_user_id
  left join public.prestataire_profiles pp
    on cr.target_type = 'prestataire_profile'
    and pp.id::text = cr.target_id
  left join public.user_profiles tpp on tpp.user_id = pp.user_id
  where public.is_admin_user(auth.uid())
    and (not p_only_pending or cr.reviewed_at is null)
  order by cr.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

create or replace function public.admin_mark_content_report_reviewed(
  p_report_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden'
      using errcode = '42501';
  end if;

  update public.content_reports
  set reviewed_at = now(),
      reviewed_by = auth.uid()
  where id = p_report_id
    and reviewed_at is null;

  if not found then
    raise exception 'report_not_found_or_already_reviewed'
      using errcode = 'P0002';
  end if;
end;
$$;

comment on function public.admin_list_content_reports(boolean, integer) is
  'Liste des signalements pour les admins (e-mail signaleur, libellé cible).';

comment on function public.admin_mark_content_report_reviewed(uuid) is
  'Marque un signalement comme traité par l’admin connecté.';

grant execute on function public.admin_list_content_reports(boolean, integer)
to authenticated;
grant execute on function public.admin_mark_content_report_reviewed(uuid)
to authenticated;
