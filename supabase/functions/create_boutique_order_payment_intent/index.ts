import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { accountCanAcceptPayments } from "../_shared/stripe_connect.ts";
import {
  ensureStripeCustomer,
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";

interface CartLineBody {
  produitId?: string;
  quantite?: number;
}

interface Body {
  prestataireId?: string;
  lines?: CartLineBody[];
  notesClient?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user, supabase: userSb } = await requireAuthUser(req);
    const body = (await req.json()) as Body;
    const prestataireId = String(body.prestataireId ?? "").trim();
    const lines = Array.isArray(body.lines) ? body.lines : [];
    const notesClient = String(body.notesClient ?? "").trim();

    if (!prestataireId || lines.length === 0) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    const { data: ownPresta } = await admin
      .from("prestataire_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (ownPresta?.id === prestataireId) {
      return jsonResponse({ error: "Achat sur son propre profil interdit" }, 403);
    }

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select(
        "stripe_connect_account_id, stripe_connect_charges_enabled, nom_salon",
      )
      .eq("id", prestataireId)
      .maybeSingle();

    const connectAccountId = prestataire?.stripe_connect_account_id as
      | string
      | undefined;
    const chargesEnabled = prestataire?.stripe_connect_charges_enabled === true;
    if (!connectAccountId?.startsWith("acct_") || !chargesEnabled) {
      return jsonResponse(
        {
          error: "Ce salon n’accepte pas encore les paiements en ligne.",
          code: "prestataire_not_payable",
        },
        400,
      );
    }

    const connectAccount = await stripe.accounts.retrieve(connectAccountId);
    if (!accountCanAcceptPayments(connectAccount)) {
      return jsonResponse(
        {
          error: "Compte Stripe Connect non prêt pour encaisser.",
          code: "prestataire_not_payable",
        },
        400,
      );
    }

    // Création + décrément stock atomique (RPC, JWT utilisateur).
    const { data: created, error: rpcErr } = await userSb.rpc(
      "create_boutique_commande_from_cart",
      {
        p_payload: {
          prestataire_id: prestataireId,
          pay_on_site: false,
          notes_client: notesClient || null,
          items: lines.map((l) => ({
            produit_id: String(l.produitId ?? "").trim(),
            quantite: Math.max(1, Math.floor(Number(l.quantite ?? 1))),
          })),
        },
      },
    );

    if (rpcErr || !created) {
      const msg = rpcErr?.message?.trim() || "Création commande impossible";
      return jsonResponse({ error: msg }, 400);
    }

    const map = created as Record<string, unknown>;
    const commandeId = String(map.commande_id ?? "");
    const amountCents = Number(map.amount_cents ?? 0);
    if (!commandeId || amountCents < 50) {
      if (commandeId) {
        await admin
          .from("boutique_commandes")
          .update({
            statut: "canceled",
            payment_status: "failed",
          })
          .eq("id", commandeId);
      }
      return jsonResponse({ error: "Montant trop faible" }, 400);
    }

    const { data: clientRow } = await admin
      .from("client_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (!clientRow?.id) {
      return jsonResponse({ error: "Profil client manquant" }, 403);
    }
    const clientId = clientRow.id as string;

    const customerId = await ensureStripeCustomer(
      admin,
      stripe,
      clientId,
      user.id,
      user.email,
    );

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: "2024-11-20.acacia" },
    );

    let pi;
    try {
      pi = await stripe.paymentIntents.create({
        amount: amountCents,
        currency: "eur",
        customer: customerId,
        capture_method: "automatic",
        transfer_data: { destination: connectAccountId },
        metadata: {
          madbeauty_type: "boutique_order",
          commande_id: commandeId,
          client_id: clientId,
          prestataire_id: prestataireId,
          supabase_user_id: user.id,
        },
      });
    } catch (e) {
      await admin
        .from("boutique_commandes")
        .update({
          statut: "canceled",
          payment_status: "failed",
        })
        .eq("id", commandeId);
      throw e;
    }

    await admin
      .from("boutique_commandes")
      .update({ stripe_payment_intent_id: pi.id })
      .eq("id", commandeId);

    return jsonResponse({
      commandeId,
      paymentIntentId: pi.id,
      paymentIntentClientSecret: pi.client_secret,
      customerId,
      ephemeralKey: ephemeralKey.secret,
      amountCents,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error("create_boutique_order_payment_intent", e);
    return jsonResponse({ error: "Erreur serveur" }, 500);
  }
});
