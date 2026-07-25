// Données partagées (var = global entre ui.js et live.js)
var USERS = [], RDV_DATA = [], PAYMENTS = [], FEEDBACKS = [], CHATS = [];
var PAYS_DATA = [], ZONES = [];
var userListFilter = { type: 'all', status: 'all', query: '' };

// ─── BLUR ───────────────────────────────────────────────────
let blurred = false;
function toggleBlur() {
  blurred = !blurred;
  document.querySelectorAll('.blur-val').forEach(el => {
    el.style.filter = blurred ? 'blur(6px)' : '';
    el.style.userSelect = blurred ? 'none' : '';
  });
  document.getElementById('blur-icon').className = blurred ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye';
  document.getElementById('blur-label').textContent = blurred ? 'Afficher montants' : 'Masquer montants';
}

// ─── NAVIGATION ─────────────────────────────────────────────
const sectionTitles = {
  dashboard:'Tableau de bord', users:'Utilisateurs', clients:'Clients',
  presta:'Prestataires', rdv:'Rendez-vous', zones:'Zones géographiques',
  finance:'Finances', forfaits:'Forfaits', messages:'Messagerie', feedback:'Retours',
  'pays-users':'Utilisateurs par pays', 'pays-revenue':'Revenus par pays',
  verifications:'Vérifications', 'content-reports':'Signalements contenu',
  photos:'Photos réalisations', audit:'Journal audit', push:'Notifications push',
  trial:'Essai catalogue', 'platform-fee':'Commission RDV',
};

function showSection(id, el) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.getElementById('sec-'+id).classList.add('active');
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  if(el) el.classList.add('active');
  document.getElementById('topbar-title').textContent = sectionTitles[id] || id;
  if(id === 'pays-users') setTimeout(renderPaysUsers, 0);
  if(id === 'pays-revenue') setTimeout(renderPaysRevenue, 0);
  if (id === 'users') {
    resetUsersListFilters();
    applyUserFilters();
  }
  if (id === 'clients' || id === 'presta') {
    applyUserFilters();
  }
  if (id === 'push') {
    renderPushTemplates();
  }
  if (id === 'forfaits') {
    setTimeout(() => {
      if (typeof renderPrestataireSubscriptions === 'function') renderPrestataireSubscriptions();
      else if (window.MBLive?.searchSubscriptions) window.MBLive.searchSubscriptions();
    }, 0);
  }
}

function resetUsersListFilters() {
  userListFilter.type = 'all';
  userListFilter.status = 'all';
  const typeSel = document.getElementById('users-filter-type');
  const statusSel = document.getElementById('users-filter-status');
  if (typeSel) typeSel.value = 'all';
  if (statusSel) statusSel.value = 'all';
}

function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('open');
}

// ─── TOAST ──────────────────────────────────────────────────
function showToast(msg) {
  const t = document.getElementById('toast');
  document.getElementById('toast-msg').textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 3000);
}

// ─── MODAL ──────────────────────────────────────────────────
function escapeHtml(s) {
  return String(s || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function openModalShell({ title, bodyHtml, footerHtml, variant }) {
  const box = document.getElementById('modal-box');
  const footer = document.getElementById('modal-footer');
  if (box) box.className = variant ? `modal modal--${variant}` : 'modal';
  document.getElementById('modal-title').textContent = title;
  document.getElementById('modal-body').innerHTML = bodyHtml;
  if (footer) {
    footer.innerHTML = footerHtml || '<button type="button" class="btn btn-outline" onclick="closeModal()">Fermer</button>';
  }
  document.getElementById('modal-overlay').classList.add('open');
}

function closeModal() {
  document.getElementById('modal-overlay').classList.remove('open');
  const box = document.getElementById('modal-box');
  if (box) box.className = 'modal';
}

function openBanModal(userId) {
  const u = USERS.find((x) => x.id === userId);
  if (!u) { showToast('Utilisateur introuvable'); return; }
  openModalShell({
    title: 'Bannissement',
    variant: 'danger',
    bodyHtml: `
      <div class="modal-alert modal-alert--danger">
        <div class="modal-alert-icon"><i class="fa-solid fa-ban"></i></div>
        <div>
          <div class="modal-alert-title">Bannir cet utilisateur ?</div>
          <div class="modal-alert-sub">${escapeHtml(u.name)} · ${escapeHtml(u.email)}</div>
        </div>
      </div>
      <p class="modal-hint">L'utilisateur ne pourra plus se connecter. Le motif est enregistré dans le journal d'audit.</p>
      <div class="form-group" style="margin-bottom:0;">
        <label class="form-label" for="ban-reason-input">Motif du bannissement <span class="required">*</span></label>
        <textarea id="ban-reason-input" class="form-input form-textarea" rows="4" placeholder="Ex. : signalements répétés, fraude, contenu inapproprié…"></textarea>
        <div class="form-error" id="ban-reason-error" hidden>Motif obligatoire.</div>
      </div>`,
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-danger" id="ban-confirm-btn" onclick="submitBanModal('${u.id}')"><i class="fa-solid fa-ban"></i> Confirmer le bannissement</button>`,
  });
  const input = document.getElementById('ban-reason-input');
  input?.addEventListener('input', () => {
    input.classList.remove('input-error');
    const err = document.getElementById('ban-reason-error');
    if (err) err.hidden = true;
  });
  input?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      submitBanModal(userId);
    }
  });
  setTimeout(() => input?.focus(), 60);
}

function submitBanModal(userId) {
  const input = document.getElementById('ban-reason-input');
  const err = document.getElementById('ban-reason-error');
  const reason = input?.value?.trim() || '';
  if (!reason) {
    if (err) err.hidden = false;
    input?.classList.add('input-error');
    input?.focus();
    return;
  }
  if (typeof MBLive?.confirmBan === 'function') MBLive.confirmBan(userId, reason);
}

function openUnbanModal(userId) {
  const u = USERS.find((x) => x.id === userId);
  if (!u) { showToast('Utilisateur introuvable'); return; }
  openModalShell({
    title: 'Lever le bannissement',
    bodyHtml: `
      <div class="modal-alert modal-alert--danger" style="background:rgba(26,107,60,.08);border-color:rgba(26,107,60,.18);">
        <div class="modal-alert-icon" style="background:rgba(26,107,60,.14);color:var(--success);"><i class="fa-solid fa-unlock"></i></div>
        <div>
          <div class="modal-alert-title">Réactiver cet utilisateur ?</div>
          <div class="modal-alert-sub">${escapeHtml(u.name)} · ${escapeHtml(u.email)}</div>
        </div>
      </div>
      ${u.banReason ? `<p class="modal-hint"><strong>Motif actuel :</strong> ${escapeHtml(u.banReason)}</p>` : ''}
      <p class="modal-hint" style="margin-bottom:0;">L'utilisateur pourra à nouveau se connecter et utiliser l'application.</p>`,
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-primary" onclick="MBLive.confirmUnban('${u.id}')"><i class="fa-solid fa-unlock"></i> Débannir</button>`,
  });
}

