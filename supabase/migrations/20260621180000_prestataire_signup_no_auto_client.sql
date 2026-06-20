-- Inscription : ne plus attribuer automatiquement le rôle client.
-- Le rôle client est ajouté explicitement (inscription cliente ou opt-in depuis le profil prestataire).

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_profiles (user_id, nom, prenom, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', null),
    null,
    now()
  )
  on conflict (user_id) do nothing;

  return new;
end;
$$;
