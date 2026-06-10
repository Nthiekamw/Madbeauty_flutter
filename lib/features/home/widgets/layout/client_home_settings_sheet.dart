import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_fonts.dart';
import 'client_home_layout_sheet.dart';

/// Menu paramètres accueil (actions rapides).
Future<void> showClientHomeSettingsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                DiscHome.settingsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: Text(DiscHome.layoutOrganizeAction),
              subtitle: Text(
                DiscHome.layoutCustomizeHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showClientHomeLayoutSheet(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: Text(DiscHome.settingsOpenCatalog),
              subtitle: Text(
                DiscHome.settingsOpenCatalogHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.goClientSearch();
              },
            ),
          ],
        ),
      );
    },
  );
}
