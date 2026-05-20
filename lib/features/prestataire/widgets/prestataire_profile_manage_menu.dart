import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../models/prestataire_profile_edit_section.dart';

/// Raccourcis pour modifier chaque bloc du profil prestataire.
class PrestataireProfileManageMenu extends StatelessWidget {
  const PrestataireProfileManageMenu({
    super.key,
    this.showHeader = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final bool showHeader;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = PrestataireProfileEditSection.values;

    return Padding(
      padding: padding,
      child: DiscoverySurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPrestaProfile.sectionPro,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DiscPrestaProfile.sectionProHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0 || showHeader)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              DiscoveryMenuTile(
                icon: sections[i].icon,
                title: sections[i].menuTitle,
                subtitle: sections[i].menuSubtitle,
                onTap: () => context.pushPrestataireProfileEditSection(
                  sections[i],
                ),
              ),
            ],
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
            DiscoveryMenuTile(
              icon: Icons.schedule_rounded,
              title: DiscPrestaProfile.horaires,
              subtitle: DiscPrestaProfile.menuHorairesHint,
              onTap: () => context.pushPrestataireHoraires(),
            ),
          ],
        ),
      ),
    );
  }
}
