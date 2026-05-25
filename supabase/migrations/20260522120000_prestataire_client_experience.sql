-- Confort client et conditions de service (fiche prestataire)

ALTER TABLE public.prestataire_profiles
  ADD COLUMN IF NOT EXISTS confort_client text[] NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS conditions_service text[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.prestataire_profiles.confort_client IS
  'Ids preset (wifi, parking…) ou custom:Libellé libre.';
COMMENT ON COLUMN public.prestataire_profiles.conditions_service IS
  'Ids preset (cancel_24h…) ou custom:Texte libre pour chaque règle.';
