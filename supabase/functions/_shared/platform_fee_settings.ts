import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface PlatformFeeSettings {
  feeCents: number;
  freeBookingCount: number;
}

const DEFAULT: PlatformFeeSettings = {
  feeCents: 0,
  freeBookingCount: 2,
};

export async function fetchPlatformFeeSettings(
  admin: SupabaseClient,
): Promise<PlatformFeeSettings> {
  const { data, error } = await admin.rpc("platform_booking_fee_settings");
  if (error) {
    console.error("fetchPlatformFeeSettings", error);
    return DEFAULT;
  }
  return parsePlatformFeeSettings(data);
}

export function parsePlatformFeeSettings(raw: unknown): PlatformFeeSettings {
  if (raw == null || typeof raw !== "object") return DEFAULT;
  const value = raw as Record<string, unknown>;
  const feeCents = Math.max(0, Math.round(Number(value.fee_cents ?? 0)));
  const freeBookingCount = Math.max(
    0,
    Math.round(Number(value.free_booking_count ?? DEFAULT.freeBookingCount)),
  );
  if (!Number.isFinite(feeCents) || !Number.isFinite(freeBookingCount)) {
    return DEFAULT;
  }
  return { feeCents, freeBookingCount };
}
