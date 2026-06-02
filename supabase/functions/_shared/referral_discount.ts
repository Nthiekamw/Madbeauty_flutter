import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export const REFERRAL_BOOKING_DISCOUNT_PERCENT = 10;

export interface ActiveReferralDiscount {
  percent: number;
  reason: string;
}

/** Prix prestation après remise parrainage (centimes). */
export function discountedServicePriceCents(
  originalCents: number,
  percent: number,
): number {
  return Math.round((originalCents * (100 - percent)) / 100);
}

export async function fetchActiveReferralDiscount(
  admin: SupabaseClient,
  clientId: string,
): Promise<ActiveReferralDiscount | null> {
  const { data, error } = await admin
    .from("client_profiles")
    .select(
      "referral_discount_percent, referral_discount_reason, referral_discount_used_at",
    )
    .eq("id", clientId)
    .maybeSingle();

  if (error || !data) {
    console.error("fetchActiveReferralDiscount", error);
    return null;
  }

  const percent = Number(data.referral_discount_percent ?? 0);
  if (percent <= 0 || data.referral_discount_used_at != null) {
    return null;
  }

  return {
    percent,
    reason: String(data.referral_discount_reason ?? "referred"),
  };
}
