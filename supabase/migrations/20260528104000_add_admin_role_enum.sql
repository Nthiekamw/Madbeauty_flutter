do $$
begin
  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    where t.typname = 'app_role' and e.enumlabel = 'admin'
  ) then
    alter type public.app_role add value 'admin';
  end if;
end
$$;
