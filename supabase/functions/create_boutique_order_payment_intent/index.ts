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
    const { user } = await requireAuthUser(req);
    const body = (await req.json()) as Body;
    const prestataireId = String(body.prestataireId ?? "").trim();
    const lines = Array.isArray(body.lines) ? body.lines : [];
    const notesClient = String(body.notesClient ?? "").trim();

    if (!prestataireId || lines.length === 0) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    // Nettoie les pending Stripe abandonnés (create-before-pay).
    await admin.rpc("expire_stale_boutique_pending_orders");

    const { data: clientRow } = await admin
      .from("client_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (!clientRow?.id) {
      return jsonResponse({ error: "Profil client manquant" }, 403);
    }
    const clientId = clientRow.id as string;

    const { data: ownPresta } = await admin
      .from("prestataire_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (ownPresta?.id === prestataireId) {
      return jsonResponse({ error: "Achat sur son propre profil interdit" }, 403);
    }

    const produitIds = [
      ...new Set(
        lines
          .map((l) => String(l.produitId ?? "").trim())
          .filter((id) => id.length > 0),
      ),
    ];

    const { data: produits } = await admin
      .from("produits_boutique")
      .select("id, nom, conditionnement, prix, is_actif, prestataire_id")
      .in("id", produitIds)
      .eq("prestataire_id", prestataireId)
      .eq("is_actif", true);

    const byId = new Map(
      (produits ?? []).map((p) => [p.id as string, p]),
    );

    const itemRows: Array<Record<string, unknown>> = [];
    let amountCents = 0;
    for (const line of lines) {
      const produitId = String(line.produitId ?? "").trim();
      const quantite = Math.max(1, Math.floor(Number(line.quantite ?? 1)));
      const produit = byId.get(produitId);
      if (!produit) {
        return jsonResponse(
          { error: `Produit indisponible (${produitId})` },
          400,
        );
      }
      const prixCents = Math.round(Number(produit.prix) * 100);
      amountCents += prixCents * quantite;
      itemRows.push({
        produit_id: produitId,
        nom_snapshot: String(produit.nom ?? ""),
        conditionnement_snapshot: produit.conditionnement ?? null,
        prix_cents: prixCents,
        quantite,
      });
    }

    if (amountCents < 50) {
      return jsonResponse({ error: "Montant trop faible" }, 400);
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

    const { data: commande, error: commandeErr } = await admin
      .from("boutique_commandes")
      .insert({
        client_id: clientId,
        prestataire_id: prestataireId,
        statut: "pending_payment",
        payment_status: "pending",
        amount_cents: amountCents,
        currency: "eur",
        fulfillment: "pickup",
        notes_client: notesClient || null,
      })
      .select("id")
      .single();

    if (commandeErr || !commande?.id) {
      return jsonResponse({ error: "Création commande impossible" }, 500);
    }

    const commandeId = commande.id as string;
    const { error: itemsErr } = await admin.from("boutique_commande_items")
      .insert(
        itemRows.map((row) => ({ ...row, commande_id: commandeId })),
      );
    if (itemsErr) {
      await admin.from("boutique_commandes").delete().eq("id", commandeId);
      return jsonResponse({ error: "Lignes commande invalides" }, 500);
    }

    const pi = await stripe.paymentIntents.create({
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
