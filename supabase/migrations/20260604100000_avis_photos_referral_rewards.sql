-- Photos d'avis + récompenses parrainage (badge ambassadrice à 3 filleules).

-- ---------------------------------------------------------------------------
-- Parrainage : badge ambassadrice
-- ---------------------------------------------------------------------------

alter table public.client_profiles
  add column if not exists referral_ambassador_at timestamptz;

comment on column public.client_profiles.referral_ambassador_at is
  'Date d’obtention du badge Ambassadrice (3+ filleules parrainées).';

create or replace function public.trg_check_referral_ambassador()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  select count(*)::integer
  into v_count
  from public.client_referrals
  where referrer_client_id = new.referrer_client_id;

  if v_count >= 3 then
    update public.client_profiles
    set referral_ambassador_at = coalesce(referral_ambassador_at, now())
    where id = new.referrer_client_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_client_referrals_ambassador on public.client_referrals;
create trigger trg_client_referrals_ambassador
after insert on public.client_referrals
for each row
execute function public.trg_check_referral_ambassador();

create or replace function public.get_my_referral_info()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_code text;
  v_count integer;
  v_has_referrer boolean;
  v_ambassador_at timestamptz;
  v_tier text;
  v_next integer;
  v_reward text;
begin
  select c.id, c.referral_code, c.referral_ambassador_at
  into v_client_id, v_code, v_ambassador_at
  from public.client_profiles c
  where c.user_id = auth.uid();

  if v_client_id is null then
    return jsonb_build_object('error', 'client_not_found');
  end if;

  select count(*)::integer
  into v_count
  from public.client_referrals r
  where r.referrer_client_id = v_client_id;

  select exists (
    select 1 from public.client_referrals r
    where r.referred_client_id = v_client_id
  )
  into v_has_referrer;

  if v_count >= 3 or v_ambassador_at is not null then
    v_tier := 'ambassador';
    v_next := null;
    v_reward :=
      'Badge Ambassadrice MadBeauty débloqué ! Merci de faire grandir la communauté.';
  elsif v_count >= 1 then
    v_tier := 'friend';
    v_next := 3 - v_count;
    v_reward := format(
      'Encore %s amie(s) pour débloquer le badge Ambassadrice.',
      greatest(v_next, 0)
    );
  else
    v_tier := 'none';
    v_next := 1;
    v_reward := 'Parraine ta première amie pour commencer à débloquer des récompenses.';
  end if;

  return jsonb_build_object(
    'code', v_code,
    'invitations_count', v_count,
    'has_referrer', v_has_referrer,
    'is_ambassador', v_tier = 'ambassador',
    'tier', v_tier,
    'next_milestone', v_next,
    'reward_message', v_reward
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Photos d'avis
-- ---------------------------------------------------------------------------

alter table public.avis
  add column if not exists photo_urls text[] not null default '{}';

comment on column public.avis.photo_urls is
  'URLs publiques des photos jointes à l’avis (max 3 en app).';

-- Bucket stockage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'review-photos',
  'review-photos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "review_photos_select_public"
on storage.objects for select to public
using (bucket_id = 'review-photos');

create policy "review_photos_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "review_photos_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'review-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