function fmtUserDateTime(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return d.toLocaleString('fr-FR', {
    day: 'numeric', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

function fmtUserDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' });
}

function formatCityName(value) {
  const trimmed = String(value ?? '').trim();
  if (!trimmed) return '';

  const capitalizeToken = (token) => {
    if (!token) return token;
    const lower = token.toLowerCase();
    let out = '';
    let upperNext = true;
    for (const c of lower) {
      if (upperNext && /[a-zàâäéèêëïîôùûüç]/i.test(c)) {
        out += c.toUpperCase();
        upperNext = false;
      } else {
        out += c;
        if (c === "'") upperNext = true;
      }
    }
    return out;
  };

  return trimmed
    .split(/\s+/)
    .map((word) => word.split('-').map(capitalizeToken).join('-'))
    .join(' ');
}

function formatStreetLine({ adresse, numero, voieType, voieNom } = {}) {
  const raw = String(adresse ?? '').trim();
  if (raw.includes(',')) {
    const street = raw.split(',')[0].trim();
    if (street) return street;
  }
  if (raw) return raw;
  const built = [numero, voieType, voieNom].filter(Boolean).join(' ').trim();
  return built || '—';
}

function formatAddressLine({
  adresse,
  numero,
  voieType,
  voieNom,
  codePostal,
  ville,
  pays,
} = {}) {
  const raw = String(adresse ?? '').trim();
  if (raw.includes(',')) {
    const parts = raw.split(',').map((s) => s.trim()).filter(Boolean);
    if (pays && pays.length === 2) {
      const paysUpper = pays.toUpperCase();
      const hasPays = parts.some((p) => p.toUpperCase() === paysUpper);
      if (!hasPays) parts.push(paysUpper);
    }
    return parts.join(' · ');
  }
  const street = formatStreetLine({ adresse: raw, numero, voieType, voieNom });
  const locality = [codePostal, formatCityName(ville)].filter(Boolean).join(' ').trim();
  const parts = [street === '—' ? '' : street, locality, pays].filter((p) => p && String(p).trim());
  return parts.length ? parts.join(' · ') : '—';
}

function profileCompletenessBadge(isComplete, isVisible) {
  if (isComplete === null || isComplete === undefined) {
    return '<span style="color:var(--text3);">—</span>';
  }
  if (isComplete && isVisible) {
    return '<span class="badge active">Visible catalogue</span>';
  }
  if (isComplete) {
    return '<span class="badge pending">Complet · non visible</span>';
  }
  return '<span class="badge inactive">Incomplet</span>';
}

function renderMissingLabelsList(labels, { compact = false } = {}) {
  const items = (labels || []).filter(Boolean);
  if (!items.length) {
    return compact
      ? '<span style="color:var(--text3);font-size:12px;">Rien à signaler</span>'
      : userDetailRow('Éléments manquants', 'Aucun');
  }
  if (compact) {
    const preview = items.slice(0, 2).join(', ');
    const extra = items.length > 2 ? ` (+${items.length - 2})` : '';
    return `<span style="font-size:12px;color:var(--text2);" title="${escapeHtml(items.join(' · '))}">${escapeHtml(preview + extra)}</span>`;
  }
  const list = items.map((item) => `<li>${escapeHtml(item)}</li>`).join('');
  return `<div class="user-detail-row user-detail-row--full">
    <div class="user-detail-label">Éléments manquants</div>
    <div class="user-detail-value"><ul class="completeness-missing">${list}</ul></div>
  </div>`;
}

function userDetailRow(label, value, { mono = false, empty = '—' } = {}) {
  const v = value == null || String(value).trim() === '' ? empty : String(value);
  return `<div class="user-detail-row">
    <div class="user-detail-label">${escapeHtml(label)}</div>
    <div class="user-detail-value${mono ? ' user-detail-value--mono' : ''}">${escapeHtml(v)}</div>
  </div>`;
}

function userDetailSection(title, icon, rowsHtml) {
  if (!rowsHtml) return '';
  return `<section class="user-detail-section">
    <div class="user-detail-section-title"><i class="fa-solid ${icon}"></i> ${escapeHtml(title)}</div>
    <div class="user-detail-grid">${rowsHtml}</div>
  </section>`;
}

function renderUserDetailBody(u, details) {
  const profile = details?.profile || {};
  const roles = Array.isArray(details?.roles)
    ? details.roles.map((r) => (typeof r === 'string' ? r : String(r))).filter(Boolean)
    : (u.roles || []);
  const client = details?.client_profile;
  const presta = details?.prestataire_profile;
  const providers = Array.isArray(details?.auth_providers) ? details.auth_providers : [];
  const isActive = u.status === 'active';
  const displayName = [profile.prenom, profile.nom].filter(Boolean).join(' ').trim() || u.name;
  const avatarHtml = profile.avatar_url
    ? `<img src="${escapeHtml(profile.avatar_url)}" alt="" class="user-detail-avatar-img">`
    : `<div class="user-detail-avatar-fallback">${initials(displayName)}</div>`;

  const rolesHtml = roles.length
    ? roles.map((r) => `<span class="badge pro" style="margin-right:6px;">${escapeHtml(r)} <button type="button" class="btn btn-outline btn-sm" style="padding:0 4px;margin-left:4px;" onclick="MBLive.removeRole('${u.id}','${r}')">×</button></span>`).join('')
    : '<span style="color:var(--text3);">Aucun rôle</span>';

  const accountRows = [
    userDetailRow('Prénom', profile.prenom || u.prenom),
    userDetailRow('Nom', profile.nom || u.nom),
    userDetailRow('E-mail', details?.email || u.email),
    userDetailRow('Téléphone', profile.telephone || u.phone),
    userDetailRow('Inscription', fmtUserDateTime(details?.created_at || u.createdAt)),
    userDetailRow('Dernière connexion', fmtUserDateTime(details?.last_sign_in_at || u.lastSignInAt)),
    userDetailRow('Dernière activité', fmtUserDateTime(profile.last_seen_at)),
    userDetailRow('E-mail confirmé', details?.email_confirmed_at ? fmtUserDateTime(details.email_confirmed_at) : 'Non'),
    userDetailRow('Notifications push', profile.has_fcm_token || u.hasFcmToken ? 'Token actif' : 'Aucun token'),
    userDetailRow('ID utilisateur', details?.user_id || u.id, { mono: true }),
  ].join('');

  const statusRows = [
    userDetailRow('Statut compte', isActive ? 'Actif' : 'Banni'),
    userDetailRow('Type affiché', u.type),
    ...(u.banReason || profile.ban_reason ? [userDetailRow('Motif ban', u.banReason || profile.ban_reason)] : []),
    ...(u.bannedAt || profile.banned_at ? [userDetailRow('Banni le', fmtUserDateTime(u.bannedAt || profile.banned_at))] : []),
    userDetailRow('Profil client', client ? 'Oui' : (u.hasClientProfile ? 'Oui' : 'Non')),
    userDetailRow('Profil prestataire', presta ? 'Oui' : (u.hasPrestaProfile ? 'Oui' : 'Non')),
  ].join('');

  const clientRows = client ? [
    userDetailRow('Adresse', client.adresse),
    userDetailRow('Voie', [client.numero_rue, client.voie_type, client.voie_nom].filter(Boolean).join(' ').trim() || null),
    userDetailRow('Ville', formatCityName(client.ville || u.clientVille)),
    userDetailRow('Code postal', client.code_postal || u.clientCodePostal),
    userDetailRow('Pays', client.pays || u.clientPays),
    userDetailRow('Adresse complète', formatAddressLine({
      adresse: client.adresse,
      numero: client.numero_rue,
      voieType: client.voie_type,
      voieNom: client.voie_nom,
      codePostal: client.code_postal || u.clientCodePostal,
      ville: formatCityName(client.ville || u.clientVille),
      pays: client.pays || u.clientPays,
    })),
    userDetailRow('Réservations', client.reservations_count ?? '0'),
    userDetailRow('Stripe client', client.stripe_customer_id, { mono: true }),
    userDetailRow('Profil créé le', fmtUserDateTime(client.created_at)),
  ].join('') : '';

  const completeness = presta?.completeness || {};
  const missingLabels = Array.isArray(completeness.missing)
    ? completeness.missing
    : (u.prestaMissingLabels || []);

  const prestaRows = presta ? [
    userDetailRow('Salon', presta.nom_salon || u.prestaNomSalon),
    userDetailRow('Nom affiché', presta.nom_affiche),
    userDetailRow('Adresse', presta.adresse || u.prestaAdresse),
    userDetailRow('Ville', formatCityName(presta.ville || u.prestaVille)),
    userDetailRow('Code postal', presta.code_postal || u.prestaCodePostal),
    userDetailRow('Pays', presta.pays || u.prestaPays),
    userDetailRow('Lieu de travail', presta.lieu_travail),
    userDetailRow('Adresse complète', formatAddressLine({
      adresse: presta.adresse || u.prestaAdresse,
      codePostal: presta.code_postal || u.prestaCodePostal,
      ville: formatCityName(presta.ville || u.prestaVille),
      pays: presta.pays || u.prestaPays,
    })),
    userDetailRow('Description', presta.description),
    userDetailRow('Profil professionnel', completeness.is_professionally_complete ? 'Complet' : 'Incomplet'),
    userDetailRow('Visible catalogue', completeness.is_catalog_visible ? 'Oui' : 'Non'),
    userDetailRow('Accès catalogue', completeness.has_catalog_access ? 'Actif (abo ou essai)' : 'Expiré / absent'),
    userDetailRow('Spécialités', completeness.specialties_count ?? presta.specialties_count ?? '0'),
    userDetailRow('Services valides', completeness.valid_services_count ?? '—'),
    userDetailRow('Note moyenne', presta.note_moyenne != null ? `⭐ ${Number(presta.note_moyenne).toFixed(1)}` : '—'),
    userDetailRow('Vérifié', presta.is_verified ? 'Oui' : 'Non'),
    userDetailRow('Masqué catalogue', presta.is_hidden ? `Oui (${fmtUserDateTime(presta.hidden_at)})` : 'Non'),
    userDetailRow('Réservations', presta.reservations_count ?? '0'),
    userDetailRow('Services', presta.services_count ?? '0'),
    userDetailRow('Abonnement', presta.subscription_status || 'none'),
    userDetailRow('Palier', presta.subscription_tier ? `${presta.subscription_tier} / ${presta.subscription_interval || '—'}` : '—'),
    userDetailRow('Fin période abo.', fmtUserDateTime(presta.subscription_current_period_end)),
    userDetailRow('Essai catalogue', fmtUserDateTime(presta.catalog_trial_ends_at)),
    userDetailRow('Stripe Connect', presta.stripe_connect_account_id, { mono: true }),
    userDetailRow('Connect statut', presta.stripe_connect_onboarding_status),
    userDetailRow('Paiements activés', presta.stripe_connect_charges_enabled ? 'Oui' : 'Non'),
    userDetailRow('Profil créé le', fmtUserDateTime(presta.created_at)),
  ].join('') : '';

  const providersRows = providers.length
    ? providers.map((p) => userDetailRow(
      p.provider || '—',
      `Depuis ${fmtUserDateTime(p.created_at)}${p.last_sign_in_at ? ` · dernière utilisation ${fmtUserDateTime(p.last_sign_in_at)}` : ''}`,
    )).join('')
    : userDetailRow('Fournisseurs', '—');

  return `
    <div class="user-detail-header">
      <div class="user-detail-avatar">${avatarHtml}</div>
      <div class="user-detail-header-text">
        <div class="user-detail-name">${escapeHtml(displayName)}</div>
        <div class="user-detail-email">${escapeHtml(details?.email || u.email)}</div>
        <div class="user-detail-badges">
          <span class="badge ${u.type === 'prestataire' ? 'pro' : u.type === 'client' ? 'active' : 'inactive'}">${escapeHtml(u.type)}</span>
          <span class="badge ${isActive ? 'active' : 'inactive'}">${isActive ? 'Actif' : 'Banni'}</span>
          ${presta?.is_verified ? '<span class="badge active">Vérifié</span>' : ''}
        </div>
      </div>
    </div>
    ${userDetailSection('Compte', 'fa-user', accountRows)}
    ${userDetailSection('Statut & rôles', 'fa-shield-halved', statusRows + `<div class="user-detail-row user-detail-row--full"><div class="user-detail-label">Rôles</div><div class="user-detail-value">${rolesHtml}</div></div>`)}
    ${client ? userDetailSection('Profil client', 'fa-user-tag', clientRows) : ''}
    ${presta ? userDetailSection('Profil prestataire', 'fa-store', prestaRows + renderMissingLabelsList(missingLabels)) : ''}
    ${userDetailSection('Connexion', 'fa-key', providersRows)}
    <div class="user-detail-actions">
      ${!roles.includes('client') ? `<button type="button" class="btn btn-outline btn-sm" onclick="MBLive.setRole('${u.id}','client')">+ Client</button>` : ''}
      ${!roles.includes('prestataire') ? `<button type="button" class="btn btn-outline btn-sm" onclick="MBLive.setRole('${u.id}','prestataire')">+ Prestataire</button>` : ''}
      ${!roles.includes('admin') ? `<button type="button" class="btn btn-outline btn-sm" onclick="MBLive.setRole('${u.id}','admin')">+ Admin</button>` : ''}
      <button type="button" class="btn btn-outline btn-sm" onclick="closeModal();openSupportForUser('${u.id}')"><i class="fa-solid fa-comment"></i> Support</button>
      <button type="button" class="btn btn-danger btn-sm" onclick="closeModal();${isActive ? `openBanModal('${u.id}')` : `openUnbanModal('${u.id}')`}"><i class="fa-solid fa-ban"></i> ${isActive ? 'Bannir' : 'Débannir'}</button>
    </div>`;
}

async function openUserModal(userId) {
  const u = USERS.find((x) => x.id === userId);
  if (!u) { showToast('Utilisateur introuvable'); return; }
  openModalShell({
    title: u.name,
    bodyHtml: '<div class="user-detail-loading"><i class="fa-solid fa-spinner fa-spin"></i> Chargement des détails…</div>',
    footerHtml: '<button type="button" class="btn btn-outline" onclick="closeModal()">Fermer</button>',
    variant: 'user-detail',
  });
  try {
    const details = await MBApi.getUserDetails(userId);
    const body = document.getElementById('modal-body');
    if (!body) return;
    if (!details) {
      body.innerHTML = '<p class="modal-hint">Utilisateur introuvable sur le serveur.</p>';
      return;
    }
    body.innerHTML = renderUserDetailBody(u, details);
  } catch (e) {
    const body = document.getElementById('modal-body');
    if (body) {
      body.innerHTML = `<p class="modal-hint" style="color:var(--danger);">${escapeHtml(e.message || 'Impossible de charger les détails')}</p>`;
    }
  }
}

// ─── TABLES ─────────────────────────────────────────────────
const avatarColors = ['#C4956A','#2C1810','#1A6B3C','#5C3D2E','#8B6340','#B8860B'];
function getColor(i) { return avatarColors[i % avatarColors.length]; }
function initials(name) { return name.split(' ').map(w=>w[0]).join('').substring(0,2).toUpperCase(); }

function getFilteredUsers(scope = 'users') {
  const status = document.getElementById('users-filter-status')?.value || userListFilter.status || 'all';
  let type = 'all';
  if (scope === 'users') {
    type = document.getElementById('users-filter-type')?.value || userListFilter.type || 'all';
  }
  return USERS.filter((u) => {
    if (scope === 'clients' && !u.isClient) return false;
    if (scope === 'presta' && !u.isPresta) return false;
    if (scope === 'users' && type !== 'all' && u.type !== type) return false;
    if (status === 'active' && u.status !== 'active') return false;
    if (status === 'banned' && u.status !== 'inactive') return false;
    return true;
  });
}

function userRowActions(u) {
  return `<td style="display:flex;gap:6px;flex-wrap:wrap;">
    <button type="button" class="btn btn-outline btn-sm" title="Détails" onclick="openUserModal('${u.id}')"><i class="fa-solid fa-eye"></i></button>
    <button type="button" class="btn btn-outline btn-sm" title="Support" onclick="openSupportForUser('${u.id}')"><i class="fa-solid fa-comment"></i></button>
    <button type="button" class="btn btn-danger btn-sm" title="${u.status === 'active' ? 'Bannir' : 'Débannir'}" onclick="${u.status === 'active' ? `openBanModal('${u.id}')` : `openUnbanModal('${u.id}')`}"><i class="fa-solid fa-ban"></i></button>
  </td>`;
}

function emptyRow(cols, msg) {
  return `<tr><td colspan="${cols}" style="color:var(--text3);padding:24px;text-align:center;">${msg}</td></tr>`;
}

function subscriptionStatusBadge(row) {
  const status = row.subscription_status || 'none';
  if (row.is_catalog_trial) {
    return '<span class="badge pending">Essai catalogue</span>';
  }
  const map = {
    active: ['active', 'Actif'],
    trialing: ['active', 'Essai Stripe'],
    past_due: ['danger', 'En retard'],
    unpaid: ['danger', 'Impayé'],
    incomplete: ['pending', 'Incomplet'],
    canceled: ['inactive', 'Annulé'],
    none: ['inactive', 'Aucun'],
  };
  const [cls, label] = map[status] || ['inactive', status];
  return `<span class="badge ${cls}">${escapeHtml(label)}</span>`;
}

function subscriptionTierLabel(tier, interval) {
  if (!tier) return '—';
  const tierLabel = tier === 'multi' ? '2+ services' : tier === 'solo' ? '1 service' : tier;
  const intLabel = interval === 'year' ? 'annuel' : interval === 'month' ? 'mensuel' : interval || '';
  return intLabel ? `${tierLabel} · ${intLabel}` : tierLabel;
}

function renderPrestataireSubscriptions() {
  const tbody = document.getElementById('subs-tbody');
  const summary = document.getElementById('subs-summary');
  if (!tbody) return;

  const rows = (typeof store !== 'undefined' && store.prestataireSubscriptions) || [];
  if (!rows.length) {
    tbody.innerHTML = emptyRow(12, 'Aucun prestataire — lance une recherche ou vérifie la migration admin.');
    if (summary) summary.textContent = '';
    return;
  }

  if (summary) {
    const active = rows.filter((r) => ['active', 'trialing'].includes(r.subscription_status)).length;
    const trial = rows.filter((r) => r.is_catalog_trial).length;
    summary.textContent = `${rows.length} résultat(s) · ${active} abonnement(s) Stripe · ${trial} en essai catalogue`;
  }

  tbody.innerHTML = rows.map((row, i) => {
    const name = row.display_name || row.nom_salon || row.email || '—';
    const salon = [row.nom_salon, formatCityName(row.ville)].filter(Boolean).join(' · ') || '—';
    const address = formatStreetLine({
      adresse: row.adresse,
    });
    const missing = row.missing_labels || row.missingLabels || [];
    const stripeRef = row.stripe_subscription_id
      ? `<span style="font-family:monospace;font-size:11px;" title="${escapeHtml(row.stripe_subscription_id)}">${escapeHtml(row.stripe_subscription_id.slice(0, 14))}…</span>`
      : '—';
    return `
      <tr>
        <td>
          <div class="user-cell">
            <div class="user-avatar" style="background:${getColor(i)};color:white;">${initials(name)}</div>
            <div>
              <div class="user-name">${escapeHtml(name)}</div>
              <div class="user-email">${escapeHtml(row.email || '')}</div>
            </div>
          </div>
        </td>
        <td style="font-size:13px;">${escapeHtml(salon)}</td>
        <td style="font-size:12px;color:var(--text2);max-width:220px;">${escapeHtml(address)}</td>
        <td>${subscriptionStatusBadge(row)}</td>
        <td>${profileCompletenessBadge(row.is_profile_complete, row.is_catalog_visible)}</td>
        <td>${renderMissingLabelsList(missing, { compact: true })}</td>
        <td style="font-size:13px;">${escapeHtml(subscriptionTierLabel(row.subscription_tier, row.subscription_interval))}</td>
        <td style="font-size:12px;color:var(--text3);">${fmtUserDateTime(row.subscription_current_period_end)}</td>
        <td style="font-size:12px;color:var(--text3);">${row.is_catalog_trial ? fmtUserDateTime(row.catalog_trial_ends_at) : '—'}</td>
        <td>${row.services_count ?? 0}</td>
        <td>${stripeRef}</td>
        <td>
          <button type="button" class="btn btn-outline btn-sm" title="Fiche utilisateur" onclick="openUserModal('${row.user_id}')"><i class="fa-solid fa-eye"></i></button>
        </td>
      </tr>`;
  }).join('');
}

function renderTables() {
  ['recent-users-tbody','all-users-tbody','clients-tbody','presta-tbody','rdv-tbody','payments-tbody'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.innerHTML = '';
  });

  const filtered = getFilteredUsers('users');
  const clients = getFilteredUsers('clients');
  const prestas = getFilteredUsers('presta');

  const recentTbody = document.getElementById('recent-users-tbody');
  if (recentTbody) {
    if (!USERS.length) recentTbody.innerHTML = emptyRow(7, 'Aucun utilisateur — vérifiez la connexion admin');
    else USERS.slice(0, 5).forEach((u, i) => {
      recentTbody.innerHTML += `
      <tr>
        <td><div class="user-cell"><div class="user-avatar" style="background:${getColor(i)};color:white;">${initials(u.name)}</div><div><div class="user-name">${u.name}</div><div class="user-email">${u.email}</div></div></div></td>
        <td><span class="badge ${u.type==='prestataire'?'pro':u.type==='client'?'active':'inactive'}">${u.type}</span></td>
        <td>${(u.roles || []).join(', ') || '—'}</td>
        <td>${u.phone}</td>
        <td style="color:var(--text3);font-size:12px;">${u.city}</td>
        <td><span class="badge ${u.status==='active'?'active':'inactive'}">${u.status==='active'?'Actif':'Banni'}</span></td>
        ${userRowActions(u)}
      </tr>`;
    });
  }

  const allTbody = document.getElementById('all-users-tbody');
  if (allTbody) {
    if (!filtered.length) allTbody.innerHTML = emptyRow(8, USERS.length ? 'Aucun résultat pour ces filtres' : 'Aucun utilisateur chargé');
    else filtered.forEach((u, i) => {
      allTbody.innerHTML += `
      <tr>
        <td><div class="user-cell"><div class="user-avatar" style="background:${getColor(i)};color:white;">${initials(u.name)}</div><div><div class="user-name">${u.name}</div><div class="user-email">${u.email}</div></div></div></td>
        <td><span class="badge ${u.type==='prestataire'?'pro':u.type==='client'?'active':'inactive'}">${u.type}</span></td>
        <td style="font-size:12px;color:var(--text3);">${(u.roles || []).join(', ') || '—'}</td>
        <td>${u.phone}</td>
        <td style="font-size:12px;color:var(--text3);">${u.city}</td>
        <td>${u.rdv}</td>
        <td><span class="badge ${u.status==='active'?'active':'inactive'}">${u.status==='active'?'Actif':'Banni'}</span></td>
        ${userRowActions(u)}
      </tr>`;
    });
  }

  const clientsTbody = document.getElementById('clients-tbody');
  if (clientsTbody) {
    if (!clients.length) clientsTbody.innerHTML = emptyRow(8, 'Aucun client');
    else clients.forEach((u, i) => {
      const address = formatStreetLine({
        adresse: u.clientAdresse,
      });
      clientsTbody.innerHTML += `
      <tr>
        <td><div class="user-cell"><div class="user-avatar" style="background:${getColor(i)};color:white;">${initials(u.name)}</div><div><div class="user-name">${u.name}</div><div class="user-email">${u.email}</div></div></div></td>
        <td style="font-size:12px;color:var(--text2);max-width:240px;">${escapeHtml(address)}</td>
        <td>${u.city}</td>
        <td><span class="badge inactive">${u.sub}</span></td>
        <td>${u.rdv}</td>
        <td>${u.depense||'—'}</td>
        <td><span class="badge ${u.status==='active'?'active':'inactive'}">${u.status==='active'?'Actif':'Banni'}</span></td>
        ${userRowActions(u)}
      </tr>`;
    });
  }

  const prestaTbody = document.getElementById('presta-tbody');
  if (prestaTbody) {
    if (!prestas.length) prestaTbody.innerHTML = emptyRow(11, 'Aucun prestataire');
    else prestas.forEach((u, i) => {
      const address = formatStreetLine({
        adresse: u.prestaAdresse,
      });
      prestaTbody.innerHTML += `
      <tr>
        <td><div class="user-cell"><div class="user-avatar" style="background:${getColor(i)};color:white;">${initials(u.name)}</div><div><div class="user-name">${u.name}</div><div class="user-email">${u.email}</div></div></div></td>
        <td>${u.specialty || '—'}</td>
        <td style="font-size:12px;color:var(--text2);max-width:240px;">${escapeHtml(address)}</td>
        <td>${u.city}</td>
        <td>${profileCompletenessBadge(u.prestaIsProfileComplete, u.prestaIsCatalogVisible)}</td>
        <td>${renderMissingLabelsList(u.prestaMissingLabels, { compact: true })}</td>
        <td>${u.rdv}</td>
        <td>${u.note != null ? '⭐ ' + u.note : '—'}</td>
        <td><span class="badge pro">${u.sub}</span></td>
        <td><span class="badge ${u.status==='active'?'active':'inactive'}">${u.status==='active'?'Actif':'Banni'}</span></td>
        ${userRowActions(u)}
      </tr>`;
    });
  }

  const rdvTbody = document.getElementById('rdv-tbody');
  if (rdvTbody) {
    if (!RDV_DATA.length) rdvTbody.innerHTML = emptyRow(7, 'Aucune réservation');
    else RDV_DATA.forEach(r => {
    rdvTbody.innerHTML += `
    <tr>
      <td>${r.client}</td>
      <td>${r.presta}</td>
      <td>${r.service}</td>
      <td>${r.date}</td>
      <td>${r.city}</td>
      <td style="font-weight:500;color:var(--success);">${r.commission}</td>
      <td><span class="badge ${r.status==='confirme'?'active':'danger'}">${r.status==='confirme'?'Confirmé':'Annulé'}</span></td>
    </tr>`;
    });
  }

  const payTbody = document.getElementById('payments-tbody');
  if (payTbody) {
    if (!PAYMENTS.length) payTbody.innerHTML = emptyRow(6, 'Aucun paiement capturé');
    else PAYMENTS.forEach(p => {
    payTbody.innerHTML += `
    <tr>
      <td>${p.user}</td>
      <td>${p.type}</td>
      <td><span class="badge pro">${p.plan}</span></td>
      <td style="font-weight:600;" class="blur-val">${p.amount}</td>
      <td style="color:var(--text3);">${p.date}</td>
      <td><span class="badge ${p.status==='active'?'active':'pending'}">${p.status==='active'?'Payé':'En attente'}</span></td>
    </tr>`;
    });
  }
}

function applyUserFilters() {
  userListFilter.type = document.getElementById('users-filter-type')?.value || 'all';
  userListFilter.status = document.getElementById('users-filter-status')?.value || 'all';
  renderTables();
}

function filterUsers(q) {
  applyUserFilters();
}

function filterTableRows(tbodyId, q) {
  const rows = document.querySelectorAll(`#${tbodyId} tr`);
  const needle = (q || '').toLowerCase();
  rows.forEach((r) => {
    r.style.display = !needle || r.textContent.toLowerCase().includes(needle) ? '' : 'none';
  });
}

function filterRdv(q) {
  const rows = document.querySelectorAll('#rdv-tbody tr');
  const needle = (q || '').toLowerCase();
  rows.forEach((r) => {
    r.style.display = !needle || r.textContent.toLowerCase().includes(needle) ? '' : 'none';
  });
}

function downloadCsv(filename, headers, rows) {
  const esc = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
  const lines = [headers.map(esc).join(',')].concat(rows.map((row) => row.map(esc).join(',')));
  const blob = new Blob(['\uFEFF' + lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  a.click();
  URL.revokeObjectURL(a.href);
}

function exportPaysUsersCsv() {
  if (!PAYS_DATA.length) { showToast('Aucune donnée à exporter'); return; }
  const rows = PAYS_DATA.map((p) => [p.pays, p.users, p.clients, p.presta, p.rdv, p.trend]);
  downloadCsv('utilisateurs-par-pays.csv', ['Pays', 'Total', 'Clients', 'Prestataires', 'RDV', 'Tendance'], rows);
  showToast('Export CSV téléchargé');
}

function exportPaysRevenueCsv() {
  if (!PAYS_DATA.length) { showToast('Aucune donnée à exporter'); return; }
  const rows = PAYS_DATA.map((p) => [p.pays, p.rev, p.comm, p.abo]);
  downloadCsv('revenus-par-pays.csv', ['Pays', 'Revenus €', 'Commissions €', 'Abonnements €'], rows);
  showToast('Export CSV téléchargé');
}

// ─── CHATS ──────────────────────────────────────────────────
window.activeChatId = null;
let feedbackFilter = 'all';
function renderChats() {
  const list = document.getElementById('chat-list-items');
  list.innerHTML = '';
  if (!CHATS.length) {
    document.getElementById('chat-messages-area').innerHTML = '<p style="padding:20px;color:var(--text3);">Aucune conversation.</p>';
    const chatTitle = document.getElementById('chat-list-title');
    if (chatTitle) chatTitle.textContent = 'Conversations (0)';
    updateChatBanButton();
    return;
  }
  CHATS.forEach((c, idx) => {
    const div = document.createElement('div');
    div.className = 'chat-item' + (idx === 0 ? ' active' : '');
    div.innerHTML = `<div style="display:flex;justify-content:space-between;"><span class="chat-item-name">${c.name}${c.unread ? ` <span class="nav-badge" style="margin-left:4px;">${c.unread}</span>` : ''}</span><span class="chat-item-time">${c.time}</span></div><div class="chat-item-preview">${c.preview}</div>`;
    div.onclick = () => selectChat(c.id, div);
    list.appendChild(div);
  });
  activeChatId = CHATS[0].id;
  window.activeChatId = activeChatId;
  document.getElementById('chat-active-name').textContent = CHATS[0].name;
  loadChat(activeChatId);
}

function selectChat(id, el) {
  activeChatId = id;
  window.activeChatId = id;
  document.querySelectorAll('.chat-item').forEach(i => i.classList.remove('active'));
  el.classList.add('active');
  const chat = CHATS.find(c => c.id===id);
  document.getElementById('chat-active-name').textContent = chat.name;
  if (typeof MBLive?.loadSupportThread === 'function') {
    MBLive.loadSupportThread(id);
  } else {
    loadChat(id);
  }
  updateChatBanButton();
}

function loadChat(id) {
  const chat = CHATS.find(c => c.id===id);
  const area = document.getElementById('chat-messages-area');
  area.innerHTML = '';
  chat.messages.forEach(m => {
    const div = document.createElement('div');
    div.className = 'msg '+m.from;
    div.innerHTML = `<div class="msg-bubble">${m.text}</div><div class="msg-time">${m.from==='admin'?'Admin':chat.name}</div>`;
    area.appendChild(div);
  });
  area.scrollTop = area.scrollHeight;
}

function updateChatBanButton() {
  const btn = document.getElementById('chat-ban-btn');
  if (!btn) return;
  const chat = CHATS.find((c) => c.id === activeChatId);
  const u = chat?.userId ? USERS.find((x) => x.id === chat.userId) : null;
  const banned = u?.status === 'inactive';
  btn.innerHTML = `<i class="fa-solid fa-ban"></i> ${banned ? 'Débannir' : 'Bannir'}`;
}

function sendAdminMessage() {
  if (typeof MBLive?.sendSupportMessage === 'function') {
    MBLive.sendSupportMessage();
    return;
  }
  const inp = document.getElementById('chat-input');
  const txt = inp.value.trim();
  if (!txt) return;
  const chat = CHATS.find(c => c.id===activeChatId);
  chat.messages.push({from:'admin',text:txt});
  inp.value = '';
  loadChat(activeChatId);
  showToast('Message envoyé');
}

function blockChatUser() {
  if (typeof MBLive?.blockChatUser === 'function') MBLive.blockChatUser();
}

// ─── FEEDBACK ───────────────────────────────────────────────
function filterFeedback(mode) {
  feedbackFilter = mode || 'all';
  renderFeedback();
}

function renderFeedback() {
  const list = document.getElementById('feedback-list');
  list.innerHTML = '';
  let items = FEEDBACKS;
  if (feedbackFilter === 'pending') {
    items = items.filter((f) => ['pending', 'in_progress'].includes(f.status));
  } else if (feedbackFilter === 'resolved') {
    items = items.filter((f) => f.status === 'resolved');
  }
  if (!items.length) {
    list.innerHTML = '<p style="color:var(--text3);padding:20px;text-align:center;">Aucun signalement</p>';
    return;
  }
  items.forEach(f => {
    const stars = f.stars ? '⭐'.repeat(f.stars) : '';
    const pending = f.status && ['pending', 'in_progress'].includes(f.status);
    list.innerHTML += `
    <div class="feedback-item">
      <div class="feedback-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="user-avatar" style="background:var(--gold);color:var(--brown);width:34px;height:34px;font-size:12px;">${initials(f.user)}</div>
          <div>
            <div class="feedback-user">${f.user}</div>
            <div style="font-size:11.5px;color:var(--text3);">${f.role} · ${f.status || '—'}</div>
          </div>
        </div>
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="stars">${stars}</div>
          <span class="feedback-date">${f.date}</span>
          ${pending && f.id ? `<button class="btn btn-outline btn-sm" onclick="MBLive.resolveBug('${f.id}')"><i class="fa-solid fa-check"></i> Résoudre</button>` : ''}
        </div>
      </div>
      <div class="feedback-text">"${f.text}"</div>
    </div>`;
  });
}

// ─── ZONES ──────────────────────────────────────────────────
function renderZones() {
  const list = document.getElementById('zones-list');
  if (!list) return;
  list.innerHTML = '';
  if (!ZONES.length) return;
  const max = Math.max(...ZONES.map(z => z.count), 1);
  ZONES.forEach(z => {
    list.innerHTML += `<div class="zone-row"><div class="zone-name">${z.city}</div><div class="zone-bar-wrap"><div class="zone-bar" style="width:${Math.round(z.count/max*100)}%"></div></div><div class="zone-val">${z.count.toLocaleString()}</div></div>`;
  });
}

// ─── CHARTS ─────────────────────────────────────────────────
let revenueChartObj, subChartObj, userPieChartObj, revPieChartObj, zonesChartObj;
window.REVENUE_CHART_SUB = [];
window.REVENUE_CHART_RDV = [];

function initCharts() {
  function last12MonthLabelsSafe() {
    const labels = [];
    const now = new Date();
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      labels.push(d.toLocaleDateString('fr-FR', { month: 'short' }));
    }
    return labels;
  }

  const months = last12MonthLabelsSafe();
  const zeros12 = months.map(() => 0);
  const zeros5 = [0, 0, 0, 0, 0];

  revenueChartObj = new Chart(document.getElementById('revenueChart'), {
    type: 'line',
    data: {
      labels: months,
      datasets: [
        { label:'Abonnements', data: zeros12, borderColor:'#C4956A', backgroundColor:'rgba(196,149,106,.1)', tension:.4, fill:true, pointRadius:3, borderWidth:2 },
        { label:'Commissions', data: zeros12, borderColor:'#2C1810', backgroundColor:'rgba(44,24,16,.06)', tension:.4, fill:true, pointRadius:3, borderWidth:2, borderDash:[5,4] }
      ]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{ legend:{display:false} },
      scales:{
        x:{grid:{display:false},ticks:{font:{size:10},color:'#9E8878'}},
        y:{grid:{color:'rgba(0,0,0,.04)'},ticks:{font:{size:10},color:'#9E8878',callback:v=>v.toLocaleString()+'€'}}
      }
    }
  });

  userPieChartObj = new Chart(document.getElementById('userPieChart'), {
    type: 'doughnut',
    data: {
      labels: ['Clients','Prestataires'],
      datasets: [{ data:[0, 0], backgroundColor:['#C4956A','#2C1810'], borderWidth:0 }]
    },
    options: { responsive:true, maintainAspectRatio:false, plugins:{legend:{display:false}}, cutout:'72%' }
  });

  zonesChartObj = new Chart(document.getElementById('zonesChart'), {
    type: 'bar',
    data: {
      labels: [],
      datasets: [{ data:[], backgroundColor:['#C4956A','#3D1F0D','#8B6340','#5C3D2E','#EDE0CC'], borderWidth:0, borderRadius:6 }]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{legend:{display:false}},
      scales:{
        x:{grid:{display:false},ticks:{font:{size:11},color:'#9E8878'}},
        y:{grid:{color:'rgba(0,0,0,.04)'},ticks:{font:{size:10},color:'#9E8878'}}
      }
    }
  });

  const subMonths = ['Jan','Fév','Mar','Avr','Mai'];
  subChartObj = new Chart(document.getElementById('subChart'), {
    type: 'bar',
    data: {
      labels: subMonths,
      datasets: [
        { label:'Mensuel', data: zeros5, backgroundColor:'#C4956A', borderRadius:5, borderWidth:0 },
        { label:'Annuel', data: zeros5, backgroundColor:'#2C1810', borderRadius:5, borderWidth:0 }
      ]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{legend:{display:false}},
      scales:{
        x:{grid:{display:false},ticks:{font:{size:11},color:'#9E8878'}},
        y:{grid:{color:'rgba(0,0,0,.04)'},ticks:{font:{size:10},color:'#9E8878'}}
      }
    }
  });

  revPieChartObj = new Chart(document.getElementById('revPieChart'), {
    type: 'doughnut',
    data: {
      labels: ['Abonnements','Commissions RDV'],
      datasets: [{ data:[0, 0], backgroundColor:['#C4956A','#2C1810'], borderWidth:0 }]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{legend:{display:false}},
      cutout:'65%'
    }
  });
}


// PAYS_DATA et ZONES alimentés par live.js

const PAYS_COLORS = ['#C4956A','#2C1810','#1A6B3C','#5C3D2E','#8B6340','#B8860B','#3B5BDB','#C0392B','#7048E8','#0D9488','#D97706','#6D28D9'];

let paysUsersBarObj, paysUsersPieObj, paysRevBarObj, paysRevPieObj;

function renderPaysUsers() {
  const filter = document.getElementById('pays-users-filter')?.value || 'all';
  const tbody = document.getElementById('pays-users-tbody');
  if (!tbody) return;

  if (!PAYS_DATA.length) {
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:28px;color:var(--text3);">Aucune donnée pays disponible.</td></tr>';
    if (paysUsersBarObj) { paysUsersBarObj.destroy(); paysUsersBarObj = null; }
    if (paysUsersPieObj) { paysUsersPieObj.destroy(); paysUsersPieObj = null; }
    const legend = document.getElementById('pays-pie-legend');
    if (legend) legend.innerHTML = '';
    return;
  }

  const metric = (p) => (filter === 'client' ? p.clients : filter === 'prestataire' ? p.presta : p.users);
  const total = PAYS_DATA.reduce((s, p) => s + metric(p), 0);

  tbody.innerHTML = '';
  const sorted = [...PAYS_DATA].sort((a, b) => metric(b) - metric(a));
  sorted.forEach((p) => {
    const val = metric(p);
    const pct = total ? ((val / total) * 100).toFixed(1) : '0.0';
    const monthRdv = p.reservationsThisMonth || 0;
    const trendIcon = monthRdv > 0
      ? `<span style="color:var(--success);font-size:12px;"><i class="fa-solid fa-arrow-trend-up"></i> +${monthRdv} RDV ce mois</span>`
      : '<span style="color:var(--text3);font-size:12px;"><i class="fa-solid fa-minus"></i> Stable</span>';
    tbody.innerHTML += `<tr>
      <td style="font-weight:500;">${p.pays}</td>
      <td style="font-size:20px;">${p.flag}</td>
      <td style="font-weight:600;color:var(--gold2);">${p.users.toLocaleString()}</td>
      <td style="color:var(--text2);">${p.clients.toLocaleString()}</td>
      <td style="color:var(--text2);">${p.presta.toLocaleString()}</td>
      <td style="color:var(--text2);">${(p.rdv || 0).toLocaleString()}</td>
      <td>
        <div style="display:flex;align-items:center;gap:8px;">
          <div style="flex:1;height:6px;background:var(--cream2);border-radius:3px;overflow:hidden;max-width:80px;">
            <div style="width:${pct}%;height:100%;background:var(--gold);border-radius:3px;"></div>
          </div>
          <span style="font-size:12px;color:var(--text3);">${pct}%</span>
        </div>
      </td>
      <td>${trendIcon}</td>
    </tr>`;
  });

  const labels = sorted.map((p) => p.pays);
  const vals = sorted.map((p) => metric(p));
  if (paysUsersBarObj) paysUsersBarObj.destroy();
  paysUsersBarObj = new Chart(document.getElementById('paysUsersBarChart'), {
    type:'bar',
    data:{
      labels,
      datasets:[{
        data:vals,
        backgroundColor:PAYS_COLORS,
        borderWidth:0,borderRadius:6
      }]
    },
    options:{
      responsive:true,maintainAspectRatio:false,
      plugins:{legend:{display:false}},
      scales:{
        x:{grid:{display:false},ticks:{font:{size:10},color:'#9E8878'}},
        y:{grid:{color:'rgba(0,0,0,.04)'},ticks:{font:{size:10},color:'#9E8878'}}
      }
    }
  });

  // Pie (top 5)
  const top5 = sorted.slice(0, 5);
  const top5vals = top5.map((p) => metric(p));
  const autresVal = sorted.slice(5).reduce((s, p) => s + metric(p), 0);
  if (paysUsersPieObj) paysUsersPieObj.destroy();
  paysUsersPieObj = new Chart(document.getElementById('paysUsersPieChart'), {
    type:'doughnut',
    data:{
      labels:[...top5.map(p=>p.pays),'Autres'],
      datasets:[{data:[...top5vals,autresVal],backgroundColor:[...PAYS_COLORS.slice(0,5),'#EDE0CC'],borderWidth:0}]
    },
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},cutout:'68%'}
  });

  // Legend
  const legend = document.getElementById('pays-pie-legend');
  legend.innerHTML = [...top5.map((p,i)=>`<span style="display:flex;align-items:center;gap:4px;"><span style="width:8px;height:8px;border-radius:2px;background:${PAYS_COLORS[i]};display:inline-block;"></span>${p.pays}</span>`), '<span style="display:flex;align-items:center;gap:4px;"><span style="width:8px;height:8px;border-radius:2px;background:#EDE0CC;display:inline-block;"></span>Autres</span>'].join('');
}

