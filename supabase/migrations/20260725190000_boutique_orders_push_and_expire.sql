-- Push boutique + expiration des pending_payment abandonnés.

-- ---------------------------------------------------------------------------
-- Expire les commandes Stripe non finalisées (create-before-pay).
-- ---------------------------------------------------------------------------
create or replace function public.expire_stale_boutique_pending_orders(
  p_max_age interval default interval '2 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
begin
  update public.boutique_commandes
  set
    statut = 'canceled',
    payment_status = 'failed',
    updated_at = now()
  where statut = 'pending_payment'
    and payment_status in ('pending', 'unpaid')
    and created_at < (now() - p_max_age);
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.expire_stale_boutique_pending_orders(interval)
  from public;
grant execute on function public.expire_stale_boutique_pending_orders(interval)
  to service_role;

comment on function public.expire_stale_boutique_pending_orders(interval) is
  'Annule les commandes boutique pending_payment trop anciennes (appel service_role).';

-- Client : annule ses propres pending abandonnés (RLS + auth.uid).
create or replace function public.expire_own_stale_boutique_pending_orders(
  p_max_age interval default interval '2 hours'
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
  v_client_id uuid;
begin
  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    return 0;
  end if;

  update public.boutique_commandes
  set
    statut = 'canceled',
    payment_status = 'failed',
    updated_at = now()
  where client_id = v_client_id
    and statut = 'pending_payment'
    and payment_status in ('pending', 'unpaid')
    and created_at < (now() - p_max_age);
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.expire_own_stale_boutique_pending_orders(interval)
  from public;
grant execute on function public.expire_own_stale_boutique_pending_orders(interval)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Triggers push (même canal private.notify_edge_function que les bookings).
-- ---------------------------------------------------------------------------
create or replace function public.trigger_boutique_order_created_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  -- Notifie le presta pour les commandes « actives » (pas pending Stripe).
  if NEW.statut in ('pay_on_site', 'paid') then
    perform private.notify_edge_function(
      'on_boutique_order_created',
      jsonb_build_object(
        'type', 'INSERT',
        'table', 'boutique_commandes',
        'schema', 'public',
        'record', to_jsonb(NEW),
        'old_record', null
      )
    );
  end if;
  return NEW;
end;
$$;

create or replace function public.trigger_boutique_order_updated_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  if NEW.statut is distinct from OLD.statut then
    -- Passage pending → paid : traite comme nouvelle commande pour le presta.
    if OLD.statut = 'pending_payment' and NEW.statut = 'paid' then
      perform private.notify_edge_function(
        'on_boutique_order_created',
        jsonb_build_object(
          'type', 'INSERT',
          'table', 'boutique_commandes',
          'schema', 'public',
          'record', to_jsonb(NEW),
          'old_record', to_jsonb(OLD)
        )
      );
    end if;

    perform private.notify_edge_function(
      'on_boutique_order_updated',
      jsonb_build_object(
        'type', 'UPDATE',
        'table', 'boutique_commandes',
        'schema', 'public',
        'record', to_jsonb(NEW),
        'old_record', to_jsonb(OLD)
      )
    );
  end if;
  return NEW;
end;
$$;

drop trigger if exists boutique_order_created_push_trigger
  on public.boutique_commandes;
create trigger boutique_order_created_push_trigger
  after insert on public.boutique_commandes
  for each row
  execute function public.trigger_boutique_order_created_push();

drop trigger if exists boutique_order_updated_push_trigger
  on public.boutique_commandes;
create trigger boutique_order_updated_push_trigger
  after update on public.boutique_commandes
  for each row
  execute function public.trigger_boutique_order_updated_push();
