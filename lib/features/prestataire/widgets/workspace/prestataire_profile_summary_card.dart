import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../profile/overview/prestataire_profile_insets.dart';

/// Carte résumé salon (profil prestataire).
class PrestataireProfileSummaryCard extends StatelessWidget {
  const PrestataireProfileSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.onTap,
    this.trailingBadge,
  });

  final String title;
  final String subtitle;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final Widget? trailingBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(top: 12),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: AppAvatar(
                    imageUrl: avatarUrl,
                    displayName: title,
                    radius: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (trailingBadge != null) ...[
                            const SizedBox(width: 8),
                            trailingBadge!,
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DiscPrestaProfile.editProfileHint,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget prestataireFreePlanBadge(BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: theme.colorScheme.secondary.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      DiscPrestaWorkspace.profileSummaryFree,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.secondary,
      ),
    ),
  );
}