function renderPaysRevenue() {
  if (typeof window.applyPaysRevenueKpis === 'function') window.applyPaysRevenueKpis();
  const sorted = [...PAYS_DATA].sort((a, b) => b.rev - a.rev);
  const totalRev = sorted.reduce((s, p) => s + p.rev, 0);
  const tbody = document.getElementById('pays-rev-tbody');
  if (!tbody) return;

  if (!sorted.length || !totalRev) {
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:28px;color:var(--text3);">Aucun revenu capturé par pays.</td></tr>';
    if (paysRevBarObj) { paysRevBarObj.destroy(); paysRevBarObj = null; }
    if (paysRevPieObj) { paysRevPieObj.destroy(); paysRevPieObj = null; }
    return;
  }

  tbody.innerHTML = '';
  sorted.forEach((p) => {
    const pct = ((p.rev / totalRev) * 100).toFixed(1);
    const basis = Math.max(p.clients || p.presta || 1, 1);
    const arpu = (p.rev / basis).toFixed(2);
    const monthRdv = p.reservationsThisMonth || 0;
    const trendIcon = monthRdv > 0
      ? `<span style="color:var(--success);font-size:12px;"><i class="fa-solid fa-arrow-trend-up"></i> +${monthRdv} RDV ce mois</span>`
      : '<span style="color:var(--text3);font-size:12px;"><i class="fa-solid fa-minus"></i> Stable</span>';
    tbody.innerHTML += `<tr>
      <td style="font-weight:500;">${p.pays}</td>
      <td style="font-size:20px;">${p.flag}</td>
      <td style="font-weight:600;color:var(--success);" class="blur-val">${p.rev.toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} €</td>
      <td class="blur-val" style="color:var(--text3);">—</td>
      <td class="blur-val" style="color:var(--text2);">${p.comm.toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} €</td>
      <td style="font-weight:500;" class="blur-val">${arpu} €</td>
      <td>
        <div style="display:flex;align-items:center;gap:8px;">
          <div style="flex:1;height:6px;background:var(--cream2);border-radius:3px;overflow:hidden;max-width:80px;">
            <div style="width:${pct}%;height:100%;background:var(--gold);border-radius:3px;"></div>
          </div>
          <span style="font-size:12px;color:var(--text3);">${pct}%</span>
        </div>
      </td>
      <td>${trendIcon}</td>
    </tr>`;
  });

  const labels = sorted.map((p) => p.pays);
  if (paysRevBarObj) paysRevBarObj.destroy();
  paysRevBarObj = new Chart(document.getElementById('paysRevBarChart'), {
    type:'bar',
    data:{
      labels,
      datasets:[
        { label: 'Commissions RDV', data: sorted.map((p) => p.comm), backgroundColor: '#C4956A', borderWidth: 0, borderRadius: 6 },
      ]
    },
    options:{
      responsive:true,maintainAspectRatio:false,
      plugins:{legend:{display:false}},
      scales:{
        x:{ grid:{display:false}, ticks:{font:{size:10},color:'#9E8878'} },
        y:{ grid:{color:'rgba(0,0,0,.04)'}, ticks:{font:{size:10},color:'#9E8878',callback:(v)=>`${v.toLocaleString()}€`} }
      }
    }
  });

  // Pie
  const top5r = sorted.slice(0,5);
  const autresRev = sorted.slice(5).reduce((s,p)=>s+p.rev,0);
  if (paysRevPieObj) paysRevPieObj.destroy();
  paysRevPieObj = new Chart(document.getElementById('paysRevPieChart'), {
    type:'doughnut',
    data:{
      labels:[...top5r.map(p=>p.pays),'Autres'],
      datasets:[{data:[...top5r.map(p=>p.rev),autresRev],backgroundColor:[...PAYS_COLORS.slice(0,5),'#EDE0CC'],borderWidth:0}]
    },
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},cutout:'68%'}
  });

  // Legend
  const legend = document.getElementById('rev-pie-legend');
  legend.innerHTML = [...top5r.map((p,i)=>`<span style="display:flex;align-items:center;gap:4px;"><span style="width:8px;height:8px;border-radius:2px;background:${PAYS_COLORS[i]};display:inline-block;"></span>${p.pays}</span>`), '<span style="display:flex;align-items:center;gap:4px;"><span style="width:8px;height:8px;border-radius:2px;background:#EDE0CC;display:inline-block;"></span>Autres</span>'].join('');

  // Apply current blur state to newly created elements
  if(blurred) {
    document.querySelectorAll('#pays-rev-tbody .blur-val').forEach(el => {
      el.style.filter = 'blur(6px)';
      el.style.userSelect = 'none';
    });
  }
}

