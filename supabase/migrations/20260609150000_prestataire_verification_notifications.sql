-- Vérification prestataire : re-demande après refus, motif obligatoire, push FCM.

-- Prestataire : lire ses propres événements (boîte de notifications in-app).
drop policy if exists "prestataire_verification_events_self_select"
  on public.prestataire_verification_events;
create policy "prestataire_verification_events_self_select"
  on public.prestataire_verification_events
  for select to authenticated
  using (
    exists (
      select 1
      from public.prestataire_profiles pp
      where pp.id = prestataire_id
        and pp.user_id = auth.uid()
    )
  );

-- Statut lecture seule pour l'écran profil prestataire.
create or replace function public.prestataire_verification_status()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.prestataire_profiles%rowtype;
begin
  select * into v_row
  from public.prestataire_profiles
  where user_id = auth.uid();

  if not found then
    return jsonb_build_object('found', false);
  end if;

  return jsonb_build_object(
    'found', true,
    'is_verified', coalesce(v_row.is_verified, false),
    'verification_requested_at', v_row.verification_requested_at,
    'verification_note', v_row.verification_note,
    'verified_at', v_row.verified_at,
    'can_request',
      coalesce(v_row.is_verified, false) = false
      and v_row.verification_requested_at is null
  );
end;
$$;

grant execute on function public.prestataire_verification_status() to authenticated;

-- Demande : interdit si déjà vérifié ou demande en cours.
create or replace function public.request_prestataire_verification()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prestataire_id uuid;
begin
  select pp.id
  into v_prestataire_id
  from public.prestataire_profiles pp
  where pp.user_id = auth.uid();

  if v_prestataire_id is null then
    raise exception 'prestataire_profile_not_found'
      using errcode = 'P0002';
  end if;

  if exists (
    select 1
    from public.prestataire_profiles pp
    where pp.id = v_prestataire_id
      and pp.is_verified = true
  ) then
    raise exception 'already_verified'
      using errcode = 'P0002';
  end if;

  if exists (
    select 1
    from public.prestataire_profiles pp
    where pp.id = v_prestataire_id
      and pp.verification_requested_at is not null
  ) then
    raise exception 'verification_already_pending'
      using errcode = 'P0002';
  end if;

  update public.prestataire_profiles
  set verification_requested_at = now(),
      verification_note = null
  where id = v_prestataire_id;

  insert into public.prestataire_verification_events (
    prestataire_id,
    actor_user_id,
    action,
    note
  )
  values (v_prestataire_id, auth.uid(), 'requested', null);

  perform public.admin_write_audit_log(
    'verification_requested',
    'prestataire_profile',
    v_prestataire_id::text,
    null
  );
end;
$$;

create or replace function public.approve_prestataire_verification(
  p_prestataire_id uuid,
  p_note text default null
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

  update public.prestataire_profiles
  set is_verified = true,
      verified_at = now(),
      verified_by = auth.uid(),
      verification_requested_at = coalesce(verification_requested_at, now()),
      verification_note = nullif(trim(coalesce(p_note, '')), '')
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id, actor_user_id, action, note
  )
  values (
    p_prestataire_id,
    auth.uid(),
    'approved',
    nullif(trim(coalesce(p_note, '')), '')
  );

  perform public.admin_write_audit_log(
    'approve_verification',
    'prestataire_profile',
    p_prestataire_id::text,
    jsonb_build_object('note', p_note)
  );
end;
$$;

create or replace function public.revoke_prestataire_verification(
  p_prestataire_id uuid,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_note text := nullif(trim(coalesce(p_note, '')), '');
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if v_note is null or length(v_note) < 3 then
    raise exception 'revoke_note_required'
      using errcode = 'P0002';
  end if;

  update public.prestataire_profiles
  set is_verified = false,
      verified_at = null,
      verified_by = auth.uid(),
      verification_requested_at = null,
      verification_note = v_note
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id, actor_user_id, action, note
  )
  values (p_prestataire_id, auth.uid(), 'revoked', v_note);

  perform public.admin_write_audit_log(
    'revoke_verification',
    'prestataire_profile',
    p_prestataire_id::text,
    jsonb_build_object('note', v_note)
  );
end;
$$;

-- Push FCM prestataire (approve / revoke).
create or replace function public.trigger_verification_decided_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  if NEW.action not in ('approved', 'revoked') then
    return NEW;
  end if;

  perform private.notify_edge_function(
    'on_verification_decided',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'prestataire_verification_events',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists verification_decided_push_trigger
  on public.prestataire_verification_events;
create trigger verification_decided_push_trigger
  after insert on public.prestataire_verification_events
  for each row
  execute function public.trigger_verification_decided_push();
