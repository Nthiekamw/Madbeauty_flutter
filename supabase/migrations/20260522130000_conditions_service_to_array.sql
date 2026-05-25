-- Si conditions_service a été créé en text (ancienne version), conversion en tableau.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'prestataire_profiles'
      AND column_name = 'conditions_service'
      AND data_type = 'text'
  ) THEN
    ALTER TABLE public.prestataire_profiles
      ALTER COLUMN conditions_service DROP DEFAULT;

    ALTER TABLE public.prestataire_profiles
      ALTER COLUMN conditions_service TYPE text[] USING (
        CASE
          WHEN conditions_service IS NULL
            OR btrim(conditions_service) = '' THEN '{}'::text[]
          ELSE ARRAY[btrim(conditions_service)]
        END
      );

    ALTER TABLE public.prestataire_profiles
      ALTER COLUMN conditions_service SET DEFAULT '{}';

    ALTER TABLE public.prestataire_profiles
      ALTER COLUMN conditions_service SET NOT NULL;
  END IF;
END $$;