function filterPaysTable(q, tableId) {
  const rows = document.querySelectorAll('#'+tableId+' tbody tr');
  rows.forEach(r => {
    r.style.display = r.textContent.toLowerCase().includes(q.toLowerCase()) ? '' : 'none';
  });
}

function updateRevenueChart(type) {
  const sub = window.REVENUE_CHART_SUB || [];
  const rdv = window.REVENUE_CHART_RDV || [];
  if (!revenueChartObj) return;
  if (type==='sub') {
    revenueChartObj.data.datasets[0].data = sub;
    revenueChartObj.data.datasets[1].data = sub.map(()=>0);
  } else if (type==='rdv') {
    revenueChartObj.data.datasets[0].data = rdv.map(()=>0);
    revenueChartObj.data.datasets[1].data = rdv;
  } else {
    revenueChartObj.data.datasets[0].data = sub;
    revenueChartObj.data.datasets[1].data = rdv;
  }
  revenueChartObj.update();
}

// ─── PHOTOS RÉALISATIONS ────────────────────────────────────
var PHOTO_BY_ID = {};

function getPhotoById(id) { return PHOTO_BY_ID[id]; }

function fmtPhotoDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return Number.isNaN(d.getTime())
    ? '—'
    : d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function closePhotoMenus() {
  document.querySelectorAll('.photo-tile-dropdown.open').forEach((el) => el.classList.remove('open'));
  document.querySelectorAll('.photo-tile--menu-open').forEach((el) => el.classList.remove('photo-tile--menu-open'));
}

