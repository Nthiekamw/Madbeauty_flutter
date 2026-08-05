-- Slugs publics courts pour partage : https://madbeauty.pro/@vichy

alter table public.prestataire_profiles
  add column if not exists public_slug text;

comment on column public.prestataire_profiles.public_slug is
  'Identifiant URL public (ex. vichy → madbeauty.pro/@vichy). Unique, stable.';

-- Slugify (minuscules, sans accents, tirets).
create or replace function public.slugify_label(p_raw text)
returns text
language plpgsql
immutable
as $$
declare
  v text := lower(trim(coalesce(p_raw, '')));
begin
  if v = '' then
    return '';
  end if;

  v := translate(
    v,
    'àáâãäåāăąèéêëēĕėęěìíîïĩīĭįıòóôõöøōŏőùúûüũūŭůűųçćčñńņňýÿžźżśšşđðßæœ',
    'aaaaaaaaaeeeeeeeeeiiiiiiiiioooooooooouuuuuuuuucccnnnnyyzzzsssddssaeoe'
  );

  v := regexp_replace(v, '[^a-z0-9]+', '-', 'g');
  v := regexp_replace(v, '^-+|-+$', '', 'g');
  v := regexp_replace(v, '-{2,}', '-', 'g');

  if char_length(v) > 48 then
    v := left(v, 48);
    v := regexp_replace(v, '-+$', '', 'g');
  end if;

  return v;
end;
$$;

create or replace function public.is_reserved_prestataire_slug(p_slug text)
returns boolean
language sql
immutable
as $$
  select lower(trim(coalesce(p_slug, ''))) in (
    'admin', 'api', 'app', 'assets', 'auth', 'booking', 'client', 'dashboard',
    'help', 'home', 'invite', 'login', 'madbeauty', 'p', 'presta', 'prestataire',
    'prestataires', 'profile', 'reel', 'reels', 'register', 'search', 'support',
    'www', 'well-known'
  );
$$;

-- Alloue un slug unique à partir d’un libellé (suffixe -2, -3… si besoin).
create or replace function public.allocate_prestataire_public_slug(
  p_prestataire_id uuid,
  p_label text
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_base text;
  v_candidate text;
  v_i integer := 2;
begin
  v_base := public.slugify_label(p_label);
  if v_base = '' or public.is_reserved_prestataire_slug(v_base) then
    v_base := 'salon';
  end if;
  if char_length(v_base) < 2 then
    v_base := 'salon';
  end if;

  v_candidate := v_base;
  loop
    exit when not exists (
      select 1
      from public.prestataire_profiles pp
      where pp.public_slug = v_candidate
        and pp.id is distinct from p_prestataire_id
    )
    and not public.is_reserved_prestataire_slug(v_candidate);

    v_candidate := left(v_base, greatest(1, 48 - char_length(v_i::text) - 1))
      || '-' || v_i::text;
    v_i := v_i + 1;
    if v_i > 9999 then
      v_candidate := 'salon-' || replace(p_prestataire_id::text, '-', '');
      exit;
    end if;
  end loop;

  return v_candidate;
end;
$$;

-- Backfill des profils existants.
do $$
declare
  r record;
  v_slug text;
begin
  for r in
    select
      pp.id,
      coalesce(
        nullif(trim(pp.nom_affiche), ''),
        nullif(trim(pp.nom_salon), ''),
        'salon'
      ) as label
    from public.prestataire_profiles pp
    where pp.public_slug is null
       or length(trim(pp.public_slug)) = 0
  loop
    v_slug := public.allocate_prestataire_public_slug(r.id, r.label);
    update public.prestataire_profiles
    set public_slug = v_slug
    where id = r.id;
  end loop;
end $$;

create unique index if not exists idx_prestataire_profiles_public_slug
  on public.prestataire_profiles (public_slug)
  where public_slug is not null;

alter table public.prestataire_profiles
  drop constraint if exists prestataire_profiles_public_slug_format;
alter table public.prestataire_profiles
  add constraint prestataire_profiles_public_slug_format
  check (
    public_slug is null
    or (
      public_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
      and char_length(public_slug) between 2 and 48
    )
  );

-- Remplit le slug à la création / si encore vide.
create or replace function public.trg_prestataire_profiles_ensure_public_slug()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_label text;
begin
  if NEW.public_slug is not null and length(trim(NEW.public_slug)) > 0 then
    NEW.public_slug := lower(trim(NEW.public_slug));
    if public.is_reserved_prestataire_slug(NEW.public_slug) then
      raise exception 'prestataire_slug_reserved'
        using errcode = 'P0001',
              message = 'Ce lien court est réservé.';
    end if;
    return NEW;
  end if;

  v_label := coalesce(
    nullif(trim(NEW.nom_affiche), ''),
    nullif(trim(NEW.nom_salon), ''),
    'salon'
  );
  NEW.public_slug := public.allocate_prestataire_public_slug(NEW.id, v_label);
  return NEW;
end;
$$;

drop trigger if exists trg_prestataire_profiles_ensure_public_slug
  on public.prestataire_profiles;
create trigger trg_prestataire_profiles_ensure_public_slug
before insert or update of nom_affiche, nom_salon, public_slug
on public.prestataire_profiles
for each row
execute function public.trg_prestataire_profiles_ensure_public_slug();

-- Résolution publique UUID ou slug (anon OK).
create or replace function public.resolve_prestataire_public_ref(p_ref text)
returns uuid
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_ref text := lower(trim(coalesce(p_ref, '')));
  v_id uuid;
begin
  if v_ref = '' then
    return null;
  end if;

  -- Enlève un éventuel @
  if left(v_ref, 1) = '@' then
    v_ref := substr(v_ref, 2);
  end if;

  if v_ref ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    select pp.id into v_id
    from public.prestataire_profiles pp
    where pp.id = v_ref::uuid
      and public.prestataire_is_catalog_visible(pp.id)
    limit 1;
    return v_id;
  end if;

  select pp.id into v_id
  from public.prestataire_profiles pp
  where pp.public_slug = v_ref
    and public.prestataire_is_catalog_visible(pp.id)
  limit 1;

  return v_id;
end;
$$;

revoke all on function public.resolve_prestataire_public_ref(text) from public;
grant execute on function public.resolve_prestataire_public_ref(text)
  to anon, authenticated;
