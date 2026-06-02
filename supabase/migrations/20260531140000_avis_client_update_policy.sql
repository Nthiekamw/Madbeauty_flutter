-- Le client peut modifier son avis pendant 30 jours après publication.
create policy "avis_update_own_within_month"
on public.avis
for update
to authenticated
using (
  exists (
    select 1
    from public.client_profiles c
    where c.id = avis.client_id
      and c.user_id = auth.uid()
  )
  and created_at >= (now() - interval '30 days')
)
with check (
  exists (
    select 1
    from public.client_profiles c
    where c.id = avis.client_id
      and c.user_id = auth.uid()
  )
  and created_at >= (now() - interval '30 days')
  and note >= 1
  and note <= 5
);