function togglePhotoMenu(btn, event) {
  event?.stopPropagation();
  const menu = btn?.nextElementSibling;
  const tile = btn?.closest('.photo-tile');
  const wasOpen = menu?.classList.contains('open');
  closePhotoMenus();
  if (!wasOpen) {
    menu?.classList.add('open');
    tile?.classList.add('photo-tile--menu-open');
  }
}

function openPhotoPreview(photoId) {
  const p = getPhotoById(photoId);
  if (!p?.url) { showToast('Média introuvable'); return; }
  closePhotoMenus();
  const isVideo = (p.media_type || p.mediaType) === 'video';
  const media = document.getElementById('photo-preview-media');
  const meta = document.getElementById('photo-preview-meta');
  if (!media || !meta) return;
  media.innerHTML = isVideo
    ? `<video src="${escapeHtml(p.url)}" controls autoplay playsinline></video>`
    : `<img src="${escapeHtml(p.url)}" alt="Aperçu">`;
  const label = p.prestataire_label || p.prestataireLabel || '—';
  const email = p.owner_email || p.ownerEmail || '';
  const caption = p.caption
    ? `<div style="margin-top:6px;"><strong>Légende :</strong> ${escapeHtml(p.caption)}</div>`
    : '';
  meta.innerHTML = `
    <div><strong>${escapeHtml(label)}</strong>${email ? ` · ${escapeHtml(email)}` : ''}</div>
    ${caption}
    <div style="margin-top:6px;color:var(--text3);">${fmtPhotoDate(p.created_at)}</div>`;
  document.getElementById('photo-preview-overlay')?.classList.add('open');
}

