-- Nettoyage rapide des adresses existantes (à exécuter manuellement si besoin).
-- Exemple :
-- npx supabase db query < scripts/cleanup_addresses.sql

update public.client_profiles
set adresse = null
where upper(trim(coalesce(adresse, ''))) = 'NULL';

update public.prestataire_profiles
set adresse = null
where upper(trim(coalesce(adresse, ''))) = 'NULL';

update public.client_profiles
set adresse = regexp_replace(
  trim(adresse),
  '^\s*(rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+\1\s+',
  '\1 ',
  'i'
)
where adresse is not null;

update public.prestataire_profiles
set adresse = regexp_replace(
  trim(adresse),
  '^\s*(rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+\1\s+',
  '\1 ',
  'i'
)
where adresse is not null;

select 'client_profiles' as table_name, id, adresse
from public.client_profiles
where adresse is null
   or trim(adresse) = ''
   or adresse ~* '^\s*(rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+\1\s+'
order by id;

select 'prestataire_profiles' as table_name, id, adresse
from public.prestataire_profiles
where adresse is null
   or trim(adresse) = ''
   or adresse ~* '^\s*(rue|avenue|boulevard|place|all[ée]e|impasse|chemin|passage|quai|route|square|cours|r[ée]sidence|voie|sentier)\s+\1\s+'
order by id;
