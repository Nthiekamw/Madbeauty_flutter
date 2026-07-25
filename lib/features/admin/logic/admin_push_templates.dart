import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/admin/admin_push_service.dart';

/// Modèle de diffusion admin (aligné web-admin).
class AdminPushTemplate {
  const AdminPushTemplate({
    required this.id,
    required this.label,
    required this.icon,
    required this.audience,
    required this.nav,
    required this.title,
    required this.body,
  });

  final String id;
  final String label;
  final IconData icon;
  final AdminPushAudience audience;
  final AdminPushNavTarget nav;
  final String title;
  final String body;
}

/// Templates prêts à l’emploi — mêmes textes que l’admin web.
abstract final class AdminPushTemplates {
  AdminPushTemplates._();

  static const List<AdminPushTemplate> all = [
    AdminPushTemplate(
      id: 'incomplete_profile',
      label: DiscProfile.adminPushTemplateIncompleteProfile,
      icon: Icons.manage_accounts_outlined,
      audience: AdminPushAudience.prestataireIncomplete,
      nav: AdminPushNavTarget.prestataireProfileEdit,
      title: DiscProfile.adminPushTplIncompleteTitle,
      body: DiscProfile.adminPushTplIncompleteBody,
    ),
    AdminPushTemplate(
      id: 'app_update',
      label: DiscProfile.adminPushTemplateAppUpdate,
      icon: Icons.rocket_launch_outlined,
      audience: AdminPushAudience.all,
      nav: AdminPushNavTarget.none,
      title: DiscProfile.adminPushTplAppUpdateTitle,
      body: DiscProfile.adminPushTplAppUpdateBody,
    ),
    AdminPushTemplate(
      id: 'subscription',
      label: DiscProfile.adminPushTemplateSubscription,
      icon: Icons.workspace_premium_outlined,
      audience: AdminPushAudience.prestataire,
      nav: AdminPushNavTarget.prestataireSubscription,
      title: DiscProfile.adminPushTplSubscriptionTitle,
      body: DiscProfile.adminPushTplSubscriptionBody,
    ),
    AdminPushTemplate(
      id: 'catalog_hidden',
      label: DiscProfile.adminPushTemplateCatalogHidden,
      icon: Icons.visibility_off_outlined,
      audience: AdminPushAudience.prestataire,
      nav: AdminPushNavTarget.prestataireSubscription,
      title: DiscProfile.adminPushTplCatalogHiddenTitle,
      body: DiscProfile.adminPushTplCatalogHiddenBody,
    ),
    AdminPushTemplate(
      id: 'clients_welcome',
      label: DiscProfile.adminPushTemplateClientsWelcome,
      icon: Icons.favorite_outline,
      audience: AdminPushAudience.client,
      nav: AdminPushNavTarget.clientSearch,
      title: DiscProfile.adminPushTplClientsWelcomeTitle,
      body: DiscProfile.adminPushTplClientsWelcomeBody,
    ),
    AdminPushTemplate(
      id: 'custom',
      label: DiscProfile.adminPushTemplateCustom,
      icon: Icons.edit_outlined,
      audience: AdminPushAudience.all,
      nav: AdminPushNavTarget.none,
      title: '',
      body: '',
    ),
  ];
}