function closePhotoPreview() {
  const overlay = document.getElementById('photo-preview-overlay');
  const media = document.getElementById('photo-preview-media');
  overlay?.classList.remove('open');
  if (media) media.innerHTML = '';
}

function openPhotoDeleteConfirm(photoId) {
  closePhotoMenus();
  openModalShell({
    title: 'Supprimer cette photo ?',
    bodyHtml: '<p class="modal-hint" style="margin:0;">Elle sera retirée de la galerie publique et du stockage.</p>',
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-danger" onclick="MBLive.moderatePhotoAction('${photoId}', 'remove')"><i class="fa-solid fa-trash"></i> Supprimer</button>`,
  });
}

function openPhotoFlagConfirm(photoId) {
  closePhotoMenus();
  openModalShell({
    title: 'Signaler comme obscène ?',
    bodyHtml: '<p class="modal-hint" style="margin:0;">La photo sera supprimée et un signalement interne sera enregistré.</p>',
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-danger" onclick="MBLive.moderatePhotoAction('${photoId}', 'flag_obscene')"><i class="fa-solid fa-flag"></i> Signaler (obscène)</button>`,
  });
}

function openPhotoWarnModal(photoId) {
  closePhotoMenus();
  const defaultNote = 'Une photo de votre galerie ne respecte pas nos règles. Merci de publier uniquement du contenu professionnel.';
  openModalShell({
    title: 'Avertir le prestataire',
    bodyHtml: `
      <div class="form-group" style="margin-bottom:0;">
        <label class="form-label" for="photo-warn-input">Message visible dans ses notifications</label>
        <textarea id="photo-warn-input" class="form-input form-textarea" rows="4">${escapeHtml(defaultNote)}</textarea>
        <div class="form-error" id="photo-warn-error" hidden>Message obligatoire.</div>
      </div>`,
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-primary" onclick="submitPhotoWarn('${photoId}')"><i class="fa-solid fa-triangle-exclamation"></i> Avertir le compte</button>`,
  });
  setTimeout(() => document.getElementById('photo-warn-input')?.focus(), 60);
}

function submitPhotoWarn(photoId) {
  const input = document.getElementById('photo-warn-input');
  const err = document.getElementById('photo-warn-error');
  const note = input?.value?.trim() || '';
  if (!note) {
    if (err) err.hidden = false;
    input?.classList.add('input-error');
    input?.focus();
    return;
  }
  if (typeof MBLive?.moderatePhotoAction === 'function') MBLive.moderatePhotoAction(photoId, 'warn', note);
}

