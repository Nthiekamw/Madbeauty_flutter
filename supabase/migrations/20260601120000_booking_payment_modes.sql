-- Modes de paiement réservation (acompte 20 % / sur place) + frais plateforme.

alter table public.reservations
  add column if not exists payment_mode text
    check (
      payment_mode is null
      or payment_mode in ('deposit_20', 'on_site')
    ),
  add column if not exists platform_fee_cents integer
    check (platform_fee_cents is null or platform_fee_cents >= 0),
  add column if not exists service_price_cents integer
    check (service_price_cents is null or service_price_cents >= 0),
  add column if not exists prestataire_amount_cents integer
    check (prestataire_amount_cents is null or prestataire_amount_cents >= 0);

comment on column public.reservations.payment_mode is
  'deposit_20 = acompte 20 % dans l’app ; on_site = prestation réglée chez le prestataire.';
comment on column public.reservations.platform_fee_cents is
  'Frais MadBeauty (ex. 100 = 1 €) prélevés sur le PaymentIntent.';
comment on column public.reservations.service_price_cents is
  'Prix catalogue du service au moment de la réservation (centimes).';
comment on column public.reservations.prestataire_amount_cents is
  'Part du PaymentIntent transférée au prestataire (acompte).';
