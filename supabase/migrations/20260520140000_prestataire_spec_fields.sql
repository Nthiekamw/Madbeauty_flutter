-- Champs spec onboarding prestataire + services enrichis + suggestions catégorie

DO $$ BEGIN
  CREATE TYPE public.lieu_travail_type AS ENUM ('home', 'client', 'both');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE public.prestataire_profiles
  ADD COLUMN IF NOT EXISTS lieu_travail public.lieu_travail_type,
  ADD COLUMN IF NOT EXISTS annees_experience text,
  ADD COLUMN IF NOT EXISTS code_postal text,
  ADD COLUMN IF NOT EXISTS nom_affiche text,
  ADD COLUMN IF NOT EXISTS experience_professionnelle text,
  ADD COLUMN IF NOT EXISTS description text;

ALTER TABLE public.services_beaute
  ADD COLUMN IF NOT EXISTS description text,
  ADD COLUMN IF NOT EXISTS categorie_id uuid REFERENCES public.categories_service(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_services_beaute_categorie
  ON public.services_beaute(categorie_id);

CREATE TABLE IF NOT EXISTS public.suggestions_categorie (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prestataire_id uuid NOT NULL REFERENCES public.prestataire_profiles(id) ON DELETE CASCADE,
  nom text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_suggestions_categorie_prestataire
  ON public.suggestions_categorie(prestataire_id);

ALTER TABLE public.suggestions_categorie ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS suggestions_categorie_write_own ON public.suggestions_categorie;
CREATE POLICY suggestions_categorie_write_own ON public.suggestions_categorie
  FOR ALL TO authenticated
  USING (
    prestataire_id IN (
      SELECT id FROM public.prestataire_profiles WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    prestataire_id IN (
      SELECT id FROM public.prestataire_profiles WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS suggestions_categorie_select_authenticated ON public.suggestions_categorie;
CREATE POLICY suggestions_categorie_select_authenticated ON public.suggestions_categorie
  FOR SELECT TO authenticated
  USING (true);