function openPhotoBanModal(photoId) {
  const p = getPhotoById(photoId);
  if (!p) { showToast('Photo introuvable'); return; }
  closePhotoMenus();
  const label = p.prestataire_label || p.prestataireLabel || 'Prestataire';
  openModalShell({
    title: 'Bannir le compte',
    variant: 'danger',
    bodyHtml: `
      <div class="modal-alert modal-alert--danger">
        <div class="modal-alert-icon"><i class="fa-solid fa-ban"></i></div>
        <div>
          <div class="modal-alert-title">Bannir ${escapeHtml(label)} ?</div>
          <div class="modal-alert-sub">La photo sera supprimée et le compte suspendu.</div>
        </div>
      </div>
      <div class="form-group" style="margin-bottom:0;">
        <label class="form-label" for="photo-ban-input">Motif du bannissement <span class="required">*</span></label>
        <textarea id="photo-ban-input" class="form-input form-textarea" rows="4" placeholder="Motif obligatoire…"></textarea>
        <div class="form-error" id="photo-ban-error" hidden>Motif obligatoire.</div>
      </div>`,
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal()">Annuler</button>
      <button type="button" class="btn btn-danger" id="photo-ban-confirm-btn" onclick="submitPhotoBan('${photoId}')"><i class="fa-solid fa-ban"></i> Bannir le compte</button>`,
  });
  setTimeout(() => document.getElementById('photo-ban-input')?.focus(), 60);
}

function submitPhotoBan(photoId) {
  const input = document.getElementById('photo-ban-input');
  const err = document.getElementById('photo-ban-error');
  const reason = input?.value?.trim() || '';
  if (!reason) {
    if (err) err.hidden = false;
    input?.classList.add('input-error');
    input?.focus();
    return;
  }
  if (typeof MBLive?.moderatePhotoAction === 'function') MBLive.moderatePhotoAction(photoId, 'ban', null, reason);
}

// ─── AUDIT ──────────────────────────────────────────────────
var auditActiveTab = 'general';

function switchAuditTab(tab, btn) {
  auditActiveTab = tab;
  document.querySelectorAll('.audit-tab').forEach((el) => el.classList.remove('active'));
  if (btn) btn.classList.add('active');
  const general = document.getElementById('audit-panel-general');
  const verif = document.getElementById('audit-panel-verifications');
  const toolbar = document.querySelector('#sec-audit .photos-toolbar');
  if (general) general.hidden = tab !== 'general';
  if (verif) verif.hidden = tab !== 'verifications';
  if (toolbar) toolbar.style.display = tab === 'general' ? '' : 'none';
  renderAuditTable();
}

function populateAuditFilters(entries) {
  const actionSel = document.getElementById('audit-filter-action');
  const entitySel = document.getElementById('audit-filter-entity');
  if (!actionSel || !entitySel) return;
  const actions = [...new Set((entries || []).map((e) => e.action).filter(Boolean))].sort();
  const entities = [...new Set((entries || []).map((e) => e.entity_type).filter(Boolean))].sort();
  const actionVal = actionSel.value;
  const entityVal = entitySel.value;
  actionSel.innerHTML = '<option value="all">Toutes les actions</option>'
    + actions.map((a) => `<option value="${escapeHtml(a)}">${escapeHtml(a)}</option>`).join('');
  entitySel.innerHTML = '<option value="all">Toutes les entités</option>'
    + entities.map((e) => `<option value="${escapeHtml(e)}">${escapeHtml(e)}</option>`).join('');
  actionSel.value = [...actionSel.options].some((o) => o.value === actionVal) ? actionVal : 'all';
  entitySel.value = [...entitySel.options].some((o) => o.value === entityVal) ? entityVal : 'all';
}

function filterAuditEntries(entries) {
  const q = document.getElementById('audit-search')?.value?.trim().toLowerCase() || '';
  const action = document.getElementById('audit-filter-action')?.value || 'all';
  const entity = document.getElementById('audit-filter-entity')?.value || 'all';
  return (entries || []).filter((e) => {
    if (action !== 'all' && e.action !== action) return false;
    if (entity !== 'all' && e.entity_type !== entity) return false;
    if (q) {
      const meta = e.metadata ? JSON.stringify(e.metadata) : '';
      const hay = `${e.actor_display_name || ''} ${e.action || ''} ${e.entity_type || ''} ${e.entity_id || ''} ${meta}`.toLowerCase();
      if (!hay.includes(q)) return false;
    }
    return true;
  });
}

function renderAuditTable() {
  const fmt = window.fmtPhotoDate || ((iso) => iso || '—');
  const audit = window.MBAdminStore?.audit || [];
  const verifications = window.MBAdminStore?.verificationEvents || [];
  const sub = document.getElementById('sec-audit-sub');

  if (auditActiveTab === 'general') {
    populateAuditFilters(audit);
    const filtered = filterAuditEntries(audit);
    const tbody = document.getElementById('audit-tbody');
    if (!tbody) return;
    if (!filtered.length) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:24px;color:var(--text3);">${audit.length ? 'Aucun résultat pour ces filtres' : 'Aucune entrée d\'audit'}</td></tr>`;
    } else {
      tbody.innerHTML = filtered.map((e) => {
        const meta = e.metadata && typeof e.metadata === 'object'
          ? Object.entries(e.metadata).slice(0, 3).map(([k, v]) => `${k}: ${String(v).slice(0, 40)}`).join(' · ')
          : '';
        return `<tr>
          <td>${escapeHtml(e.actor_display_name || '—')}</td>
          <td><span class="badge pro">${escapeHtml(e.action || '—')}</span></td>
          <td>${escapeHtml(e.entity_type || '—')}<br><code style="font-size:11px;">${escapeHtml((e.entity_id || '').slice(0, 12))}</code></td>
          <td style="font-size:12px;color:var(--text3);max-width:220px;">${escapeHtml(meta || '—')}</td>
          <td>${fmt(e.created_at)}</td>
        </tr>`;
      }).join('');
    }
    if (sub) sub.textContent = `${filtered.length} / ${audit.length} entrée(s)`;
    return;
  }

  const q = document.getElementById('audit-search')?.value?.trim().toLowerCase() || '';
  const filteredVerif = (verifications || []).filter((e) => {
    if (!q) return true;
    const hay = `${e.nom_salon || ''} ${e.action || ''} ${e.actor_display_name || ''} ${e.note || ''}`.toLowerCase();
    return hay.includes(q);
  });
  const vbody = document.getElementById('audit-verifications-tbody');
  if (!vbody) return;
  if (!filteredVerif.length) {
    vbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:24px;color:var(--text3);">${verifications.length ? 'Aucun résultat' : 'Aucun événement de vérification'}</td></tr>`;
  } else {
    vbody.innerHTML = filteredVerif.map((e) => `<tr>
      <td>${escapeHtml(e.nom_salon || '—')}</td>
      <td>${escapeHtml(e.action || '—')}</td>
      <td>${escapeHtml(e.actor_display_name || '—')}</td>
      <td style="font-size:12px;color:var(--text2);">${escapeHtml(e.note || '—')}</td>
      <td>${fmt(e.created_at)}</td>
    </tr>`).join('');
  }
  if (sub) sub.textContent = `${filteredVerif.length} / ${verifications.length} vérification(s)`;
}

// ─── PUSH ─────────────────────────────────────────────────────
var pushSelectedUserId = null;
var pushSearchResults = [];
var pushPendingPayload = null;
var pushActiveTemplateId = null;

const PUSH_TEMPLATES = [
  {
    id: 'incomplete_profile',
    label: 'Profil presta incomplet',
    icon: 'fa-user-pen',
    audience: 'prestataire_incomplete',
    nav: 'prestataire_profile_edit',
    title: 'Complète ton profil MadBeauty',
    body: 'Ton profil pro est encore incomplet. Ajoute les infos manquantes pour apparaître dans le catalogue et recevoir des clientes.',
  },
  {
    id: 'app_update',
    label: 'Nouvelle mise à jour',
    icon: 'fa-rocket',
    audience: 'all',
    nav: 'none',
    title: 'Nouvelle mise à jour MadBeauty',
    body: 'Une nouvelle version de MadBeauty est disponible. Mets à jour l’app pour profiter des dernières améliorations.',
  },
  {
    id: 'subscription',
    label: 'Abonnement catalogue',
    icon: 'fa-crown',
    audience: 'prestataire',
    nav: 'prestataire_subscription',
    title: 'Active ton abonnement',
    body: 'Passe en abonnement pour rester visible dans le catalogue et continuer à recevoir des réservations.',
  },
  {
    id: 'catalog_hidden',
    label: 'Profil masqué',
    icon: 'fa-eye-slash',
    audience: 'prestataire',
    nav: 'prestataire_subscription',
    title: 'Ton salon est masqué du catalogue',
    body: 'Les clientes ne voient plus ton profil. Vérifie ton abonnement ou ton essai catalogue pour réactiver ta visibilité.',
  },
  {
    id: 'clients_welcome',
    label: 'Clients — découverte',
    icon: 'fa-heart',
    audience: 'client',
    nav: 'client_search',
    title: 'Trouve ton prochain RDV beauté',
    body: 'Parcours le catalogue MadBeauty et réserve chez un prestataire près de chez toi.',
  },
  {
    id: 'custom',
    label: 'Message libre',
    icon: 'fa-pen',
    audience: 'all',
    nav: 'none',
    title: '',
    body: '',
  },
];

function pushAudienceLabel(audience) {
  switch (audience) {
    case 'client': return 'Clients';
    case 'prestataire': return 'Prestataires';
    case 'prestataire_incomplete': return 'Prestataires — profil incomplet';
    case 'user': return 'Un utilisateur';
    case 'users': return 'Utilisateurs filtrés';
    default: return 'Tous (avec token FCM)';
  }
}

function pushNavLabel(nav) {
  switch (nav) {
    case 'client_home': return 'Accueil client';
    case 'client_reservations': return 'Réservations client';
    case 'client_search': return 'Catalogue / recherche';
    case 'client_messages': return 'Messages client';
    case 'prestataire_dashboard': return 'Dashboard presta';
    case 'prestataire_subscription': return 'Abonnement presta';
    case 'prestataire_profile_edit': return 'Édition profil presta';
    case 'booking': return 'Réservation';
    default: return 'Aucun écran';
  }
}

function renderPushTemplates() {
  const box = document.getElementById('push-templates');
  if (!box) return;
  box.innerHTML = PUSH_TEMPLATES.map((t) => `
    <button type="button"
      class="push-template-chip${pushActiveTemplateId === t.id ? ' active' : ''}"
      onclick="applyPushTemplate('${t.id}')">
      <i class="fa-solid ${t.icon}"></i>
      <span>${escapeHtml(t.label)}</span>
    </button>`).join('');
}

function applyPushTemplate(templateId) {
  const t = PUSH_TEMPLATES.find((x) => x.id === templateId);
  if (!t) return;
  pushActiveTemplateId = t.id;
  const audienceEl = document.getElementById('push-audience');
  const titleEl = document.getElementById('push-title');
  const bodyEl = document.getElementById('push-body');
  const navEl = document.getElementById('push-nav');
  if (audienceEl) audienceEl.value = t.audience;
  if (titleEl) titleEl.value = t.title;
  if (bodyEl) bodyEl.value = t.body;
  if (navEl) navEl.value = t.nav;
  onPushAudienceChange();
  renderPushTemplates();
  const result = document.getElementById('push-result');
  if (result) {
    result.textContent = t.id === 'custom'
      ? 'Modèle libre : rédige ton titre et ton message.'
      : `Modèle « ${t.label} » appliqué — tu peux encore modifier le texte avant envoi.`;
  }
  showToast(`Modèle : ${t.label}`);
}

