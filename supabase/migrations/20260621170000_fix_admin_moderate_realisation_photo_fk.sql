-- Corrige admin_moderate_realisation_photo : insérer l'événement modération
-- avant suppression (FK account_moderation_events.photo_id → photos_realisation).

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
      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id, auth.uid(), 'photo_removed', p_photo_id, v_message
      );
      delete from public.photos_realisation where id = p_photo_id;

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
      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id,
        auth.uid(),
        'photo_obscene_flagged',
        p_photo_id,
        'Contenu signalé comme inapproprié et retiré de la galerie.'
      );
      delete from public.photos_realisation where id = p_photo_id;

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

      insert into public.account_moderation_events (
        user_id, admin_user_id, event_type, photo_id, message
      ) values (
        v_user_id,
        auth.uid(),
        'photo_obscene_flagged',
        p_photo_id,
        'Compte suspendu : ' || trim(p_ban_reason)
      );
      delete from public.photos_realisation where id = p_photo_id;

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
