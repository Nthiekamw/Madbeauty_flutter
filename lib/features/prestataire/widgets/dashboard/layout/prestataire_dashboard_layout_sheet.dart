import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../models/prestataire_dashboard_layout.dart';
import '../../../providers/dashboard/prestataire_dashboard_layout_provider.dart';
import '../../../providers/dashboard/prestataire_dashboard_provider.dart';
import '../../../providers/profile/prestataire_profile_form_provider.dart';
import 'prestataire_dashboard_layout_tile.dart';

Future<void> showPrestataireDashboardLayoutSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          final layout =
              ref.watch(prestataireDashboardLayoutProvider).asData?.value ??
                  PrestataireDashboardLayout.defaults;
          final dashboard = ref.watch(prestataireDashboardProvider).asData?.value;
          final dashboardLoaded = ref.watch(prestataireDashboardProvider).hasValue;
          final dashboardError =
              ref.watch(prestataireDashboardProvider).hasError &&
                  dashboard == null;
          final profileLoaded =
              ref.watch(prestataireProfileFormProvider).hasValue;

          final visible = visiblePrestataireDashboardSections(
            layout: layout,
            profileLoaded: profileLoaded,
            dashboardLoaded: dashboardLoaded && !dashboardError,
            dashboard: dashboard,
          );

          final layoutNotifier =
              ref.read(prestataireDashboardLayoutProvider.notifier);
          final maxHeight = MediaQuery.sizeOf(context).height * 0.55;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  child: Text(
                    DiscPrestaDash.layoutCustomizeTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    DiscPrestaDash.layoutCustomizeHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      DiscPrestaDash.layoutCustomizeEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      itemCount: visible.length,
                      onReorder: (oldIndex, newIndex) {
                        layoutNotifier.reorderVisible(
                          visible,
                          oldIndex: oldIndex,
                          newIndex: newIndex,
                        );
                      },
                      itemBuilder: (context, index) {
                        final sectionId = visible[index];
                        final meta = PrestataireDashboardLayoutTile.metaFor(
                          sectionId,
                          theme,
                        );
                        final accent = meta.$3 ?? theme.colorScheme.primary;

                        return Card(
                          key: ValueKey(sectionId),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(meta.$1, color: accent, size: 20),
                            ),
                            title: Text(
                              meta.$2,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text(DiscPrestaDash.layoutModalDone),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
