import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type BookingPaymentMode = "deposit_20" | "on_site";

export const PLATFORM_FEE_CENTS = 100;
export const PLATFORM_FEE_FREE_BOOKING_COUNT = 2;
export const DEPOSIT_PERCENT = 20;

export interface BookingPricingBreakdown {
  paymentMode: BookingPaymentMode;
  servicePriceCents: number;
  depositCents: number;
  platformFeeCents: number;
  prestatairePortionCents: number;
  totalChargeCents: number;
  balanceOnSiteCents: number;
  requiresInAppPayment: boolean;
  priorBookingCount: number;
  originalServicePriceCents?: number;
  referralDiscountPercent?: number;
}

export function platformFeeCentsForPriorCount(priorBookingCount: number): number {
  if (priorBookingCount < PLATFORM_FEE_FREE_BOOKING_COUNT) return 0;
  return PLATFORM_FEE_CENTS;
}

export function depositCentsFromService(servicePriceCents: number): number {
  return Math.round((servicePriceCents * DEPOSIT_PERCENT) / 100);
}

export function discountedServicePriceCents(
  originalCents: number,
  discountPercent: number,
): number {
  return Math.round((originalCents * (100 - discountPercent)) / 100);
}

export function computeBookingPricing(params: {
  servicePriceCents: number;
  paymentMode: BookingPaymentMode;
  priorBookingCount: number;
  prestataireAcceptsConnect: boolean;
  referralDiscountPercent?: number;
}): BookingPricingBreakdown {
  const {
    servicePriceCents: originalServicePriceCents,
    paymentMode,
    priorBookingCount,
    prestataireAcceptsConnect,
    referralDiscountPercent,
  } = params;
  const percent = referralDiscountPercent;
  const servicePriceCents = percent != null && percent > 0
    ? discountedServicePriceCents(originalServicePriceCents, percent)
    : originalServicePriceCents;
  const platformFee = platformFeeCentsForPriorCount(priorBookingCount);
  const discountMeta = percent != null && percent > 0
    ? { originalServicePriceCents, referralDiscountPercent: percent }
    : {};

  if (paymentMode === "deposit_20") {
    if (!prestataireAcceptsConnect) {
      throw new Error("deposit_requires_connect");
    }
    const deposit = depositCentsFromService(servicePriceCents);
    const total = deposit + platformFee;
    return {
      paymentMode,
      servicePriceCents,
      depositCents: deposit,
      platformFeeCents: platformFee,
      prestatairePortionCents: deposit,
      totalChargeCents: total,
      balanceOnSiteCents: servicePriceCents - deposit,
      requiresInAppPayment: total > 0,
      priorBookingCount,
      ...discountMeta,
    };
  }

  return {
    paymentMode: "on_site",
    servicePriceCents,
    depositCents: 0,
    platformFeeCents: platformFee,
    prestatairePortionCents: 0,
    totalChargeCents: platformFee,
    balanceOnSiteCents: servicePriceCents,
    requiresInAppPayment: platformFee > 0,
    priorBookingCount,
    ...discountMeta,
  };
}

/** Réservations client hors annulées (avant la réservation en cours). */
export async function countClientBookingsForPlatformFee(
  admin: SupabaseClient,
  clientId: string,
): Promise<number> {
  const { count, error } = await admin
    .from("reservations")
    .select("id", { count: "exact", head: true })
    .eq("client_id", clientId)
    .not("statut", "in", "(annulee,cancelled)");
  if (error) {
    console.error("countClientBookingsForPlatformFee", error);
    return 0;
  }
  return count ?? 0;
}
