/** Données live Supabase — branche le mockup UI (ui.js) */
(() => {
  const nf = new Intl.NumberFormat('fr-FR');
  const eur = (c) =>
    new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR', maximumFractionDigits: 0 }).format((c || 0) / 100);
  const fmtDate = (iso) => {
    if (!iso) return '—';
    const d = new Date(iso);
    return Number.isNaN(d.getTime()) ? '—' : d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' });
  };
  const fmtTime = (iso) => {
    if (!iso) return '';
    const d = new Date(iso);
    const n = new Date();
    if (d.toDateString() === n.toDateString()) return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
    return fmtDate(iso);
  };
  const cl = (code) => {
    const u = (code || 'XX').toUpperCase();
    if (u === 'XX') return 'Inconnu';
    try { return new Intl.DisplayNames(['fr'], { type: 'region' }).of(u) || u; } catch { return u; }
  };
  const flag = (code) => {
    const u = (code || 'XX').toUpperCase();
    return u.length === 2 ? String.fromCodePoint(...[...u].map((c) => 0x1f1e6 + c.charCodeAt(0) - 65)) : '🌍';
  };

  const SUBSCRIPTION_PLANS = [
    { tier: 'solo', interval: 'month', label: 'Solo · 1 service', price: '14,99 €', period: 'Mensuel' },
    { tier: 'solo', interval: 'year', label: 'Solo · 1 service', price: '150 €', period: 'Annuel' },
    { tier: 'multi', interval: 'month', label: 'Multi · 2+ services', price: '17,99 €', period: 'Mensuel' },
    { tier: 'multi', interval: 'year', label: 'Multi · 2+ services', price: '180 €', period: 'Annuel' },
  ];

  let chartsReady = false;
  let notifOpen = false;
  const store = {};
  window.MBAdminStore = store;

  function set(id, v) {
    const el = document.getElementById(id);
    if (el) el.textContent = v;
  }

  function setTrend(id, text) {
    const el = document.getElementById(id);
    if (!el) return;
    if (!text) { el.style.display = 'none'; return; }
    el.style.display = '';
    el.innerHTML = `<i class="fa-solid fa-arrow-trend-up"></i> ${text}`;
  }

  function mapUser(r) {
    const roles = Array.isArray(r.roles) ? r.roles : [];
    const hasClientProfile = Boolean(r.has_client_profile ?? r.hasClientProfile);
    const hasPrestaProfile = Boolean(r.has_prestataire_profile ?? r.hasPrestaProfile);
    const isClient = roles.includes('client') || hasClientProfile;
    const isPresta = roles.includes('prestataire') || hasPrestaProfile;
    const isAdmin = roles.includes('admin');
    let type = 'utilisateur';
    if (isAdmin) type = 'admin';
    else if (isPresta) type = 'prestataire';
    else if (isClient) type = 'client';
    const name = [r.prenom, r.nom].filter(Boolean).join(' ').trim() || r.email || '—';
    const cityRaw = r.client_ville || r.presta_ville || '';
    const city = cityRaw ? formatCityName(cityRaw) : '—';
    const rdvCount = r.reservations_count ?? r.reservationsCount;
    const prestaMissing = Array.isArray(r.presta_missing_labels)
      ? r.presta_missing_labels
      : (Array.isArray(r.prestaMissingLabels) ? r.prestaMissingLabels : []);
    return {
      id: r.user_id,
      name,
      prenom: r.prenom || '',
      nom: r.nom || '',
      email: r.email || '—',
      phone: r.telephone?.trim() || '—',
      city,
      rdv: rdvCount != null ? String(rdvCount) : '—',
      createdAt: r.created_at || r.createdAt || null,
      lastSignInAt: r.last_sign_in_at || r.lastSignInAt || null,
      hasFcmToken: Boolean(r.has_fcm_token ?? r.hasFcmToken),
      avatarUrl: r.avatar_url || r.avatarUrl || '',
      status: r.is_banned ? 'inactive' : 'active',
      sub: '—',
      roles,
      banReason: r.ban_reason || '',
      bannedAt: r.banned_at,
      type,
      isClient,
      isPresta,
      isAdmin,
      hasClientProfile,
      hasPrestaProfile,
      clientAdresse: r.client_adresse || '',
      clientVille: formatCityName(r.client_ville || ''),
      clientCodePostal: r.client_code_postal || '',
      clientPays: r.client_pays || '',
      prestaId: r.presta_id || '',
      prestaNomSalon: r.presta_nom_salon || '',
      prestaAdresse: r.presta_adresse || '',
      prestaVille: formatCityName(r.presta_ville || ''),
      prestaCodePostal: r.presta_code_postal || '',
      prestaPays: r.presta_pays || '',
      prestaIsVerified: Boolean(r.presta_is_verified),
      prestaIsProfileComplete: r.presta_is_profile_complete,
      prestaIsCatalogVisible: r.presta_is_catalog_visible,
      prestaMissingLabels: prestaMissing,
      specialty: r.presta_nom_salon || '—',
    };
  }

  function buildPays(countries) {
    return (countries || []).map((c) => {
      const rev = (c.revenue_captured_cents || 0) / 100;
      const presta = c.prestataires_count || 0;
      const clients = c.clients_count || 0;
      const rdv = c.reservations_total || 0;
      return {
        pays: cl(c.country_code), flag: flag(c.country_code),
        users: clients + presta, clients, presta, rdv,
        trend: (c.reservations_this_month || 0) > 0 ? 'up' : 'stable',
        rev, abo: 0, comm: rev,
        reservationsThisMonth: c.reservations_this_month || 0,
      };
    });
  }

  function planCounts(summary, tier, interval) {
    const plans = summary?.plans || [];
    const row = plans.find((p) => p.tier === tier && (p.interval === interval || p.interval_key === interval));
    return { active: row?.active_count || 0, total: row?.total_count || 0 };
  }

  function groupPhotosByUser(photos) {
    const byUser = new Map();
    (photos || []).forEach((p) => {
      const key = p.prestataire_user_id || p.prestataireUserId || p.prestataire_id || p.prestataireId || p.id;
      if (!byUser.has(key)) byUser.set(key, []);
      byUser.get(key).push(p);
    });
    const groups = [];
    byUser.forEach((items) => {
      items.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      const first = items[0];
      groups.push({
        label: first.prestataire_label || first.prestataireLabel || '—',
        email: first.owner_email || first.ownerEmail || '',
        photos: items,
      });
    });
    groups.sort((a, b) => a.label.localeCompare(b.label, 'fr'));
    return groups;
  }

  function renderPhotoTile(p, busy) {
    const id = p.id;
    PHOTO_BY_ID[id] = p;
    const esc = window.escapeHtml || ((s) => String(s || ''));
    const fmt = window.fmtPhotoDate || (() => '—');
    const isVideo = (p.media_type || p.mediaType) === 'video';
    const busyCls = busy ? ' photo-tile-busy' : '';
    const media = isVideo
      ? `<video src="${esc(p.url)}" muted playsinline preload="metadata"></video><div class="photo-tile-play"><i class="fa-solid fa-play"></i></div>`
      : `<img src="${esc(p.url)}" alt="" loading="lazy">`;
    return `
      <div class="photo-tile${busyCls}" onclick="openPhotoPreview('${id}')">
        <div class="photo-tile-media">
          ${busy ? '<div class="photo-tile-spinner"><i class="fa-solid fa-spinner fa-spin"></i></div>' : ''}
          ${media}
          <div class="photo-tile-date">${fmt(p.created_at)}</div>
        </div>
        <div class="photo-tile-menu-wrap" onclick="event.stopPropagation()">
          <button type="button" class="photo-tile-menu-btn" onclick="togglePhotoMenu(this, event)"><i class="fa-solid fa-ellipsis-vertical"></i></button>
          <div class="photo-tile-dropdown">
            <button type="button" onclick="MBLive.photoDownload('${id}')"><i class="fa-solid fa-download"></i> Ouvrir / télécharger</button>
            <button type="button" class="danger" onclick="openPhotoDeleteConfirm('${id}')"><i class="fa-solid fa-trash"></i> Supprimer</button>
            <button type="button" class="danger" onclick="openPhotoFlagConfirm('${id}')"><i class="fa-solid fa-flag"></i> Signaler (obscène)</button>
            <button type="button" onclick="openPhotoWarnModal('${id}')"><i class="fa-solid fa-triangle-exclamation"></i> Avertir le compte</button>
            <button type="button" class="danger" onclick="openPhotoBanModal('${id}')"><i class="fa-solid fa-ban"></i> Bannir le compte</button>
          </div>
        </div>
      </div>`;
  }

  function renderPhotosGallery() {
    const root = document.getElementById('photos-gallery');
    const countLabel = document.getElementById('photos-count-label');
    if (!root) return;
    const photos = store.photos || [];
    PHOTO_BY_ID = {};
    window.PHOTO_BY_ID = PHOTO_BY_ID;
    const esc = window.escapeHtml || ((s) => String(s || ''));
    const groups = groupPhotosByUser(photos);
    if (countLabel) {
      countLabel.textContent = photos.length
        ? `${photos.length} média${photos.length > 1 ? 's' : ''} · ${groups.length} compte${groups.length > 1 ? 's' : ''}`
        : 'Aucun média';
    }
    if (!photos.length) {
      root.innerHTML = `
        <div class="photos-empty">
          <i class="fa-solid fa-images"></i>
          <div style="font-size:15px;font-weight:600;color:var(--text);margin-bottom:6px;">Aucune photo de réalisation</div>
          <div>Essayez une autre recherche ou actualisez la liste.</div>
        </div>`;
      return;
    }
    const busy = store.photosBusy || new Set();
    root.innerHTML = groups.map((g) => `
      <div class="photos-group-card">
        <div class="photos-group-header">
          <div class="photos-group-avatar"><i class="fa-solid fa-user"></i></div>
          <div>
            <div class="photos-group-name">${esc(g.label)}</div>
            ${g.email ? `<div class="photos-group-email">${esc(g.email)}</div>` : ''}
            <div class="photos-group-count">${g.photos.length} média${g.photos.length > 1 ? 's' : ''}</div>
          </div>
        </div>
        <div class="photos-grid">
          ${g.photos.map((p) => renderPhotoTile(p, busy.has(p.id))).join('')}
        </div>
      </div>`).join('');
  }

  async function reloadPhotos(showCountToast = true) {
    const q = document.getElementById('photos-search')?.value?.trim() || '';
    store.photosSearch = q;
    try {
      store.photos = await MBApi.listPhotos(200, 0, q) || [];
      renderPhotosGallery();
      if (showCountToast) showToast(`${store.photos.length} média(s)`);
    } catch (e) {
      showToast(e.message || 'Impossible de charger les photos');
    }
  }

  window.renderPhotosGallery = renderPhotosGallery;

  function computeRdvStats(reservations) {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekStart = new Date(todayStart);
    weekStart.setDate(weekStart.getDate() - 6);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    let today = 0; let week = 0; let month = 0; let monthCommission = 0;
    (reservations || []).forEach((r) => {
      const d = new Date(r.date_heure);
      if (Number.isNaN(d.getTime())) return;
      if (d >= todayStart) today++;
      if (d >= weekStart) week++;
      if (d >= monthStart) {
        month++;
        if (r.payment_status === 'captured') monthCommission += r.amount_cents || 0;
      }
    });
    return { today, week, month, monthCommission };
  }

  function last12MonthLabels() {
    const labels = [];
    const now = new Date();
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      labels.push(d.toLocaleDateString('fr-FR', { month: 'short' }));
    }
    return labels;
  }

  function aggregateRevenueByMonth(reservations) {
    const buckets = [];
    const now = new Date();
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      buckets.push({ y: d.getFullYear(), m: d.getMonth(), sum: 0 });
    }
    (reservations || []).forEach((r) => {
      if (r.payment_status !== 'captured') return;
      const dt = new Date(r.paid_at || r.date_heure);
      if (Number.isNaN(dt.getTime())) return;
      const b = buckets.find((x) => x.y === dt.getFullYear() && x.m === dt.getMonth());
      if (b) b.sum += r.amount_cents || 0;
    });
    return buckets.map((b) => Math.round(b.sum / 100));
  }

  function supportUnread(threads) {
    return (threads || []).reduce((s, t) => s + Number(t.unread_count || 0), 0);
  }

  function notifTotal(a, unread) {
    return (a?.verification_pending || 0) + (a?.reports_pending || 0) + (a?.bugs_pending || 0) + unread;
  }

  function buildNotifItems(a, unread) {
    const items = [];
    if ((a?.verification_pending || 0) > 0) {
      items.push({ label: `${a.verification_pending} vérification(s) en attente`, section: 'verifications', sub: 'Prestataires à valider' });
    }
    if ((a?.reports_pending || 0) > 0) {
      items.push({ label: `${a.reports_pending} signalement(s) contenu`, section: 'content-reports', sub: 'Modération requise' });
    }
    if ((a?.bugs_pending || 0) > 0) {
      items.push({ label: `${a.bugs_pending} bug(s) signalé(s)`, section: 'feedback', sub: 'Retours utilisateurs' });
    }
    if (unread > 0) {
      items.push({ label: `${unread} message(s) support non lu(s)`, section: 'messages', sub: 'Messagerie admin' });
    }
    return items;
  }

  function renderNotifPanel() {
    const panel = document.getElementById('notif-panel');
    if (!panel) return;
    const a = store.analytics;
    const unread = store.supportUnread || 0;
    const items = buildNotifItems(a, unread);
    if (!items.length) {
      panel.innerHTML = '<div class="notif-panel-header">Notifications</div><div class="notif-empty">Aucune alerte en attente</div>';
      return;
    }
    panel.innerHTML = `<div class="notif-panel-header">Notifications (${items.length})</div>${
      items.map((it) => `<button type="button" class="notif-item" onclick="openNotifSection('${it.section}')">${it.label}<small>${it.sub}</small></button>`).join('')
    }`;
  }

  function updateNotifDot() {
    const dot = document.getElementById('notif-dot');
    if (!dot) return;
    const total = notifTotal(store.analytics, store.supportUnread || 0);
    dot.style.display = total > 0 ? '' : 'none';
  }

  window.toggleNotifPanel = (ev) => {
    ev?.stopPropagation();
    const panel = document.getElementById('notif-panel');
    if (!panel) return;
    notifOpen = !notifOpen;
    panel.style.display = notifOpen ? 'block' : 'none';
    if (notifOpen) renderNotifPanel();
  };

  window.openNotifSection = (sectionId) => {
    notifOpen = false;
    const panel = document.getElementById('notif-panel');
    if (panel) panel.style.display = 'none';
    const nav = document.querySelector(`.nav-item[onclick*="${sectionId}"]`);
    showSection(sectionId, nav);
  };

  function applyKpis(a) {
    if (!a) return;
    const unread = store.supportUnread || 0;

    set('kpi-users', nf.format(a.users_total || 0));
    set('kpi-clients', nf.format(a.clients_total || 0));
    set('kpi-presta', nf.format(a.prestataires_total || 0));
    set('kpi-rdv', nf.format(a.reservations_total || 0));
    set('kpi-total', eur(a.revenue_captured_cents));
    set('kpi-rdv-rev', eur(a.revenue_captured_cents));
    set('kpi-sub-rev', '—');

    set('sec-users-sub', `${nf.format(a.users_total || 0)} comptes enregistrés`);
    set('sec-clients-sub', `${nf.format(a.clients_total || 0)} clients inscrits`);
    set('sec-presta-sub', `${nf.format(a.prestataires_total || 0)} prestataires inscrits`);
    set('sec-rdv-sub', `${nf.format(a.reservations_total || 0)} réservations au total`);

    if (a.reservations_this_month > 0) {
      setTrend('kpi-trend-rdv', `+${nf.format(a.reservations_this_month)} ce mois`);
      setTrend('kpi-trend-rdv-rev', `+${eur(a.revenue_this_month_cents)} ce mois`);
    }

    const totalUsers = (a.clients_total || 0) + (a.prestataires_total || 0);
    if (totalUsers > 0) {
      const cPct = Math.round(((a.clients_total || 0) / totalUsers) * 100);
      set('pie-legend-clients', `Clients ${cPct}%`);
      set('pie-legend-presta', `Prestataires ${100 - cPct}%`);
    }

    const navUsers = document.getElementById('nav-badge-users');
    if (navUsers) navUsers.textContent = nf.format(a.users_total || 0);

    const navMsg = document.getElementById('nav-badge-messages');
    if (navMsg) {
      navMsg.textContent = nf.format(unread);
      navMsg.style.display = unread > 0 ? '' : 'none';
    }

    const navFb = document.getElementById('nav-badge-feedback');
    if (navFb) {
      navFb.textContent = nf.format(a.bugs_pending || 0);
      navFb.style.display = (a.bugs_pending || 0) > 0 ? '' : 'none';
    }

    const navVer = document.getElementById('nav-badge-verifications');
    if (navVer) {
      navVer.textContent = nf.format(a.verification_pending || 0);
      navVer.style.display = (a.verification_pending || 0) > 0 ? '' : 'none';
    }

    const navCr = document.getElementById('nav-badge-content-reports');
    if (navCr) {
      navCr.textContent = nf.format(a.reports_pending || 0);
      navCr.style.display = (a.reports_pending || 0) > 0 ? '' : 'none';
    }

    const rdv = computeRdvStats(store.reservations);
    set('rdv-today', nf.format(rdv.today));
    set('rdv-week', nf.format(rdv.week));
    set('rdv-month', nf.format(a.reservations_this_month || rdv.month));
    set('rdv-commission-month', eur(a.revenue_this_month_cents || rdv.monthCommission));

    set('finance-total', eur(a.revenue_captured_cents));
    set('finance-sub-monthly', '—');
    set('finance-sub-monthly-rev', 'Non disponible');
    set('finance-sub-yearly', '—');
    set('finance-sub-yearly-rev', 'Non disponible');
    set('finance-comm-total', eur(a.revenue_captured_cents));
    const captured = (store.reservations || []).filter((r) => r.payment_status === 'captured').length;
    set('finance-comm-note', `${nf.format(captured)} RDV capturés`);

    const bugs = store.bugs || [];
    const bugsPending = bugs.filter((b) => ['pending', 'in_progress'].includes(b.status)).length;
    const bugsResolved = bugs.filter((b) => b.status === 'resolved').length;
    set('feedback-bugs-total', nf.format(bugs.length));
    set('feedback-bugs-pending', nf.format(a.bugs_pending ?? bugsPending));
    set('feedback-bugs-resolved', nf.format(bugsResolved));
    set('feedback-reports-pending', nf.format(a.reports_pending || 0));

    applyPaysKpis();
    set('sec-pays-revenue-sub', `Analyse financière — ${eur(a.revenue_captured_cents)} générés`);

    const clientUsers = (USERS || []).filter((u) => u.isClient);
    const bannedClients = clientUsers.filter((u) => u.status === 'inactive').length;
    set('clients-kpi-total', nf.format(a.clients_total || clientUsers.length));
    set('clients-kpi-active', nf.format(clientUsers.length - bannedClients));
    set('clients-kpi-banned', nf.format(bannedClients));
    set('clients-kpi-total-note', `${nf.format(clientUsers.length)} profils client`);
    set('sec-feedback-sub', `${nf.format(store.bugs?.length || 0)} signalements · ${nf.format(a.bugs_pending || 0)} en attente`);

    updateNotifDot();
    if (notifOpen) renderNotifPanel();
  }

  function applyPaysKpis() {
    const countries = store.countries || [];
    const analytics = store.analytics || {};
    const enriched = countries.map((c) => ({
      ...c,
      usersTotal: (c.clients_count || 0) + (c.prestataires_count || 0),
    }));
    const sorted = [...enriched].sort((a, b) => b.usersTotal - a.usersTotal);
    const clientsGeo = sorted.reduce((s, c) => s + (c.clients_count || 0), 0);
    const prestaGeo = sorted.reduce((s, c) => s + (c.prestataires_count || 0), 0);
    const monthRes = sorted.reduce((s, c) => s + (c.reservations_this_month || 0), 0);
    const platformClients = analytics.clients_total ?? clientsGeo;
    const platformPresta = analytics.prestataires_total ?? prestaGeo;

    set('pays-count', nf.format(sorted.length));
    set('pays-count-note', `${nf.format(platformClients)} clients · ${nf.format(platformPresta)} prestataires (plateforme)`);

    if (sorted.length && (clientsGeo + prestaGeo) > 0) {
      const top = sorted[0];
      const topClients = top.clients_count || 0;
      const topPresta = top.prestataires_count || 0;
      const topVal = topClients + topPresta;
      const geoTotal = clientsGeo + prestaGeo;
      const pct = geoTotal ? ((topVal / geoTotal) * 100).toFixed(1) : '0';
      set('pays-top-label', `1er pays — ${cl(top.country_code)}`);
      set('pays-top-value', `${nf.format(topClients)} clients · ${nf.format(topPresta)} presta`);
      setTrend('pays-top-pct', `${pct}% de l'activité géo.`);
      set('pays-abroad', nf.format(Math.max(geoTotal - topVal, 0)));
      set('pays-abroad-pct', 'Clients + prestataires hors 1er pays');
    } else {
      set('pays-top-label', '1er pays');
      set('pays-top-value', '—');
      set('pays-abroad', '—');
      set('pays-abroad-pct', '—');
    }

    set('pays-month-rdv', nf.format(monthRes));
    set('pays-month-note', 'Réservations ce mois');
    set(
      'sec-pays-users-sub',
      sorted.length
        ? `${nf.format(clientsGeo)} clients ayant réservé · ${nf.format(prestaGeo)} salons · ${nf.format(sorted.length)} pays`
        : 'Aucune donnée géographique',
    );
  }

  function updateCharts(a) {
    if (!chartsReady || !a) return;

    if (typeof userPieChartObj !== 'undefined' && userPieChartObj) {
      userPieChartObj.data.datasets[0].data = [a.clients_total || 0, a.prestataires_total || 0];
      userPieChartObj.update();
    }

    if (typeof revPieChartObj !== 'undefined' && revPieChartObj) {
      const t = a.revenue_captured_cents || 0;
      revPieChartObj.data.datasets[0].data = [0, t];
      revPieChartObj.update();
    }

    const rdvMonthly = aggregateRevenueByMonth(store.reservations);
    window.REVENUE_CHART_SUB = rdvMonthly.map(() => 0);
    window.REVENUE_CHART_RDV = rdvMonthly;

    if (typeof revenueChartObj !== 'undefined' && revenueChartObj) {
      revenueChartObj.data.labels = last12MonthLabels();
      revenueChartObj.data.datasets[0].data = window.REVENUE_CHART_SUB;
      revenueChartObj.data.datasets[1].data = window.REVENUE_CHART_RDV;
      revenueChartObj.update();
    }

    if (typeof subChartObj !== 'undefined' && subChartObj) {
      subChartObj.data.datasets[0].data = [0, 0, 0, 0, 0];
      subChartObj.data.datasets[1].data = [0, 0, 0, 0, 0];
      subChartObj.update();
    }
  }

  function renderMobile() {
    const tb = (id, html) => { const el = document.getElementById(id); if (el) el.innerHTML = html || '<tr><td colspan="6" style="color:var(--text3);padding:20px;text-align:center;">Aucune donnée</td></tr>'; };

    tb('verifications-tbody', (store.verifications || []).map((v) => `
      <tr><td>${v.display_name || '—'}</td><td>${v.nom_salon || '—'}</td><td>${formatCityName(v.ville) || '—'}</td>
      <td><span class="badge ${v.is_verified ? 'active' : 'pending'}">${v.is_verified ? 'Vérifié' : 'En attente'}</span></td>
      <td style="display:flex;gap:6px;">
        ${!v.is_verified ? `<button class="btn btn-gold btn-sm" onclick="MBLive.approveVer('${v.id}')"><i class="fa-solid fa-check"></i></button>` : ''}
        ${v.is_verified ? `<button class="btn btn-danger btn-sm" onclick="MBLive.revokeVer('${v.id}')"><i class="fa-solid fa-ban"></i></button>` : ''}
      </td></tr>`).join(''));

    tb('content-reports-tbody', (store.contentReports || []).map((r) => `
      <tr><td>${r.reporter_display_name || r.reporter_email || '—'}</td><td>${r.target_label || r.target_type}</td><td>${r.reason}</td><td>${fmtDate(r.created_at)}</td>
      <td><button class="btn btn-outline btn-sm" onclick="MBLive.dismissReport('${r.id}')">Traiter</button></td></tr>`).join(''));

    renderPhotosGallery();

    renderAuditTable();

    if (store.trial) {
      const t = store.trial;
      const inp = document.getElementById('trial-days');
      if (inp) inp.value = t.catalog_trial_days ?? t.catalogTrialDays ?? 90;
      const st = document.getElementById('trial-stats');
      if (st) st.textContent = `En essai : ${t.prestataires_in_trial ?? t.prestatairesInTrial ?? 0} · Expirés sans abo : ${t.prestataires_expired_without_sub ?? t.prestatairesExpiredWithoutSub ?? 0}`;
    }
    if (store.fee) {
      const f = store.fee;
      const fc = document.getElementById('fee-cents');
      const ff = document.getElementById('fee-free');
      if (fc) fc.value = f.fee_cents ?? f.feeCents ?? 0;
      if (ff) ff.value = f.free_booking_count ?? f.freeBookingCount ?? 2;
    }
  }

  function renderForfaits() {
    const grid = document.getElementById('forfaits-grid');
    if (!grid) return;
    const summary = store.subscriptionPlans || {};
    const trial = summary.catalog_trial || store.trial || {};
    const inTrial = trial.prestataires_in_trial ?? trial.prestatairesInTrial ?? 0;
    const expired = trial.prestataires_expired_without_sub ?? trial.prestatairesExpiredWithoutSub ?? 0;
    const statusCounts = summary.status_counts || {};
    const activeTotal = (statusCounts.active || 0) + (statusCounts.trialing || 0);
    const trialDays = trial.catalog_trial_days ?? trial.catalogTrialDays ?? 90;

    const planCards = SUBSCRIPTION_PLANS.map((plan, i) => {
      const counts = planCounts(summary, plan.tier, plan.interval);
      return `
      <div class="plan-card${i === 0 ? ' featured' : ''}">
        ${i === 0 ? '<div class="plan-badge">Stripe Billing</div>' : ''}
        <div class="plan-name">${plan.label}</div>
        <div class="plan-period" style="font-size:12px;color:var(--text3);margin-top:4px;">${plan.period}</div>
        <div class="plan-price">${plan.price}</div>
        <p style="font-size:13px;color:var(--text2);margin:12px 0 0;">
          <strong style="color:var(--gold2);">${nf.format(counts.active)}</strong> actif(s)
          · ${nf.format(counts.total)} au total
        </p>
      </div>`;
    }).join('');

    const statCards = [
      { title: 'Abonnements actifs', value: nf.format(activeTotal), note: 'Tous paliers Stripe (actif + essai facturation)' },
      { title: 'Essai catalogue', value: nf.format(inTrial), note: `${trialDays} jours offerts` },
      { title: 'Sans abo après essai', value: nf.format(expired), note: 'Prestataires à relancer' },
    ].map((c) => `
      <div class="plan-card">
        <div class="plan-name">${c.title}</div>
        <div class="plan-price">${c.value}</div>
        <p style="font-size:13px;color:var(--text3);margin:12px 0 0;">${c.note}</p>
      </div>`).join('');

    grid.innerHTML = planCards + statCards;
  }

  function applyPaysRevenueKpis() {
    const sorted = [...PAYS_DATA].sort((a, b) => b.rev - a.rev);
    const totalRev = sorted.reduce((s, p) => s + p.rev, 0);
    if (!sorted.length || !totalRev) {
      set('pays-rev-top-total', '—');
      set('pays-rev-abroad-total', '—');
      set('pays-rev-arpu', '—');
      return;
    }
    const top = sorted[0];
    const abroad = totalRev - top.rev;
    const arpu = totalRev / sorted.length;
    set('pays-rev-top-total', eur(top.rev * 100));
    set('pays-rev-top-pct', `${top.pays} · ${((top.rev / totalRev) * 100).toFixed(1)}% du CA`);
    set('pays-rev-abroad-total', eur(abroad * 100));
    set('pays-rev-abroad-note', `${((abroad / totalRev) * 100).toFixed(1)}% du CA`);
    set('pays-rev-arpu', `${arpu.toFixed(2)} €`);
  }

  async function safeLoad(name, fn, fallback = null) {
    try { return await fn(); } catch (e) { console.error(`[admin] ${name}`, e); return fallback; }
  }

  window.searchUsersAdmin = async () => {
    const q = document.getElementById('users-search')?.value?.trim() || '';
    userListFilter.query = q;
    try {
      const users = await MBApi.searchUsers(q, 200);
      USERS = (users || []).map(mapUser);
      store.users = users;
      renderTables();
      showToast(`${USERS.length} utilisateur(s)`);
    } catch (e) { showToast(e.message || 'Erreur recherche'); }
  };

  window.reloadReservations = async () => {
    const statut = document.getElementById('rdv-filter-statut')?.value || '';
    const paymentStatus = document.getElementById('rdv-filter-payment')?.value || '';
    const fromVal = document.getElementById('rdv-filter-from')?.value;
    const toVal = document.getElementById('rdv-filter-to')?.value;
    const filters = {
      statut: statut || null,
      paymentStatus: paymentStatus || null,
      from: fromVal ? new Date(`${fromVal}T00:00:00`).toISOString() : null,
      to: toVal ? new Date(`${toVal}T23:59:59`).toISOString() : null,
    };
    try {
      const reservations = await MBApi.listReservations(200, filters);
      store.reservations = reservations || [];
      RDV_DATA = (reservations || []).map((r) => ({
        client: r.client_name || '—', presta: r.prestataire_salon || '—', service: r.service_name || '—',
        date: fmtDate(r.date_heure), city: '—',
        commission: r.amount_cents != null ? eur(r.amount_cents) : '—',
        status: /annul|cancel/i.test(r.statut || '') ? 'annule' : 'confirme',
        statut: r.statut, payment_status: r.payment_status,
      }));
      renderTables();
    } catch (e) { showToast(e.message || 'Erreur réservations'); }
  };

  async function loadSupportThread(threadId) {
    const chat = CHATS.find((c) => c.id === threadId);
    if (!chat) return;
    try {
      const adminId = MBApi.getUser()?.id;
      const rows = await MBApi.listSupportMessages(threadId);
      chat.messages = (rows || []).map((m) => ({
        from: m.sender_id === adminId ? 'admin' : 'user',
        text: m.content,
      }));
      await MBApi.markSupportThreadRead(threadId);
      chat.unread = 0;
      loadChat(threadId);
      updateChatBanButton();
    } catch (e) {
      showToast(e.message || 'Impossible de charger la conversation');
    }
  }

  async function loadAll() {
    const [
      analytics, users, reservations, countries, bugs, threads,
      verifications, contentReports, photos, audit, verificationEvents, trial, fee, prestataireTrials,
      subscriptionPlans,
    ] = await Promise.all([
      safeLoad('analytics', () => MBApi.getAnalytics(), {}),
      safeLoad('users', () => MBApi.searchUsers('', 200), []),
      safeLoad('reservations', () => MBApi.listReservations(200), []),
      safeLoad('countries', () => MBApi.getCountries(), []),
      safeLoad('bugs', () => MBApi.listBugReports(false, 50), []),
      safeLoad('threads', () => MBApi.listSupportThreads(50), []),
      safeLoad('verifications', () => MBApi.listVerifications(true), []),
      safeLoad('contentReports', () => MBApi.listContentReports(true, 100), []),
      safeLoad('photos', () => MBApi.listPhotos(200, 0, store.photosSearch || ''), []),
      safeLoad('audit', () => MBApi.listAudit(200), []),
      safeLoad('verificationEvents', () => MBApi.listVerificationEvents(200), []),
      safeLoad('trial', () => MBApi.getTrialSettings(), {}),
      safeLoad('fee', () => MBApi.getPlatformFee(), {}),
      safeLoad('prestataireTrials', () => MBApi.searchPrestataireTrials('', 200), []),
      safeLoad('subscriptionPlans', () => MBApi.getSubscriptionPlans(), {}),
    ]);

    store.analytics = analytics;
    store.users = users;
    store.reservations = reservations;
    store.countries = Array.isArray(countries) ? countries : [];
    store.bugs = bugs || [];
    store.threads = threads || [];
    store.supportUnread = supportUnread(threads);
    store.verifications = verifications || [];
    store.contentReports = contentReports || [];
    store.photos = photos || [];
    store.audit = audit || [];
    store.verificationEvents = verificationEvents || [];
    store.trial = trial;
    store.fee = fee;
    store.prestataireTrials = prestataireTrials || [];
    store.prestataireSubscriptions = store.prestataireSubscriptions || [];
    store.subscriptionPlans = subscriptionPlans || {};
    store.photosBusy = store.photosBusy || new Set();
    const photosSearchInput = document.getElementById('photos-search');
    if (photosSearchInput && store.photosSearch) photosSearchInput.value = store.photosSearch;

    USERS = (users || []).map(mapUser);
    RDV_DATA = (reservations || []).map((r) => ({
      client: r.client_name || '—', presta: r.prestataire_salon || '—', service: r.service_name || '—',
      date: fmtDate(r.date_heure), city: '—',
      commission: r.amount_cents != null ? eur(r.amount_cents) : '—',
      status: /annul|cancel/i.test(r.statut || '') ? 'annule' : 'confirme',
    }));
    PAYMENTS = (reservations || [])
      .filter((r) => r.payment_status === 'captured')
      .slice(0, 50)
      .map((r) => ({
        user: r.client_name || '—',
        type: 'Commission RDV',
        plan: r.service_name || '—',
        amount: eur(r.amount_cents),
        date: fmtDate(r.paid_at || r.date_heure),
        status: 'active',
      }));
    FEEDBACKS = (bugs || []).map((b) => ({
      id: b.id,
      user: b.reporter_display_name || b.reporter_email || 'Utilisateur',
      role: b.category || 'Signalement',
      status: b.status,
      stars: 0,
      date: fmtDate(b.created_at),
      text: b.description || b.title || '',
    }));
    CHATS = (threads || []).map((t, i) => ({
      id: t.thread_id || `t-${i}`,
      userId: t.user_id,
      name: t.user_display_name || t.user_email || '—',
      preview: t.last_message || '—',
      time: fmtTime(t.last_message_at || t.updated_at),
      unread: Number(t.unread_count || 0),
      messages: [],
    }));
    PAYS_DATA = buildPays(store.countries);
    applyPaysRevenueKpis();
    ZONES = [...store.countries].sort((a, b) => (b.reservations_total || 0) - (a.reservations_total || 0))
      .slice(0, 10).map((c) => ({ city: cl(c.country_code), count: c.reservations_total || 0 }));

    applyKpis(analytics);
    if (!chartsReady) { initCharts(); chartsReady = true; }
    updateCharts(analytics);
    renderTables();
    renderChats();
    const chatTitle = document.getElementById('chat-list-title');
    if (chatTitle) chatTitle.textContent = `Conversations (${CHATS.length})`;
    if (CHATS.length && typeof MBLive.loadSupportThread === 'function') {
      await MBLive.loadSupportThread(CHATS[0].id);
    }
    renderFeedback();
    renderForfaits();
    if (document.getElementById('sec-forfaits')?.classList.contains('active')) {
      renderPrestataireSubscriptions();
    }
    renderZones();
    if (typeof zonesChartObj !== 'undefined' && zonesChartObj) {
      if (ZONES.length) {
        const top = ZONES.slice(0, 5);
        const autres = ZONES.slice(5).reduce((s, z) => s + z.count, 0);
        zonesChartObj.data.labels = [...top.map((z) => z.city), ...(autres ? ['Autres'] : [])];
        zonesChartObj.data.datasets[0].data = [...top.map((z) => z.count), ...(autres ? [autres] : [])];
        zonesChartObj.update();
      } else {
        zonesChartObj.data.labels = [];
        zonesChartObj.data.datasets[0].data = [];
        zonesChartObj.update();
      }
    }
    renderMobile();
    if (typeof renderPushIncompletePanel === 'function') {
      renderPushIncompletePanel();
    }
  }

  async function enter() {
    document.getElementById('login-screen').style.display = 'none';
    const u = MBApi.getUser();
    const email = u?.email || '';
    document.querySelectorAll('.admin-name').forEach((el) => { el.textContent = email.split('@')[0] || 'Admin'; });
    document.querySelectorAll('.admin-role').forEach((el) => { el.textContent = email; });
    document.querySelectorAll('.admin-avatar').forEach((el) => { el.textContent = (email[0] || 'A').toUpperCase(); });
    await loadAll();
  }

  window.doLogin = async () => {
    const err = document.getElementById('login-error');
    const btn = document.querySelector('.login-btn');
    err.style.display = 'none';
    btn.disabled = true;
    try {
      await MBApi.signIn(document.getElementById('login-email').value.trim(), document.getElementById('login-pwd').value);
      await enter();
    } catch (e) {
      err.textContent = e.message || 'Identifiants incorrects.';
      err.style.display = 'block';
    } finally { btn.disabled = false; }
  };

  window.doLogout = async () => {
    await MBApi.signOut();
    chartsReady = false;
    notifOpen = false;
    document.getElementById('login-screen').style.display = 'flex';
    showToast('Déconnexion réussie');
  };

  window.refreshData = async () => {
    try { await loadAll(); showToast('Données actualisées'); } catch (e) { showToast(e.message); }
  };

  async function reloadAudit() {
    try {
      store.audit = await MBApi.listAudit(200) || [];
      store.verificationEvents = await MBApi.listVerificationEvents(200) || [];
      renderAuditTable();
      showToast('Journal d\'audit actualisé');
    } catch (e) { showToast(e.message || 'Erreur audit'); }
  }

  window.saveTrialDays = async () => {
    try {
      store.trial = await MBApi.updateTrialDays(parseInt(document.getElementById('trial-days').value, 10));
      renderMobile();
      showToast('Essai catalogue mis à jour');
    } catch (e) { showToast(e.message); }
  };

  window.savePlatformFee = async () => {
    try {
      store.fee = await MBApi.updatePlatformFee(
        parseInt(document.getElementById('fee-cents').value, 10),
        parseInt(document.getElementById('fee-free').value, 10),
      );
      showToast('Commission mise à jour');
    } catch (e) { showToast(e.message); }
  };

  window.applyPaysRevenueKpis = applyPaysRevenueKpis;
  window.openSupportForUser = (userId) => {
    const chat = CHATS.find((c) => c.userId === userId);
    const nav = document.querySelector('.nav-item[onclick*="messages"]');
    showSection('messages', nav);
    if (!chat) {
      showToast('Aucune conversation support pour cet utilisateur');
      return;
    }
    setTimeout(() => {
      const items = document.querySelectorAll('.chat-item');
      const idx = CHATS.findIndex((c) => c.id === chat.id);
      if (items[idx]) selectChat(chat.id, items[idx]);
    }, 50);
  };

  window.MBLive = {
    loadSupportThread,
    sendSupportMessage: async () => {
      const threadId = window.activeChatId;
      const inp = document.getElementById('chat-input');
      const txt = inp?.value?.trim();
      if (!threadId || !txt) return;
      try {
        await MBApi.sendSupportMessage(threadId, txt);
        inp.value = '';
        await loadSupportThread(threadId);
        store.supportUnread = supportUnread(store.threads);
        const threads = await MBApi.listSupportThreads(50);
        store.threads = threads || [];
        store.supportUnread = supportUnread(threads);
        applyKpis(store.analytics);
        showToast('Message envoyé');
      } catch (e) { showToast(e.message); }
    },
    blockChatUser: async () => {
      const chat = CHATS.find((c) => c.id === window.activeChatId);
      if (!chat?.userId) { showToast('Utilisateur introuvable'); return; }
      const u = USERS.find((x) => x.id === chat.userId);
      if (u?.status === 'active') openBanModal(chat.userId);
      else openUnbanModal(chat.userId);
    },
    approveVer: async (id) => { try { await MBApi.approveVerification(id); await loadAll(); showToast('Vérification approuvée'); } catch (e) { showToast(e.message); } },
    revokeVer: async (id) => { try { await MBApi.revokeVerification(id); await loadAll(); showToast('Vérification révoquée'); } catch (e) { showToast(e.message); } },
    dismissReport: async (id) => { try { await MBApi.moderateContentReport(id, 'dismiss'); await loadAll(); showToast('Signalement traité'); } catch (e) { showToast(e.message); } },
    reloadPhotos,
    photoDownload: (photoId) => {
      const p = (window.PHOTO_BY_ID || {})[photoId] || (store.photos || []).find((x) => x.id === photoId);
      if (!p?.url) { showToast('Impossible d\'ouvrir cette image.'); return; }
      window.open(p.url, '_blank', 'noopener,noreferrer');
    },
    moderatePhotoAction: async (photoId, action, note, banReason) => {
      if (!store.photosBusy) store.photosBusy = new Set();
      store.photosBusy.add(photoId);
      renderPhotosGallery();
      try {
        await MBApi.moderatePhoto(photoId, action, note, banReason);
        closeModal();
        closePhotoPreview();
        store.photos = await MBApi.listPhotos(200, 0, store.photosSearch || '') || [];
        if (action === 'ban') {
          const users = await safeLoad('users', () => MBApi.searchUsers('', 200), []);
          store.users = users;
          USERS = (users || []).map(mapUser);
          renderTables();
        }
        renderPhotosGallery();
        showToast('Action de modération appliquée.');
      } catch (e) {
        showToast(e.message || 'Impossible d\'appliquer cette action.');
      } finally {
        store.photosBusy.delete(photoId);
        renderPhotosGallery();
      }
    },
    reloadAudit,
    confirmBan: async (userId, reason) => {
      const btn = document.getElementById('ban-confirm-btn');
      if (btn) { btn.disabled = true; btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Bannissement…'; }
      try {
        await MBApi.banUser(userId, reason.trim());
        closeModal();
        await loadAll();
        updateChatBanButton();
        showToast('Utilisateur banni');
      } catch (e) {
        showToast(e.message || 'Erreur bannissement');
        if (btn) { btn.disabled = false; btn.innerHTML = '<i class="fa-solid fa-ban"></i> Confirmer le bannissement'; }
      }
    },
    confirmUnban: async (userId) => {
      try {
        await MBApi.unbanUser(userId);
        closeModal();
        await loadAll();
        updateChatBanButton();
        showToast('Bannissement levé');
      } catch (e) { showToast(e.message || 'Erreur débannissement'); }
    },
    toggleBan: async (userId, isActive) => {
      if (isActive) openBanModal(userId);
      else openUnbanModal(userId);
    },
    setRole: async (userId, role) => {
      try {
        await MBApi.setUserRole(userId, role);
        closeModal();
        await loadAll();
        showToast(`Rôle ${role} ajouté`);
      } catch (e) { showToast(e.message); }
    },
    removeRole: async (userId, role) => {
      try {
        await MBApi.removeUserRole(userId, role);
        closeModal();
        await loadAll();
        showToast(`Rôle ${role} retiré`);
      } catch (e) { showToast(e.message); }
    },
    resolveBug: async (id) => {
      try {
        await MBApi.updateBugReport(id, 'resolved', 'Traité depuis le back-office web');
        await loadAll();
        showToast('Bug marqué comme résolu');
      } catch (e) { showToast(e.message); }
    },
    searchSubscriptions: async () => {
      const q = document.getElementById('subs-search')?.value?.trim() || '';
      const status = document.getElementById('subs-filter-status')?.value || 'all';
      const tbody = document.getElementById('subs-tbody');
      if (tbody) {
        tbody.innerHTML = emptyRow(12, '<i class="fa-solid fa-spinner fa-spin"></i> Chargement…');
      }
      try {
        const rows = await MBApi.searchPrestataireSubscriptions(q, status, 500, 0);
        store.prestataireSubscriptions = rows || [];
        renderPrestataireSubscriptions();
      } catch (e) {
        store.prestataireSubscriptions = [];
        if (tbody) {
          tbody.innerHTML = emptyRow(12, escapeHtml(e.message || 'Erreur chargement abonnements'));
        }
        showToast(e.message || 'Erreur recherche abonnements');
      }
    },
  };

  const titles = {
    verifications: 'Vérifications', 'content-reports': 'Signalements contenu', photos: 'Photos réalisations',
    audit: 'Journal audit', push: 'Notifications push', trial: 'Essai catalogue', 'platform-fee': 'Commission RDV',
  };
  const origShow = window.showSection;
  window.showSection = (id, el) => {
    origShow(id, el);
    if (titles[id]) document.getElementById('topbar-title').textContent = titles[id];
    if (id === 'pays-users') setTimeout(renderPaysUsers, 0);
    if (id === 'pays-revenue') setTimeout(renderPaysRevenue, 0);
    if (id === 'forfaits') setTimeout(() => MBLive.searchSubscriptions(), 0);
    if (id === 'photos') setTimeout(renderPhotosGallery, 0);
    if (id === 'audit') setTimeout(renderAuditTable, 0);
    if (id === 'push') setTimeout(() => { onPushAudienceChange(); }, 0);
  };

  document.addEventListener('DOMContentLoaded', async () => {
    document.getElementById('login-pwd')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') doLogin();
    });
    document.getElementById('chat-input')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendAdminMessage();
      }
    });
    document.addEventListener('click', (e) => {
      if (!notifOpen) return;
      const panel = document.getElementById('notif-panel');
      const btn = document.getElementById('notif-btn');
      if (panel && !panel.contains(e.target) && btn && !btn.contains(e.target)) {
        notifOpen = false;
        panel.style.display = 'none';
      }
    });
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.photo-tile-menu-wrap') && typeof closePhotoMenus === 'function') closePhotoMenus();
    });
    try { if (await MBApi.initSession()) await enter(); } catch (e) {
      const err = document.getElementById('login-error');
      if (err) { err.textContent = e.message; err.style.display = 'block'; }
    }
  });
})();
