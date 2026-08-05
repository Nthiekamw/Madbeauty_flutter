/**
 * Synchronise les prix d'abonnement prestataire MadBeauty vers Stripe
 * et (optionnel) les secrets Supabase STRIPE_PRICE_*.
 *
 * Les Price Stripe sont immuables : le script crée / réutilise des prix
 * aux montants cibles, puis pointe les secrets dessus.
 *
 * Prérequis :
 *   - STRIPE_SECRET_KEY (sk_test_… ou sk_live_…)
 *   - Node 18+
 *   - Pour --apply-secrets : `npx supabase` lié au projet
 *
 * Exemples :
 *   $env:STRIPE_SECRET_KEY="sk_test_..."
 *   node scripts/stripe_sync_subscription_prices.mjs
 *   node scripts/stripe_sync_subscription_prices.mjs --apply-secrets
 *   node scripts/stripe_sync_subscription_prices.mjs --apply-secrets --archive-old
 *   node scripts/stripe_sync_subscription_prices.mjs --migrate-subscribers --yes
 *
 * Montants = lib/core/config/prestataire_subscription_config.dart
 */

import { spawnSync } from 'node:child_process';
import process from 'node:process';

/** Grille cible — garder alignée avec prestataire_subscription_config.dart */
const CATALOG = [
  {
    secret: 'STRIPE_PRICE_SOLO_MONTHLY',
    tier: 'solo',
    interval: 'month',
    unitAmountCents: 1800, // 18,00 €
    productName: 'MadBeauty Pro — 1 service',
    productDescription: 'Abonnement MadBeauty pour 1 service publié',
  },
  {
    secret: 'STRIPE_PRICE_SOLO_YEARLY',
    tier: 'solo',
    interval: 'year',
    unitAmountCents: 18000, // 180,00 €
    productName: 'MadBeauty Pro — 1 service',
    productDescription: 'Abonnement MadBeauty pour 1 service publié',
  },
  {
    secret: 'STRIPE_PRICE_MULTI_MONTHLY',
    tier: 'multi',
    interval: 'month',
    unitAmountCents: 2499, // 24,99 €
    productName: 'MadBeauty Pro — 2+ services',
    productDescription: 'Abonnement MadBeauty pour 2 services publiés ou plus',
  },
  {
    secret: 'STRIPE_PRICE_MULTI_YEARLY',
    tier: 'multi',
    interval: 'year',
    unitAmountCents: 25000, // 250,00 €
    productName: 'MadBeauty Pro — 2+ services',
    productDescription: 'Abonnement MadBeauty pour 2 services publiés ou plus',
  },
];

const args = new Set(process.argv.slice(2));
const APPLY_SECRETS = args.has('--apply-secrets');
const ARCHIVE_OLD = args.has('--archive-old');
const MIGRATE = args.has('--migrate-subscribers');
const YES = args.has('--yes');
const DRY_RUN = args.has('--dry-run');

const STRIPE_KEY = (process.env.STRIPE_SECRET_KEY || '').trim();
if (!STRIPE_KEY.startsWith('sk_')) {
  console.error(
    'STRIPE_SECRET_KEY manquant ou invalide (attendu sk_test_… / sk_live_…).',
  );
  process.exit(1);
}

const mode = STRIPE_KEY.startsWith('sk_live_') ? 'LIVE' : 'TEST';
console.log(`Stripe mode: ${mode}`);
if (mode === 'LIVE' && !YES && !DRY_RUN) {
  console.error(
    'Mode LIVE détecté. Relance avec --yes pour confirmer (ou --dry-run).',
  );
  process.exit(1);
}

async function stripeForm(method, path, params = {}) {
  const body = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v === undefined || v === null) continue;
    body.append(k, String(v));
  }
  const res = await fetch(`https://api.stripe.com/v1${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${STRIPE_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: method === 'GET' ? undefined : body,
  });
  const json = await res.json();
  if (!res.ok) {
    const msg = json?.error?.message || JSON.stringify(json);
    throw new Error(`Stripe ${method} ${path}: ${msg}`);
  }
  return json;
}

async function stripeGet(path, query = {}) {
  const qs = new URLSearchParams(query).toString();
  const url = qs ? `${path}?${qs}` : path;
  const res = await fetch(`https://api.stripe.com/v1${url}`, {
    headers: { Authorization: `Bearer ${STRIPE_KEY}` },
  });
  const json = await res.json();
  if (!res.ok) {
    const msg = json?.error?.message || JSON.stringify(json);
    throw new Error(`Stripe GET ${path}: ${msg}`);
  }
  return json;
}

