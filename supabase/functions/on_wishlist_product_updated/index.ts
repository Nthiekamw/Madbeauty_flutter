import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  createServiceClient,
  fetchFcmTokenForClientProfileId,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }
  if (!verifyWebhookSecret(req)) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  try {
    const payload = (await req.json()) as WebhookPayload & {
      restock?: boolean;
      price_drop?: boolean;
    };
    const record = payload.record ?? {};
    const productId = String(record["id"] ?? "");
    const productName = String(record["nom"] ?? "Produit");
    const newPrice = Number(record["prix"] ?? 0);
    const restock = payload.restock === true;
    const priceDrop = payload.price_drop === true;

    if (!productId || (!restock && !priceDrop)) {
      return jsonResponse({ ok: true, skipped: true });
    }

    const admin = createServiceClient();
    let query = admin
      .from("wishlist_produits")
      .select("client_id, alert_on_restock, alert_on_price_drop, last_seen_price")
      .eq("produit_id", productId);

    const { data: rows, error } = await query;
    if (error) {
      console.error(error);
      return jsonResponse({ error: error.message }, 500);
    }

    let sent = 0;
    for (const row of rows ?? []) {
      const clientId = String(row.client_id ?? "");
      if (!clientId) continue;

      const wantRestock = row.alert_on_restock === true && restock;
      const wantDrop = row.alert_on_price_drop === true && priceDrop &&
        Number(row.last_seen_price ?? 0) > newPrice;

      if (!wantRestock && !wantDrop) continue;

      const token = await fetchFcmTokenForClientProfileId(admin, clientId);
      if (!token) continue;

      const title = wantRestock
        ? "De retour en stock"
        : "Baisse de prix";
      const body = wantRestock
        ? `${productName} est à nouveau disponible sur MadBeauty.`
        : `${productName} a baissé de prix.`;

      await sendFcmNotification({
        token,
        title,
        body,
        data: {
          type: wantRestock ? "wishlist_restock" : "wishlist_price_drop",
          produit_id: productId,
        },
      });
      sent++;

      await admin.from("wishlist_produits").update({
        last_seen_price: newPrice,
      }).eq("client_id", clientId).eq("produit_id", productId);
    }

    return jsonResponse({ ok: true, sent });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
