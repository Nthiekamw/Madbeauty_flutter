import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_appearance_provider.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';

Future<void> showAppearanceSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _AppearanceSettingsSheet(),
  );
}

class _AppearanceSettingsSheet extends ConsumerWidget {
  const _AppearanceSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);
    final locale = appearance.locale;
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscAppearance.sheetTitle(locale),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DiscAppearance.themeSection(locale),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(DiscAppearance.themeSystem(locale)),
                icon: const Icon(Icons.brightness_auto_rounded, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(DiscAppearance.themeLight(locale)),
                icon: const Icon(Icons.light_mode_rounded, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(DiscAppearance.themeDark(locale)),
                icon: const Icon(Icons.dark_mode_rounded, size: 18),
              ),
            ],
            selected: {appearance.themeMode},
            onSelectionChanged: (selected) async {
              await ref
                  .read(appAppearanceProvider.notifier)
                  .setThemeMode(selected.first);
              if (!context.mounted) return;
              AppSnackBar.show(
                context,
                message: DiscAppearance.themeSaved(locale),
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            DiscAppearance.languageSection(locale),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<AppLanguage>(
            segments: [
              ButtonSegment(
                value: AppLanguage.french,
                label: Text(DiscAppearance.languageFrench(locale)),
              ),
              ButtonSegment(
                value: AppLanguage.english,
                label: Text(DiscAppearance.languageEnglish(locale)),
              ),
            ],
            selected: {appearance.language},
            onSelectionChanged: (selected) async {
              await ref
                  .read(appAppearanceProvider.notifier)
                  .setLanguage(selected.first);
              if (!context.mounted) return;
              final nextLocale = ref.read(appAppearanceProvider).locale;
              AppSnackBar.show(
                context,
                message: DiscAppearance.languageSaved(nextLocale),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            DiscAppearance.languageNote(locale),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
