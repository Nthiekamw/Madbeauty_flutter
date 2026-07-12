import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/market_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/logic/market/invalidate_market_catalog.dart';
import '../../../../core/providers/app_appearance_provider.dart';
import '../../../../core/providers/market_country_provider.dart';
import '../../../../services/supabase/profile/client_profile_providers.dart';
import '../../../../shared/utils/phone_number_utils.dart';
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
    final marketCountry = ref.watch(marketCountryProvider);
    final profileCountry = ref.watch(currentClientProfileProvider).maybeWhen(
          data: (profile) => profile?.pays?.trim(),
          orElse: () => null,
        );
    final marketLockedByProfile =
        profileCountry != null && profileCountry.isNotEmpty;
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
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              textStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: _AppearanceSegmentLabel(
                  text: DiscAppearance.themeSystem(locale),
                ),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: _AppearanceSegmentLabel(
                  text: DiscAppearance.themeLight(locale),
                ),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: _AppearanceSegmentLabel(
                  text: DiscAppearance.themeDark(locale),
                ),
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
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              textStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            segments: [
              ButtonSegment(
                value: AppLanguage.french,
                label: _AppearanceSegmentLabel(
                  text: DiscAppearance.languageFrench(locale),
                ),
              ),
              ButtonSegment(
                value: AppLanguage.english,
                label: _AppearanceSegmentLabel(
                  text: DiscAppearance.languageEnglish(locale),
                ),
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
          const SizedBox(height: 22),
          Text(
            DiscAppearance.marketSection(locale),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...MarketConfig.supportedMarkets.map((market) {
            final selected = market.isoCode == marketCountry;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                enabled: !marketLockedByProfile,
                leading: Text(
                  PhoneNumberUtils.countryFlag(market.isoCode),
                  style: TextStyle(
                    fontSize: 22,
                    color: marketLockedByProfile && !selected
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : null,
                  ),
                ),
                title: Text(
                  market.labelFor(locale),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: marketLockedByProfile && !selected
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : null,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : Icon(
                        Icons.circle_outlined,
                        color: theme.colorScheme.outline,
                      ),
                onTap: selected || marketLockedByProfile
                    ? null
                    : () async {
                        await ref
                            .read(marketCountryProvider.notifier)
                            .setMarketCountry(market.isoCode);
                        invalidateMarketCatalog(ref);
                        if (!context.mounted) return;
                        AppSnackBar.show(
                          context,
                          message: DiscAppearance.marketSaved(locale),
                        );
                      },
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(
            marketLockedByProfile
                ? DiscAppearance.marketLockedByAddress(locale)
                : DiscAppearance.marketNote(locale),
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

/// Libellé segment : une seule ligne, réduit si l’espace est étroit.
class _AppearanceSegmentLabel extends StatelessWidget {
  const _AppearanceSegmentLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
      ),
    );
  }
}
