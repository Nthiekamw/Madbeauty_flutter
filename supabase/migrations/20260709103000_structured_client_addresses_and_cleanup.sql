-- Adresses structurées client + nettoyage minimal des rues dupliquées / valeurs NULL.

alter table public.client_profiles
  add column if not exists ville text,
  add column if not exists code_postal text,
  add column if not exists pays char(2),
  add column if not exists voie_type text,
  add column if not exists voie_nom text,
  add column if not exists numero_rue text,
  add column if not exists latitude double precision,
  add column if not exists longitude double precision;

comment on column public.client_profiles.adresse is
  'Adresse formatée complète (voie, code postal, ville, pays).';
comment on column public.client_profiles.ville is
  'Ville normalisée du client.';
comment on column public.client_profiles.code_postal is
  'Code postal du client.';
comment on column public.client_profiles.pays is
  'Code pays ISO 3166-1 alpha-2 du client (ex. FR, BE).';
comment on column public.client_profiles.voie_type is
  'Type de voie séparé (Rue, Avenue, Boulevard…).';
comment on column public.client_profiles.voie_nom is
  'Nom de voie sans type ni numéro.';
comment on column public.client_profiles.numero_rue is
  'Numéro de rue / voie.';
comment on column public.client_profiles.latitude is
  'Latitude issue du géocodage.';
comment on column public.client_profiles.longitude is
  'Longitude issue du géocodage.';

create index if not exists idx_client_profiles_ville
  on public.client_profiles (ville);

create or replace function public.normalize_street_line(p_value text)
returns text
language sql
immutable
as $$
  select nullif(
    trim(
      regexp_replace(
        regexp_replace(
          regexp_replace(coalesce(p_value, ''), '^\s*NULL\s*$', '', 'i'),
          '\s+',
          ' ',
          'g'
        ),
        '^\s*(rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+\1\s+',
        '\1 ',
        'i'
      )
    ),
    ''
  );
$$;

create or replace function public.infer_country_iso2_from_postal_code(p_code_postal text)
returns char(2)
language sql
immutable
as $$
  select coalesce(
    case
      when trim(coalesce(p_code_postal, '')) ~ '^[0-9]{5}$' then 'FR'::char(2)
      when trim(coalesce(p_code_postal, '')) ~ '^[0-9]{4}$' then 'BE'::char(2)
      when trim(coalesce(p_code_postal, '')) ~ '^[1-9][0-9]{4}$' then 'CH'::char(2)
      when upper(trim(coalesce(p_code_postal, ''))) ~ '^[1-9][0-9]{3}\s?[A-Z]{2}$' then 'NL'::char(2)
      else null
    end,
    'FR'::char(2)
  );
$$;

update public.client_profiles
set adresse = public.normalize_street_line(adresse)
where adresse is not null;

update public.prestataire_profiles
set adresse = public.normalize_street_line(adresse)
where adresse is not null;

with parsed as (
  select
    cp.id,
    trim(split_part(coalesce(cp.adresse, ''), ',', 1)) as street_part,
    trim(split_part(coalesce(cp.adresse, ''), ',', 2)) as cp_city_part,
    nullif(trim(split_part(coalesce(cp.adresse, ''), ',', 3)), '') as country_part
  from public.client_profiles cp
)
update public.client_profiles cp
set
  numero_rue = coalesce(
    cp.numero_rue,
    nullif(substring(parsed.street_part from '^([0-9]+[A-Za-z]?)\s+'), '')
  ),
  voie_type = coalesce(
    cp.voie_type,
    initcap(nullif(substring(parsed.street_part from '^(?:[0-9]+[A-Za-z]?\s+)?([[:alpha:]]+)'), ''))
  ),
  voie_nom = coalesce(
    cp.voie_nom,
    nullif(
      regexp_replace(
        parsed.street_part,
        '^(?:[0-9]+[A-Za-z]?\s+)?(?:rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+',
        '',
        'i'
      ),
      ''
    )
  ),
  code_postal = coalesce(
    cp.code_postal,
    nullif(substring(parsed.cp_city_part from '^([0-9]{4,5})\s+'), '')
  ),
  ville = coalesce(
    cp.ville,
    nullif(regexp_replace(parsed.cp_city_part, '^[0-9]{4,5}\s+', '', 'i'), '')
  ),
  pays = coalesce(
    cp.pays,
    case
      when parsed.country_part is null then public.infer_country_iso2_from_postal_code(cp.code_postal)
      when upper(parsed.country_part) in ('FR', 'FRANCE') then 'FR'::char(2)
      when upper(parsed.country_part) in ('BE', 'BELGIQUE', 'BELGIUM') then 'BE'::char(2)
      when upper(parsed.country_part) in ('CH', 'SUISSE', 'SWITZERLAND') then 'CH'::char(2)
      when upper(parsed.country_part) in ('LU', 'LUXEMBOURG') then 'LU'::char(2)
      else public.infer_country_iso2_from_postal_code(cp.code_postal)
    end
  )
from parsed
where parsed.id = cp.id
  and (
    cp.voie_type is null
    or cp.voie_nom is null
    or cp.code_postal is null
    or cp.ville is null
    or cp.pays is null
  );
