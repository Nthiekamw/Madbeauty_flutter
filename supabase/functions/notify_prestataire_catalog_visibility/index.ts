import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  createServiceClient,
  fetchFcmTokenForPrestataireProfileId,
  sendFcmNotification,
} from "../_shared/booking_notify.ts";
import {
  requireAuthUser,
  serviceClient,
} from "../_shared/supabase_auth.ts";

type NudgeReason =
  | "incompleteProfile"
  | "missingMapLocation"
  | "needsSubscription";

const MESSAGES: Record<
  NudgeReason,
  { title: string; body: string; type: string }
> = {
  incompleteProfile: {
    title: "MadBeauty Pro",
    body:
      "Complète ton profil pro pour apparaître dans le catalogue et recevoir des clientes.",
    type: "prestataire_profile_incomplete",
  },
  missingMapLocation: {
    title: "MadBeauty Pro",
    body:
      "Vérifie ton adresse professionnelle pour apparaître sur la carte MadBeauty.",
    type: "prestataire_map_missing",
  },
  needsSubscription: {
    title: "MadBeauty Pro",
    body:
      "Ton profil est masqué du catalogue. Active ton abonnement pour être visible des clientes.",
    type: "prestataire_catalog_visibility",
  },
};

async function rpcBool(
  client: ReturnType<typeof serviceClient>,
  fn: string,
  prestataireId: string,
): Promise<boolean> {
  const { data, error } = await client.rpc(fn, {
    p_prestataire_id: prestataireId,
  });
  if (error) {
    console.error(`rpc ${fn}:`, error);
    return false;
  }
  return data === true;
}

async function resolveReason(
  client: ReturnType<typeof serviceClient>,
  prestataireId: string,
): Promise<NudgeReason | null> {
  const professionallyComplete = await rpcBool(
    client,
    "prestataire_is_professionally_complete",
    prestataireId,
  );
  if (!professionallyComplete) return "incompleteProfile";

  const catalogVisible = await rpcBool(
    client,
    "prestataire_is_catalog_visible",
    prestataireId,
  );
  if (!catalogVisible) return "needsSubscription";

  const mapVisible = await rpcBool(
    client,
    "prestataire_is_map_visible",
    prestataireId,
  );
  if (!mapVisible) return "missingMapLocation";

  return null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const supabase = serviceClient();

    const { data: presta, error } = await supabase
      .from("prestataire_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();

    if (error) throw error;
    if (!presta?.id) {
      return jsonResponse({ ok: true, skipped: true, reason: "no_prestataire" });
    }

    const prestataireId = String(presta.id);
    const reason = await resolveReason(supabase, prestataireId);
    if (reason == null) {
      return jsonResponse({ ok: true, skipped: true, reason: "already_visible" });
    }

    const notifyClient = createServiceClient();
    const token = await fetchFcmTokenForPrestataireProfileId(
      notifyClient,
      prestataireId,
    );
    if (!token) {
      return jsonResponse({ ok: true, skipped: true, reason: "no_fcm_token" });
    }

    const message = MESSAGES[reason];
    await sendFcmNotification({
      token,
      title: message.title,
      body: message.body,
      data: {
        type: message.type,
        reason,
        prestataire_id: prestataireId,
      },
    });

    return jsonResponse({ ok: true, sent: true, reason });
  } catch (e) {
    console.error(e);
    return jsonResponse({ ok: false, error: String(e) }, 500);
  }
});
