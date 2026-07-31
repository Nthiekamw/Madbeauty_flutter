import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  fetchPlatformFeeSettings,
  type PlatformFeeSettings,
} from "./platform_fee_settings.ts";

export type BookingPaymentMode = "deposit_20" | "on_site";

export const DEPOSIT_PERCENT = 20;
export const LOYALTY_MAX_REWARD_CENTS = 5000;
export const LOYALTY_POINTS_PER_REWARD = 200;
export const SALON_VIP_DISCOUNT_PERCENT = 5;

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
  platformFeeFreeBookingCount: number;
  originalServicePriceCents?: number;
  referralDiscountPercent?: number;
  vipDiscountPercent?: number;
  loyaltyRewardCents?: number;
}

export function platformFeeCentsForPriorCount(
  priorBookingCount: number,
  settings: PlatformFeeSettings,
): number {
  if (priorBookingCount < settings.freeBookingCount) return 0;
  return settings.feeCents;
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

export function loyaltyCoverCents(
  priceAfterDiscountsCents: number,
  maxCents = LOYALTY_MAX_REWARD_CENTS,
): number {
  return Math.min(priceAfterDiscountsCents, maxCents);
}

export function computeBookingPricing(params: {
  servicePriceCents: number;
  paymentMode: BookingPaymentMode;
  priorBookingCount: number;
  prestataireAcceptsConnect: boolean;
  referralDiscountPercent?: number;
  vipDiscountPercent?: number;
  applyLoyaltyReward?: boolean;
  platformFeeSettings: PlatformFeeSettings;
}): BookingPricingBreakdown {
  const {
    servicePriceCents: originalServicePriceCents,
    paymentMode,
    priorBookingCount,
    prestataireAcceptsConnect,
    referralDiscountPercent,
    vipDiscountPercent,
    applyLoyaltyReward = false,
    platformFeeSettings,
  } = params;
  const referralPercent = referralDiscountPercent;
  const afterReferral = referralPercent != null && referralPercent > 0
    ? discountedServicePriceCents(originalServicePriceCents, referralPercent)
    : originalServicePriceCents;
  const vipPercent = vipDiscountPercent;
  const afterVip = vipPercent != null && vipPercent > 0
    ? discountedServicePriceCents(afterReferral, vipPercent)
    : afterReferral;
  const loyaltyReward = applyLoyaltyReward
    ? loyaltyCoverCents(afterVip)
    : 0;
  const servicePriceCents = Math.max(afterVip - loyaltyReward, 0);

  let platformFee = platformFeeCentsForPriorCount(
    priorBookingCount,
    platformFeeSettings,
  );
  if (loyaltyReward > 0) platformFee = 0;

  const needsOriginal =
    (referralPercent != null && referralPercent > 0) ||
    (vipPercent != null && vipPercent > 0) ||
    loyaltyReward > 0;
  const discountMeta = {
    ...(needsOriginal ? { originalServicePriceCents } : {}),
    ...(referralPercent != null && referralPercent > 0
      ? { referralDiscountPercent: referralPercent }
      : {}),
    ...(vipPercent != null && vipPercent > 0
      ? { vipDiscountPercent: vipPercent }
      : {}),
    ...(loyaltyReward > 0 ? { loyaltyRewardCents: loyaltyReward } : {}),
  };

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
      platformFeeFreeBookingCount: platformFeeSettings.freeBookingCount,
      ...discountMeta,
    };
  }

  return {
    paymentMode: "on_site",
    servicePriceCents,
    depositCents: 0,
    platformFeeCents: 0,
    prestatairePortionCents: 0,
    totalChargeCents: 0,
    balanceOnSiteCents: servicePriceCents,
    requiresInAppPayment: false,
    priorBookingCount,
    platformFeeFreeBookingCount: platformFeeSettings.freeBookingCount,
    ...discountMeta,
  };
}

export async function computeBookingPricingFromSettings(
  admin: SupabaseClient,
  params: Omit<
    Parameters<typeof computeBookingPricing>[0],
    "platformFeeSettings"
  >,
): Promise<BookingPricingBreakdown> {
  const platformFeeSettings = await fetchPlatformFeeSettings(admin);
  return computeBookingPricing({ ...params, platformFeeSettings });
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

export async function clientLoyaltyPoints(
  admin: SupabaseClient,
  clientId: string,
): Promise<number> {
  const { data, error } = await admin
    .from("client_profiles")
    .select("loyalty_points")
    .eq("id", clientId)
    .maybeSingle();
  if (error) {
    console.error("clientLoyaltyPoints", error);
    return 0;
  }
  return Number(data?.loyalty_points ?? 0);
}

export async function isClientVipAtPrestataire(
  admin: SupabaseClient,
  clientId: string,
  prestataireId: string,
): Promise<boolean> {
  const { data, error } = await admin.rpc("is_client_vip_at_prestataire", {
    p_client_id: clientId,
    p_prestataire_id: prestataireId,
  });
  if (error) {
    console.error("isClientVipAtPrestataire", error);
    return false;
  }
  return data === true;
}
