-- upsert() PostgREST → INSERT ... ON CONFLICT DO UPDATE : la branche UPDATE
-- exige une policy FOR UPDATE (ex. ré-insérer le rôle client déjà créé par handle_new_user).

create policy "user_roles_update_own"
on public.user_roles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
