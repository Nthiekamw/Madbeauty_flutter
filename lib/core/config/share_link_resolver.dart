import '../models/domain/user/prestataire_public_slug.dart';
import 'app_config.dart';
import 'share_link_config.dart';

/// Résout le lien partagé (préférer le handle court `/@slug`).
abstract final class ShareLinkResolver {
  ShareLinkResolver._();

  /// Lien préféré : `https://madbeauty.pro/@vichy` si [publicSlug] connu,
  /// sinon fallback UUID `/prestataire/:id`.
  static String prestataireProfileUrl(
    String prestataireId, {
    String? publicSlug,
  }) {
    final slug = PrestatairePublicSlug.normalize(publicSlug);
    final explicit = ShareLinkConfig.httpsBaseUrl.trim().toLowerCase();

    if (explicit == 'custom') {
      if (slug != null) return ShareLinkConfig.prestataireHandleCustomUrl(slug);
      return ShareLinkConfig.prestataireProfileCustomUrl(prestataireId);
    }

    if (ShareLinkConfig.useHttpsShare) {
      if (slug != null) return ShareLinkConfig.prestataireHandleHttpsUrl(slug);
      return ShareLinkConfig.prestataireProfileHttpsUrl(prestataireId);
    }

    if (AppConfig.hasSupabase) {
      return ShareLinkConfig.supabaseFunctionShareUrl(prestataireId);
    }

    if (slug != null) return ShareLinkConfig.prestataireHandleCustomUrl(slug);
    return ShareLinkConfig.prestataireProfileCustomUrl(prestataireId);
  }

  static bool get usesPublicHttps =>
      ShareLinkConfig.useHttpsShare ||
      (ShareLinkConfig.httpsBaseUrl.trim().isEmpty && AppConfig.hasSupabase);

  static String inviteUrl(String referralCode) =>
      ShareLinkConfig.inviteCustomUrl(referralCode);

  static String reelUrl(String reelId) {
    final explicit = ShareLinkConfig.httpsBaseUrl.trim().toLowerCase();
    if (explicit == 'custom') {
      return ShareLinkConfig.reelCustomUrl(reelId);
    }
    if (ShareLinkConfig.useHttpsShare) {
      return ShareLinkConfig.reelHttpsUrl(reelId);
    }
    if (AppConfig.hasSupabase) {
      return ShareLinkConfig.supabaseReelShareUrl(reelId);
    }
    return ShareLinkConfig.reelCustomUrl(reelId);
  }
}