async function findOrCreateProduct(tier, name, description) {
  const listed = await stripeGet('/products', { limit: '100', active: 'true' });
  const byMeta = (listed.data || []).find(
    (p) => p.metadata?.madbeauty_tier === tier,
  );
  if (byMeta) return byMeta;

  const byName = (listed.data || []).find((p) => p.name === name);
  if (byName) {
    if (!DRY_RUN) {
      await stripeForm('POST', `/products/${byName.id}`, {
        'metadata[madbeauty_tier]': tier,
      });
    }
    return byName;
  }

  if (DRY_RUN) {
    console.log(`[dry-run] créer produit ${name}`);
    return { id: `prod_dry_${tier}`, name };
  }

  return stripeForm('POST', '/products', {
    name,
    description,
    'metadata[madbeauty_tier]': tier,
  });
}

async function listPricesForProduct(productId) {
  const out = [];
  let startingAfter;
  for (;;) {
    const query = {
      product: productId,
      limit: '100',
      active: 'true',
    };
    if (startingAfter) query.starting_after = startingAfter;
    const page = await stripeGet('/prices', query);
    out.push(...(page.data || []));
    if (!page.has_more || !(page.data || []).length) break;
    startingAfter = page.data[page.data.length - 1].id;
  }
  return out;
}

function matchesTarget(price, unitAmountCents, interval) {
  return (
    price.currency === 'eur' &&
    price.type === 'recurring' &&
    price.unit_amount === unitAmountCents &&
    price.recurring?.interval === interval
  );
}

async function ensurePrice(productId, unitAmountCents, interval, tier) {
  if (DRY_RUN && String(productId).startsWith('prod_dry_')) {
    console.log(
      `  [dry-run] créer price ${(unitAmountCents / 100).toFixed(2)} € / ${interval}`,
    );
    return {
      price: { id: `price_dry_${tier}_${interval}` },
      created: true,
      siblings: [],
    };
  }

  const existing = await listPricesForProduct(productId);
  const hit = existing.find((p) =>
    matchesTarget(p, unitAmountCents, interval),
  );
  if (hit) {
    console.log(
      `  réutilise ${hit.id} (${(unitAmountCents / 100).toFixed(2)} € / ${interval})`,
    );
    return { price: hit, created: false, siblings: existing };
  }

  if (DRY_RUN) {
    console.log(
      `  [dry-run] créer price ${(unitAmountCents / 100).toFixed(2)} € / ${interval}`,
    );
    return {
      price: { id: `price_dry_${tier}_${interval}` },
      created: true,
      siblings: existing,
    };
  }

  const price = await stripeForm('POST', '/prices', {
    product: productId,
    currency: 'eur',
    unit_amount: String(unitAmountCents),
    'recurring[interval]': interval,
    'metadata[madbeauty_tier]': tier,
    'metadata[madbeauty_interval]': interval,
  });
  console.log(
    `  créé ${price.id} (${(unitAmountCents / 100).toFixed(2)} € / ${interval})`,
  );
  return { price, created: true, siblings: existing };
}

function applySupabaseSecrets(mapping) {
  const pairs = Object.entries(mapping).map(([k, v]) => `${k}=${v}`);
  console.log('\nApplication des secrets Supabase…');
  const result = spawnSync(
    'npx',
    ['supabase', 'secrets', 'set', ...pairs],
    { stdio: 'inherit', shell: true },
  );
  if (result.status !== 0) {
    throw new Error('supabase secrets set a échoué');
  }
}

async function archiveOldPrices(productId, keepIds) {
  const prices = await listPricesForProduct(productId);
  for (const p of prices) {
    if (keepIds.has(p.id)) continue;
    if (DRY_RUN) {
      console.log(`  [dry-run] archiver ${p.id}`);
      continue;
    }
    await stripeForm('POST', `/prices/${p.id}`, { active: 'false' });
    console.log(`  archivé ${p.id}`);
  }
}

