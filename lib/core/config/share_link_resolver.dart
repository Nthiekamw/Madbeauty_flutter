import 'app_config.dart';
import 'share_link_config.dart';

/// Résout le lien partagé (équivalent futur `https://app.com/prestataire/:id`).
abstract final class ShareLinkResolver {
  ShareLinkResolver._();

  /// `SHARE_BASE_URL=custom` → schéma app uniquement.
  /// `SHARE_BASE_URL` HTTPS → `{base}/prestataire/:id` (futur site).
  /// Vide + Supabase → Edge Function (sans site web).
  static String prestataireProfileUrl(String prestataireId) {
    final explicit = ShareLinkConfig.httpsBaseUrl.trim().toLowerCase();
    if (explicit == 'custom') {
      return ShareLinkConfig.prestataireProfileCustomUrl(prestataireId);
    }
    if (ShareLinkConfig.useHttpsShare) {
      return ShareLinkConfig.prestataireProfileHttpsUrl(prestataireId);
    }
    if (AppConfig.hasSupabase) {
      return ShareLinkConfig.supabaseFunctionShareUrl(prestataireId);
    }
    return ShareLinkConfig.prestataireProfileCustomUrl(prestataireId);
  }

  static bool get usesPublicHttps =>
      ShareLinkConfig.useHttpsShare ||
      (ShareLinkConfig.httpsBaseUrl.trim().isEmpty && AppConfig.hasSupabase);

  static String inviteUrl(String referralCode) =>
      ShareLinkConfig.inviteCustomUrl(referralCode);
}
