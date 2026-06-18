-- Option acompte activable par le prestataire (Stripe Connect requis).

alter table public.prestataire_profiles
  add column if not exists deposit_option_enabled boolean not null default false;

comment on column public.prestataire_profiles.deposit_option_enabled is
  'Si true et Stripe Connect actif : les clients peuvent payer un acompte 20 % + frais plateforme dans l’app.';

create or replace function public.prestataire_set_deposit_option(p_enabled boolean)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
  v_charges boolean;
begin
  select p.id, p.stripe_connect_charges_enabled
  into v_id, v_charges
  from public.prestataire_profiles p
  where p.user_id = auth.uid();

  if v_id is null then
    raise exception 'prestataire_not_found' using errcode = 'P0001';
  end if;

  if p_enabled and not coalesce(v_charges, false) then
    raise exception 'connect_required' using errcode = 'P0001';
  end if;

  update public.prestataire_profiles
  set deposit_option_enabled = p_enabled
  where id = v_id;

  return p_enabled;
end;
$$;

comment on function public.prestataire_set_deposit_option(boolean) is
  'Active ou désactive l’acompte en ligne pour le prestataire connecté.';

grant execute on function public.prestataire_set_deposit_option(boolean) to authenticated;