async function migrateSubscribers(oldToNew) {
  console.log('\nMigration des abonnements actifs vers les nouveaux prix…');
  let startingAfter;
  let migrated = 0;
  for (;;) {
    const page = await stripeGet('/subscriptions', {
      status: 'active',
      limit: '100',
      ...(startingAfter ? { starting_after: startingAfter } : {}),
    });

    for (const sub of page.data || []) {
      const itemsPage = await stripeGet('/subscription_items', {
        subscription: sub.id,
        limit: '10',
      });
      const item = itemsPage.data?.[0];
      if (!item?.price) continue;
      const oldPriceId =
        typeof item.price === 'string' ? item.price : item.price.id;
      const newPriceId = oldToNew.get(oldPriceId);
      if (!newPriceId || newPriceId === oldPriceId) continue;

      console.log(`  ${sub.id}: ${oldPriceId} → ${newPriceId}`);
      if (DRY_RUN) continue;

      await stripeForm('POST', `/subscriptions/${sub.id}`, {
        'items[0][id]': item.id,
        'items[0][price]': newPriceId,
        proration_behavior: 'create_prorations',
      });
      migrated += 1;
    }

    if (!page.has_more || !(page.data || []).length) break;
    startingAfter = page.data[page.data.length - 1].id;
  }
  console.log(`Migrations effectuées: ${migrated}`);
}

async function main() {
  const secretToPrice = {};
  const productKeep = new Map(); // productId -> Set<priceId>
  const oldPriceCandidates = new Map(); // oldPriceId -> newPriceId (best effort)

  const byTier = {
    solo: CATALOG.filter((c) => c.tier === 'solo'),
    multi: CATALOG.filter((c) => c.tier === 'multi'),
  };

  for (const [tier, entries] of Object.entries(byTier)) {
    const sample = entries[0];
    console.log(`\nProduit ${tier}…`);
    const product = await findOrCreateProduct(
      tier,
      sample.productName,
      sample.productDescription,
    );
    console.log(`  product ${product.id} (${product.name})`);

    const keep = productKeep.get(product.id) || new Set();
    productKeep.set(product.id, keep);

    const before = await listPricesForProduct(product.id);

    for (const entry of entries) {
      const { price, siblings } = await ensurePrice(
        product.id,
        entry.unitAmountCents,
        entry.interval,
        entry.tier,
      );
      secretToPrice[entry.secret] = price.id;
      keep.add(price.id);

      for (const old of siblings.length ? siblings : before) {
        if (
          old.id !== price.id &&
          old.recurring?.interval === entry.interval &&
          old.currency === 'eur'
        ) {
          oldPriceCandidates.set(old.id, price.id);
        }
      }
    }
  }

  console.log('\n=== Mapping secrets ===');
  for (const [k, v] of Object.entries(secretToPrice)) {
    console.log(`${k}=${v}`);
  }

  if (APPLY_SECRETS) {
    if (DRY_RUN) {
      console.log('[dry-run] skip --apply-secrets');
    } else {
      applySupabaseSecrets(secretToPrice);
    }
  } else {
    console.log(
      '\nPour pousser vers Supabase :\n  node scripts/stripe_sync_subscription_prices.mjs --apply-secrets',
    );
    console.log('ou :');
    console.log(
      `  npx supabase secrets set ${Object.entries(secretToPrice)
        .map(([k, v]) => `${k}=${v}`)
        .join(' ')}`,
    );
  }

  if (ARCHIVE_OLD) {
    console.log('\nArchivage des anciens prix…');
    for (const [productId, keepIds] of productKeep) {
      await archiveOldPrices(productId, keepIds);
    }
  }

  if (MIGRATE) {
    if (!YES && !DRY_RUN) {
      console.error(
        'Migration abonnés : ajoute --yes (ou --dry-run) pour confirmer.',
      );
      process.exit(1);
    }
    await migrateSubscribers(oldPriceCandidates);
  }

  console.log('\nTerminé. Rebuild / redeploy l’app pour l’affichage des montants.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
