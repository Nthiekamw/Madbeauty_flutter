import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import 'client_home_reorderable_sections.dart';

/// Contenu scrollable partagé (connecté + invité).
class ClientHomeScrollContent extends ConsumerWidget {
  const ClientHomeScrollContent({
    super.key,
    this.footer,
  });

  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClientHomeReorderableSections(
      footer: footer,
    );
  }
}

/// Pied de page optionnel : indicateur cache profil.
Widget? clientHomeProfileCacheFooter(ThemeData theme, bool fromCache) {
  if (!fromCache) return null;
  return Text(
    ShellStrings.profileSourceCache,
    textAlign: TextAlign.center,
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.outline,
    ),
  );
}
