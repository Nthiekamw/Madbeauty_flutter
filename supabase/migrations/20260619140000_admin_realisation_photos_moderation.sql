-- Modération admin des photos / vidéos de réalisations prestataires.

-- ---------------------------------------------------------------------------
-- 1) Signalements : cible photo de réalisation
-- ---------------------------------------------------------------------------
alter table public.content_reports
  drop constraint if exists content_reports_target_type_check;

alter table public.content_reports
  add constraint content_reports_target_type_check
  check (target_type in (
    'prestataire_profile',
    'conversation',
    'message',
    'realisation_photo'
  ));

-- ---------------------------------------------------------------------------
-- 2) Événements de modération (avertissements visibles par l'utilisateur)
-- ---------------------------------------------------------------------------
create table if not exists public.account_moderation_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  admin_user_id uuid not null references auth.users (id),
  event_type text not null,
  photo_id uuid references public.photos_realisation (id) on delete set null,
  message text not null,
  created_at timestamptz not null default now(),
  constraint account_moderation_events_type_check
    check (event_type in (
      'photo_removed',
      'photo_obscene_flagged',
      'account_warned'
    ))
);

create index if not exists idx_account_moderation_events_user_created
  on public.account_moderation_events (user_id, created_at desc);

comment on table public.account_moderation_events is
  'Historique modération (avertissements, retraits photo) visible par l’utilisateur concerné.';

alter table public.account_moderation_events enable row level security;

drop policy if exists "account_moderation_events_select_own"
  on public.account_moderation_events;
create policy "account_moderation_events_select_own"
  on public.account_moderation_events for select to authenticated
  using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 3) Storage : suppression admin
-- ---------------------------------------------------------------------------
drop policy if exists "realisation_photos_delete_admin"
  on storage.objects;
create policy "realisation_photos_delete_admin"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'realisation-photos'
    and public.is_admin_user(auth.uid())
  );

-- ---------------------------------------------------------------------------
-- 4) Liste photos pour l’admin
-- ---------------------------------------------------------------------------
create or replace function public.admin_list_realisation_photos(
  p_limit integer default 60,
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
  order by pr.created_at desc
  limit greatest(1, least(coalesce(p_limit, 60), 200))
  offset greatest(coalesce(p_offset, 0), 0);
$$;

comment on function public.admin_list_realisation_photos(integer, integer, text) is
  'Galerie réalisations pour modération admin (recherche optionnelle).';

grant execute on function public.admin_list_realisation_photos(integer, integer, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 5) Modération d’une photo
-- ---------------------------------------------------------------------------
create or replace function public.admin_moderate_realisation_photo(
  p_photo_id uuid,
  p_action text,
  p_note text default null,
  p_ban_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_photo public.photos_realisation%rowtype;
  v_user_id uuid;
  v_message text;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select * into v_photo
  from public.photos_realisation
  where id = p_photo_id;

  if not found then
    raise exception 'photo_not_found' using errcode = 'P0002';
  end if;

  select pp.user_id into v_user_id
  from public.prestataire_profiles pp
  where pp.id = v_photo.prestataire_id;

  if v_user_id is null then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  v_message := coalesce(
    nullif(trim(p_note), ''),
    'Une photo de votre galerie ne respecte pas nos règles de publication.'
  );

  case p_action
    when 'remove' then
      delete from public.photos_realisation where id = p_photo_id;
      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id, auth.uid(), 'photo_removed', p_photo_id, v_message
      );

    when 'flag_obscene' then
      insert into public.content_reports (
        reporter_user_id,
        target_type,
        target_id,
        reason,
        details,
        reviewed_at,
        reviewed_by,
        action_taken,
        action_note
      ) values (
        auth.uid(),
        'realisation_photo',
        p_photo_id::text,
        'Contenu obscène (modération admin)',
        v_message,
        now(),
        auth.uid(),
        'flag_obscene',
        v_message
      );
      delete from public.photos_realisation where id = p_photo_id;
      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id,
        auth.uid(),
        'photo_obscene_flagged',
        p_photo_id,
        'Contenu signalé comme inapproprié et retiré de la galerie.'
      );

    when 'warn' then
      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id, auth.uid(), 'account_warned', p_photo_id, v_message
      );

    when 'ban' then
      if nullif(trim(coalesce(p_ban_reason, '')), '') is null then
        raise exception 'ban_reason_required' using errcode = 'P0001';
      end if;
      if v_user_id = auth.uid() then
        raise exception 'cannot_ban_self' using errcode = '42501';
      end if;

      perform public.admin_ban_user(v_user_id, trim(p_ban_reason));

      delete from public.photos_realisation where id = p_photo_id;

      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id,
        auth.uid(),
        'photo_obscene_flagged',
        p_photo_id,
        'Compte suspendu : ' || trim(p_ban_reason)
      );

    else
      raise exception 'unknown_action' using errcode = 'P0002';
  end case;

  perform public.admin_write_audit_log(
    'moderate_realisation_photo',
    'realisation_photo',
    p_photo_id::text,
    jsonb_build_object(
      'action', p_action,
      'prestataire_id', v_photo.prestataire_id,
      'user_id', v_user_id
    )
  );

  return jsonb_build_object(
    'photo_url', v_photo.url,
    'removed', p_action in ('remove', 'flag_obscene', 'ban')
  );
end;
$$;

comment on function public.admin_moderate_realisation_photo(uuid, text, text, text) is
  'Modération admin : remove, flag_obscene, warn, ban.';

grant execute on function public.admin_moderate_realisation_photo(uuid, text, text, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 6) Signalements : libellé photo dans la liste admin
-- ---------------------------------------------------------------------------
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
  reviewed_at timestamptz,
  action_taken text,
  action_note text
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
      when 'realisation_photo' then coalesce(
        'Photo ' || left(cr.target_id, 8),
        cr.target_id
      )
      else cr.target_id
    end as target_label,
    cr.reason,
    cr.details,
    cr.created_at,
    cr.reviewed_at,
    cr.action_taken,
    cr.action_note
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
