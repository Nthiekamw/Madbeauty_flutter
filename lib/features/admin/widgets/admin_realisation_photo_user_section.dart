import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../logic/admin_realisation_photos_grouping.dart';
import 'admin_discovery_widgets.dart';

typedef AdminRealisationPhotoActionCallback = void Function(
  AdminRealisationPhotoSummary photo,
  AdminRealisationPhotoMenuAction action,
);

enum AdminRealisationPhotoMenuAction {
  preview,
  download,
  delete,
  flagObscene,
  warn,
  ban,
}

class AdminRealisationPhotoUserSection extends StatelessWidget {
  const AdminRealisationPhotoUserSection({
    super.key,
    required this.group,
    required this.dateFormat,
    required this.busyIds,
    required this.onAction,
  });

  final AdminRealisationPhotoUserGroup group;
  final DateFormat dateFormat;
  final Set<String> busyIds;
  final AdminRealisationPhotoActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = DiscoveryResponsive.of(context);
    final columns = responsive.isWide ? 5 : (responsive.isTablet ? 4 : 3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AdminDiscoveryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.adminBg12,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.adminBorder30),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.adminAccentMid,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (group.ownerEmail != null &&
                          group.ownerEmail!.trim().isNotEmpty)
                        Text(
                          group.ownerEmail!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        DiscProfile.adminRealisationPhotosUserMediaCount(
                          group.photoCount,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.adminAccentMid,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final tileSize =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final photo in group.photos)
                      SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: _AdminRealisationPhotoTile(
                          photo: photo,
                          dateFormat: dateFormat,
                          busy: busyIds.contains(photo.id),
                          onAction: onAction,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminRealisationPhotoTile extends StatelessWidget {
  const _AdminRealisationPhotoTile({
    required this.photo,
    required this.dateFormat,
    required this.busy,
    required this.onAction,
  });

  final AdminRealisationPhotoSummary photo;
  final DateFormat dateFormat;
  final bool busy;
  final AdminRealisationPhotoActionCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: busy
            ? null
            : () => onAction(photo, AdminRealisationPhotoMenuAction.preview),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RealisationMediaCover(
                  mediaType: photo.isVideo
                      ? RealisationMediaType.video
                      : RealisationMediaType.image,
                  imageUrl: photo.url,
                  playVideoPreview: photo.isVideo,
                  showPlayBadge: photo.isVideo,
                  playIconSize: 22,
                ),
                if (busy)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _ModerationMenu(
                    busy: busy,
                    onSelected: (action) => onAction(photo, action),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
                      child: Text(
                        dateFormat.format(photo.createdAt.toLocal()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModerationMenu extends StatelessWidget {
  const _ModerationMenu({
    required this.busy,
    required this.onSelected,
  });

  final bool busy;
  final ValueChanged<AdminRealisationPhotoMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.black.withValues(alpha: 0.52),
      borderRadius: BorderRadius.circular(999),
      child: PopupMenuButton<AdminRealisationPhotoMenuAction>(
        enabled: !busy,
        icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        onSelected: onSelected,
        itemBuilder: (context) => [
          _item(
            AdminRealisationPhotoMenuAction.download,
            Icons.download_outlined,
            DiscProfile.adminRealisationPhotosDownload,
          ),
          _item(
            AdminRealisationPhotoMenuAction.delete,
            Icons.delete_outline,
            DiscProfile.adminRealisationPhotosDelete,
            color: theme.colorScheme.error,
          ),
          _item(
            AdminRealisationPhotoMenuAction.flagObscene,
            Icons.report_outlined,
            DiscProfile.adminRealisationPhotosFlagObscene,
            color: AppColors.errorLight,
          ),
          _item(
            AdminRealisationPhotoMenuAction.warn,
            Icons.warning_amber_outlined,
            DiscProfile.adminRealisationPhotosWarn,
          ),
          _item(
            AdminRealisationPhotoMenuAction.ban,
            Icons.block,
            DiscProfile.adminRealisationPhotosBan,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<AdminRealisationPhotoMenuAction> _item(
    AdminRealisationPhotoMenuAction value,
    IconData icon,
    String label, {
    Color? color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