function onPushAudienceChange() {
  const audience = document.getElementById('push-audience')?.value || 'all';
  const userPanel = document.getElementById('push-user-panel');
  const filterPanel = document.getElementById('push-filter-panel');
  if (userPanel) userPanel.hidden = audience !== 'user';
  if (filterPanel) filterPanel.hidden = audience !== 'users';
  if (audience !== 'user') {
    pushSelectedUserId = null;
    updatePushSelectedLabel();
  }
  if (audience === 'users') updatePushFilterSummary();
  refreshPushPreview();
}

function getPushFilteredUsers() {
  const type = document.getElementById('push-filter-type')?.value || 'all';
  const status = document.getElementById('push-filter-status')?.value || 'all';
  const excludeBanned = document.getElementById('push-exclude-banned')?.checked !== false;
  return (USERS || []).filter((u) => {
    if (type !== 'all' && u.type !== type) return false;
    if (status === 'active' && u.status !== 'active') return false;
    if (status === 'banned' && u.status !== 'inactive') return false;
    if (excludeBanned && u.status === 'inactive') return false;
    return true;
  });
}

function updatePushFilterSummary() {
  const el = document.getElementById('push-filter-summary');
  if (!el) return;
  const users = getPushFilteredUsers();
  el.textContent = `${users.length} utilisateur(s) correspondent aux filtres (seuls ceux avec token FCM recevront la notif).`;
}

function updatePushSelectedLabel() {
  const el = document.getElementById('push-user-selected');
  if (!el) return;
  if (!pushSelectedUserId) {
    el.textContent = 'Aucun utilisateur sélectionné.';
    return;
  }
  const u = (USERS || []).find((x) => x.id === pushSelectedUserId)
    || pushSearchResults.find((x) => x.id === pushSelectedUserId);
  el.textContent = u ? `Sélectionné : ${u.name} · ${u.email}` : `Sélectionné : ${pushSelectedUserId}`;
}

function selectPushUser(userId) {
  pushSelectedUserId = userId;
  document.querySelectorAll('.push-user-item').forEach((el) => {
    el.classList.toggle('selected', el.dataset.userId === userId);
  });
  updatePushSelectedLabel();
  refreshPushPreview();
}

async function searchPushUsers() {
  const q = document.getElementById('push-user-search')?.value?.trim() || '';
  const box = document.getElementById('push-user-results');
  if (!box) return;
  box.innerHTML = '<p class="push-hint">Recherche…</p>';
  try {
    const rows = await MBApi.searchUsers(q, 20);
    pushSearchResults = (rows || []).map((r) => ({
      id: r.user_id,
      name: [r.prenom, r.nom].filter(Boolean).join(' ').trim() || r.email || '—',
      email: r.email || '—',
    }));
    if (!pushSearchResults.length) {
      box.innerHTML = '<p class="push-hint">Aucun utilisateur trouvé.</p>';
      return;
    }
    box.innerHTML = pushSearchResults.map((u) => `
      <button type="button" class="push-user-item${pushSelectedUserId === u.id ? ' selected' : ''}" data-user-id="${u.id}" onclick="selectPushUser('${u.id}')">
        <div><strong>${escapeHtml(u.name)}</strong><span>${escapeHtml(u.email)}</span></div>
        <i class="fa-solid fa-check" style="color:var(--gold2);opacity:${pushSelectedUserId === u.id ? 1 : 0};"></i>
      </button>`).join('');
  } catch (e) {
    box.innerHTML = `<p class="push-hint" style="color:var(--danger);">${escapeHtml(e.message || 'Erreur recherche')}</p>`;
  }
}

function buildPushPayload(dryRun) {
  const audience = document.getElementById('push-audience')?.value || 'all';
  const excludeBanned = document.getElementById('push-exclude-banned')?.checked !== false;
  const nav = document.getElementById('push-nav')?.value || 'none';
  const payload = {
    audience,
    excludeBanned,
    dryRun,
    nav,
  };
  if (audience === 'user') {
    payload.audience = 'user';
    payload.userId = pushSelectedUserId || undefined;
  } else if (audience === 'users') {
    payload.audience = 'users';
    payload.userIds = getPushFilteredUsers().map((u) => u.id);
  }
  if (!dryRun) {
    payload.title = document.getElementById('push-title')?.value?.trim() || '';
    payload.body = document.getElementById('push-body')?.value?.trim() || '';
  }
  return payload;
}

async function refreshPushPreview() {
  if (document.getElementById('push-audience')?.value === 'users') updatePushFilterSummary();
  const text = document.getElementById('push-preview-text');
  if (!text) return;
  const audience = document.getElementById('push-audience')?.value;
  if (audience === 'user' && !pushSelectedUserId) {
    text.textContent = 'Sélectionnez un utilisateur pour prévisualiser.';
    return;
  }
  if (audience === 'users' && !getPushFilteredUsers().length) {
    text.textContent = 'Aucun utilisateur ne correspond aux filtres.';
    return;
  }
  if (audience === 'prestataire_incomplete') {
    text.textContent = 'Cliquez sur Prévisualiser pour compter les prestataires au profil incomplet (token FCM).';
    return;
  }
  text.textContent = 'Cliquez sur Prévisualiser pour compter les destinataires FCM.';
}

async function previewPush() {
  const btn = document.getElementById('push-preview-btn');
  const text = document.getElementById('push-preview-text');
  const result = document.getElementById('push-result');
  try {
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>'; }
    const payload = buildPushPayload(true);
    if (payload.audience === 'user' && !payload.userId) throw new Error('Sélectionnez un utilisateur.');
    if (payload.audience === 'users' && (!payload.userIds || !payload.userIds.length)) {
      throw new Error('Aucun utilisateur ne correspond aux filtres.');
    }
    const r = await MBApi.pushInvoke(payload);
    const count = r?.recipients ?? 0;
    const label = count === 1 ? '1 destinataire avec token FCM' : `${count} destinataires avec token FCM`;
    if (text) text.textContent = label;
    if (result) result.textContent = `Prévisualisation : ${label}.`;
    showToast(label);
  } catch (e) {
    if (text) text.textContent = e.message || 'Erreur de prévisualisation';
    showToast(e.message || 'Erreur de prévisualisation');
  } finally {
    if (btn) { btn.disabled = false; btn.textContent = 'Prévisualiser'; }
  }
}

function openPushConfirmModal(payload) {
  pushPendingPayload = payload;
  const previewText = document.getElementById('push-preview-text')?.textContent || '';
  const hasCount = previewText
    && !previewText.startsWith('Cliquez')
    && !previewText.startsWith('Sélectionnez')
    && !previewText.startsWith('Aucun');
  openModalShell({
    title: 'Confirmer l’envoi',
    variant: 'warning',
    bodyHtml: `
      <div class="modal-alert modal-alert--warning">
        <div class="modal-alert-icon"><i class="fa-solid fa-paper-plane"></i></div>
        <div>
          <div class="modal-alert-title">Envoyer cette notification push ?</div>
          <div class="modal-alert-sub">L’envoi est immédiat aux destinataires avec un token FCM actif.</div>
        </div>
      </div>
      <div class="push-confirm-summary">
        <div class="push-confirm-row"><span>Audience</span><strong>${escapeHtml(pushAudienceLabel(payload.audience))}</strong></div>
        <div class="push-confirm-row"><span>Ouverture</span><strong>${escapeHtml(pushNavLabel(payload.nav))}</strong></div>
        <div class="push-confirm-row"><span>Titre</span><strong>${escapeHtml(payload.title || '—')}</strong></div>
        <div class="push-confirm-row push-confirm-row--block"><span>Message</span><p>${escapeHtml(payload.body || '—')}</p></div>
      </div>
      ${hasCount
        ? `<p class="modal-hint" style="margin-bottom:0;">${escapeHtml(previewText)}</p>`
        : '<p class="modal-hint" style="margin-bottom:0;">Astuce : utilise « Prévisualiser » avant l’envoi pour connaître le nombre de destinataires.</p>'}`,
    footerHtml: `
      <button type="button" class="btn btn-outline" onclick="closeModal(); pushPendingPayload=null;">Annuler</button>
      <button type="button" class="btn btn-primary" id="push-confirm-send-btn" onclick="confirmSendPush()">
        <i class="fa-solid fa-paper-plane"></i> Confirmer l’envoi
      </button>`,
  });
}

async function sendPush() {
  try {
    const payload = buildPushPayload(false);
    if (!payload.title) throw new Error('Le titre est obligatoire.');
    if (!payload.body) throw new Error('Le message est obligatoire.');
    if (payload.audience === 'user' && !payload.userId) throw new Error('Sélectionnez un utilisateur.');
    if (payload.audience === 'users' && (!payload.userIds || !payload.userIds.length)) {
      throw new Error('Aucun utilisateur ne correspond aux filtres.');
    }
    openPushConfirmModal(payload);
  } catch (e) {
    showToast(e.message || 'Erreur envoi push');
    const result = document.getElementById('push-result');
    if (result) result.textContent = e.message || 'Erreur envoi push';
  }
}

async function confirmSendPush() {
  const payload = pushPendingPayload;
  if (!payload) { closeModal(); return; }
  const btn = document.getElementById('push-send-btn');
  const confirmBtn = document.getElementById('push-confirm-send-btn');
  const result = document.getElementById('push-result');
  try {
    if (confirmBtn) {
      confirmBtn.disabled = true;
      confirmBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Envoi…';
    }
    closeModal();
    pushPendingPayload = null;
    if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Envoi…'; }
    const r = await MBApi.pushInvoke(payload);
    const msg = `Envoyé : ${r?.sent ?? 0} / ${r?.recipients ?? 0} destinataire(s)${r?.failed ? ` (${r.failed} échec(s))` : ''}`;
    if (result) result.textContent = msg;
    if (r?.credentialError) showToast(r.credentialError);
    else if (r?.failed > 0 && !r?.sent) showToast(r.firstError || msg);
    else showToast(msg);
    if (typeof MBLive?.reloadAudit === 'function') MBLive.reloadAudit();
  } catch (e) {
    showToast(e.message || 'Erreur envoi push');
    if (result) result.textContent = e.message || 'Erreur envoi push';
  } finally {
    if (btn) { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Envoyer'; }
  }
}
