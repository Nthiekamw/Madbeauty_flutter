create or replace function public.message_contains_phone_number(p_text text)
returns boolean
language sql
immutable
as $$
  select coalesce(p_text, '') ~ '(?:\+?\d[\d .-]{7,}\d)';
$$;

create or replace function public.messages_block_phone_numbers()
returns trigger
language plpgsql
as $$
declare
  v_content text := coalesce(new.content, new.contenu, '');
begin
  if public.message_contains_phone_number(v_content) then
    raise exception 'phone_number_not_allowed'
      using errcode = '22023';
  end if;
  return new;
end;
$$;

drop trigger if exists messages_block_phone_numbers on public.messages;
create trigger messages_block_phone_numbers
before insert or update on public.messages
for each row
execute function public.messages_block_phone_numbers();
