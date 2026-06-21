/**
 * Génère web/admin/config.js pour le back-office (local ou build Netlify).
 * Variables : SUPABASE_URL, SUPABASE_ANON_KEY (env ou fichier .env à la racine).
 */
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const outFile = path.join(root, 'web', 'admin', 'config.js');

function loadDotEnv(filePath) {
  const vars = {};
  if (!fs.existsSync(filePath)) return vars;
  for (const line of fs.readFileSync(filePath, 'utf8').split(/\r?\n/)) {
    if (!line || /^\s*#/.test(line) || !line.includes('=')) continue;
    const idx = line.indexOf('=');
    const key = line.slice(0, idx).trim();
    let val = line.slice(idx + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    vars[key] = val;
  }
  return vars;
}

const envFile = loadDotEnv(path.join(root, '.env'));
const url = process.env.SUPABASE_URL || envFile.SUPABASE_URL;
const key = process.env.SUPABASE_ANON_KEY || envFile.SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error(
    'Erreur : SUPABASE_URL et SUPABASE_ANON_KEY requis (variables Netlify ou .env).',
  );
  process.exit(1);
}

const content = `/** Généré par scripts/generate_web_admin_config.js — ne pas éditer à la main. */
window.MADBEAUTY_ADMIN_CONFIG = {
  supabaseUrl: ${JSON.stringify(url)},
  supabaseAnonKey: ${JSON.stringify(key)},
};
`;

fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, content, 'utf8');
console.log(`OK: ${outFile}`);
