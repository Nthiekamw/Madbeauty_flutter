import '../../../services/storage/local_cache_service.dart';
import '../models/messaging_inbox_role.dart';

/// Rôle messagerie déduit du shell actif (client vs prestataire).
MessagingInboxRole? messagingViewerRoleFromActiveShell() {
  return switch (LocalCacheService.instance.selectedRole) {
    'client' => MessagingInboxRole.client,
    'prestataire' => MessagingInboxRole.prestataire,
    _ => null,
  };
}

/// Paramètre de route `?as=` pour ouvrir un fil dans le bon contexte.
String? messagingAsQueryParam({String? pushRole}) {
  final fromPayload = switch (pushRole) {
    'client' => 'client',
    'prestataire' => 'prestataire',
    _ => null,
  };
  if (fromPayload != null) return fromPayload;
  return messagingViewerRoleFromActiveShell()?.name;
}
