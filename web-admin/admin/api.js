/** API Supabase — parité avec lib/services/supabase/admin/ */
window.MBApi = (() => {
  let sb, user;
  const cfg = () => window.MADBEAUTY_ADMIN_CONFIG || {};

  function client() {
    if (sb) return sb;
    const { supabaseUrl, supabaseAnonKey } = cfg();
    if (!supabaseUrl || !supabaseAnonKey) throw new Error('Config Supabase manquante (admin/config.js).');
    sb = window.supabase.createClient(supabaseUrl, supabaseAnonKey, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
    });
    return sb;
  }

  async function rpc(name, params = {}) {
    const { data, error } = await client().rpc(name, params);
    if (error) throw error;
    return data;
  }

  async function isAdmin(uid) {
    const { data } = await client().from('user_roles').select('role').eq('user_id', uid);
    return (data || []).some((r) => r.role === 'admin');
  }

  async function fn(name, body) {
    const { data, error } = await client().functions.invoke(name, { body });
    if (error) {
      let message = error.message || 'Erreur serveur';
      if (error.context && typeof error.context.json === 'function') {
        try {
          const payload = await error.context.json();
          if (payload?.error) message = String(payload.error);
        } catch { /* ignore parse */ }
      }
      throw new Error(message);
    }
    if (data && typeof data === 'object') {
      if (data.error) throw new Error(String(data.error));
      if (data.ok === false) throw new Error(String(data.error || 'Opération refusée'));
    }
    return data;
  }

  return {
    getUser: () => user,
    async initSession() {
      const { data } = await client().auth.getSession();
      if (!data.session?.user || !(await isAdmin(data.session.user.id))) return null;
      user = data.session.user;
      return user;
    },
    async signIn(email, password) {
      const { data, error } = await client().auth.signInWithPassword({ email, password });
      if (error) throw error;
      if (!(await isAdmin(data.user.id))) { await client().auth.signOut(); throw new Error('Accès admin requis.'); }
      user = data.user;
      return user;
    },
    async signOut() { await client().auth.signOut(); user = null; },

    getAnalytics: () => rpc('admin_get_analytics_summary'),
    getCountries: () => rpc('admin_get_reservations_by_country'),
    getSubscriptionPlans: () => rpc('admin_get_subscription_plans_summary'),
    searchUsers: (q, limit = 200) => rpc('admin_search_users', { p_query: q, p_limit: limit }),
    getUserDetails: (userId) => rpc('admin_get_user_details', { p_user_id: userId }),
    listReservations: (limit = 100, filters = {}) =>
      rpc('admin_list_reservations', {
        p_limit: limit,
        p_statut: filters.statut || null,
        p_payment_status: filters.paymentStatus || null,
        p_from_date: filters.from || null,
        p_to_date: filters.to || null,
      }),
    listBoutiqueOrders: (limit = 200, filters = {}) =>
      rpc('admin_list_boutique_orders', {
        p_limit: limit,
        p_statut: filters.statut || null,
        p_payment_status: filters.paymentStatus || null,
        p_from_date: filters.from || null,
        p_to_date: filters.to || null,
        p_search: filters.search || null,
      }),
    listBoutiqueCatalog: (limit = 200, search = '') =>
      rpc('admin_list_boutique_catalog', {
        p_limit: limit,
        p_search: search || null,
      }),
    listBugReports: (onlyPending = false, limit = 50) =>
      rpc('admin_list_bug_reports', { p_only_pending: onlyPending, p_limit: limit }),
    listSupportThreads: (limit = 50) => rpc('admin_list_user_support_threads', { p_limit: limit }),
    listVerifications: (onlyPending = true) =>
      rpc('admin_list_prestataire_verification_requests', { p_only_pending: onlyPending }),
    approveVerification: (id, note) => rpc('approve_prestataire_verification', { p_prestataire_id: id, p_note: note }),
    revokeVerification: (id, note) => rpc('revoke_prestataire_verification', { p_prestataire_id: id, p_note: note }),
    listContentReports: (onlyPending = true, limit = 100) =>
      rpc('admin_list_content_reports', { p_only_pending: onlyPending, p_limit: limit }),
    moderateContentReport: (id, action, note) =>
      rpc('admin_moderate_content_report', { p_report_id: id, p_action: action, p_note: note }),
    listPhotos: (limit = 200, offset = 0, search = '') =>
      rpc('admin_list_realisation_photos', {
        p_limit: limit,
        p_offset: offset,
        p_search: search || null,
      }),
    moderatePhoto: (id, action, note, banReason) =>
      rpc('admin_moderate_realisation_photo', {
        p_photo_id: id,
        p_action: action,
        p_note: note || null,
        p_ban_reason: banReason || null,
      }),
    listAudit: (limit = 200) => rpc('admin_list_audit_log', { p_limit: limit }),
    listVerificationEvents: (limit = 200) => rpc('admin_list_verification_events', { p_limit: limit }),
    getTrialSettings: () => rpc('admin_get_catalog_trial_settings'),
    updateTrialDays: (days) => rpc('admin_update_catalog_trial_days', { p_days: days }),
    getPlatformFee: () => rpc('admin_get_booking_platform_fee_settings'),
    updatePlatformFee: (feeCents, freeCount) =>
      rpc('admin_update_booking_platform_fee', { p_fee_cents: feeCents, p_free_booking_count: freeCount }),
    banUser: (userId, reason) => rpc('admin_ban_user', { p_user_id: userId, p_reason: reason }),
    unbanUser: (userId) => rpc('admin_unban_user', { p_user_id: userId }),
    setUserRole: (userId, role) => rpc('admin_set_user_role', { p_user_id: userId, p_role: role }),
    removeUserRole: (userId, role) => rpc('admin_remove_user_role', { p_user_id: userId, p_role: role }),
    updateBugReport: (id, status, notes) =>
      rpc('admin_update_bug_report', { p_report_id: id, p_status: status, p_admin_notes: notes, p_reporter_message: null }),
    pushInvoke: (body) => fn('admin_send_push', body),

    listSupportMessages: async (threadId) => {
      const { data, error } = await client()
        .from('user_support_messages')
        .select('id, thread_id, sender_id, content, created_at, is_read')
        .eq('thread_id', threadId)
        .order('created_at', { ascending: true });
      if (error) throw error;
      return data || [];
    },
    sendSupportMessage: async (threadId, content) => {
      const uid = user?.id;
      if (!uid) throw new Error('Non connecté');
      const text = String(content || '').trim();
      if (!text) throw new Error('Message vide');
      const { error } = await client().from('user_support_messages').insert({
        thread_id: threadId,
        sender_id: uid,
        content: text,
      });
      if (error) throw error;
    },
    markSupportThreadRead: async (threadId) => {
      const uid = user?.id;
      if (!uid) return;
      const { error } = await client()
        .from('user_support_messages')
        .update({ is_read: true })
        .eq('thread_id', threadId)
        .neq('sender_id', uid)
        .eq('is_read', false);
      if (error) throw error;
    },
    searchPrestataireTrials: (q, limit = 200) =>
      rpc('admin_search_prestataire_trials', { p_query: q || '', p_limit: limit }),
    searchPrestataireSubscriptions: (q, status = 'all', limit = 200, offset = 0) =>
      rpc('admin_search_prestataire_subscriptions', {
        p_query: q || '',
        p_status: status || 'all',
        p_limit: limit,
        p_offset: offset,
      }),
  };
})();
