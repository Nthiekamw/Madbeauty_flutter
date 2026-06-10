-- Photos dans le chat (messages.image_url + bucket stockage).

alter table public.messages
  add column if not exists image_url text;

comment on column public.messages.image_url is
  'URL publique d’une image jointe au message (bucket chat-attachments).';

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'chat-attachments',
  'chat-attachments',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "chat_attachments_select_public"
on storage.objects for select to public
using (bucket_id = 'chat-attachments');

create policy "chat_attachments_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "chat_attachments_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'chat-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
);
