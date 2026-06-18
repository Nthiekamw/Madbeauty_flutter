import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';
import '../../../services/supabase/admin/admin_realisation_photos_service.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/app_url_launcher.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/admin_realisation_photos_provider.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminRealisationPhotosScreen extends ConsumerStatefulWidget {
  const AdminRealisationPhotosScreen({super.key});

  @override
  ConsumerState<AdminRealisationPhotosScreen> createState() =>
      _AdminRealisationPhotosScreenState();
}

class _AdminRealisationPhotosScreenState
    extends ConsumerState<AdminRealisationPhotosScreen> {
  final _searchController = TextEditingController();
  String? _search;
  final Set<String> _busyIds = <String>{};
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    setState(() => _search = _searchController.text.trim());
  }

  AdminRealisationPhotosQuery get _query =>
      (search: _search?.isEmpty == true ? null : _search, offset: 0);

  Future<void> _refresh() async {
    ref.invalidate(adminRealisationPhotosProvider(_query));
    await ref.read(adminRealisationPhotosProvider(_query).future);
  }

  Future<void> _moderate(
    AdminRealisationPhotoSummary photo,
    AdminRealisationPhotoAction action, {
    String? note,
    String? banReason,
  }) async {
    final service = ref.read(adminRealisationPhotosServiceProvider);
    if (service == null) return;

    setState(() => _busyIds.add(photo.id));
    try {
      await service.moderatePhoto(
        photoId: photo.id,
        action: action,
        note: note,
        banReason: banReason,
      );
      ref.invalidate(adminRealisationPhotosProvider(_query));
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminRealisationPhotosModerated,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminRealisationPhotosModerateErr,
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(photo.id));
    }
  }

  Future<void> _confirmDelete(AdminRealisationPhotoSummary photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscProfile.adminRealisationPhotosDeleteConfirmTitle),
        content: const Text(DiscProfile.adminRealisationPhotosDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DiscProfile.adminRealisationPhotosDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _moderate(photo, AdminRealisationPhotoAction.remove);
    }
  }

  Future<void> _confirmFlagObscene(AdminRealisationPhotoSummary photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscProfile.adminRealisationPhotosFlagConfirmTitle),
        content: const Text(DiscProfile.adminRealisationPhotosFlagConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DiscProfile.adminRealisationPhotosFlagObscene),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _moderate(photo, AdminRealisationPhotoAction.flagObscene);
    }
  }

  Future<void> _warn(AdminRealisationPhotoSummary photo) async {
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => _ModerationNoteDialog(
        title: DiscProfile.adminRealisationPhotosWarnDialogTitle,
        hint: DiscProfile.adminRealisationPhotosWarnHint,
        initialText: DiscProfile.adminRealisationPhotosWarnDefault,
        confirmLabel: DiscProfile.adminRealisationPhotosWarn,
      ),
    );
    if (note == null || note.trim().isEmpty) return;
    await _moderate(
      photo,
      AdminRealisationPhotoAction.warn,
      note: note.trim(),
    );
  }

  Future<void> _ban(AdminRealisationPhotoSummary photo) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _ModerationNoteDialog(
        title: DiscProfile.adminUsersBanDialogTitle(photo.prestataireLabel),
        hint: DiscProfile.adminUsersBanReasonHint,
        confirmLabel: DiscProfile.adminRealisationPhotosBan,
        required: true,
      ),
    );
    if (reason == null || reason.trim().isEmpty) return;
    await _moderate(
      photo,
      AdminRealisationPhotoAction.ban,
      banReason: reason.trim(),
    );
  }

  Future<void> _download(AdminRealisationPhotoSummary photo) async {
    final opened = await AppUrlLauncher.openInApp(context, photo.url);
    if (!opened && mounted) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminRealisationPhotosOpenErr,
        kind: AppSnackKind.error,
      );
    }
  }

  void _preview(AdminRealisationPhotoSummary photo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: AspectRatio(
            aspectRatio: 1,
            child: photo.isVideo
                ? Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      size: 64,
                      color: Theme.of(ctx).colorScheme.primary,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: photo.url,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photosAsync = ref.watch(adminRealisationPhotosProvider(_query));

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminRealisationPhotos,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.photo_library_outlined,
            title: DiscProfile.adminRealisationPhotosIntroTitle,
            body: DiscProfile.adminRealisationPhotosIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: DiscProfile.adminRealisationPhotosSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submitSearch,
                  child: const Text(DiscProfile.adminUsersSearchAction),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: photosAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const AdminListEmptyState(
                    icon: Icons.photo_library_outlined,
                    title: DiscProfile.adminRealisationPhotosEmpty,
                    body: DiscProfile.adminRealisationPhotosIntroBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final responsive = DiscoveryResponsive.of(context);
                      final columns = responsive.isWide
                          ? 4
                          : (responsive.isTablet ? 3 : 2);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final photo = items[index];
                          return _PhotoModerationCard(
                            photo: photo,
                            dateFormat: _dateFormat,
                            busy: _busyIds.contains(photo.id),
                            onPreview: () => _preview(photo),
                            onDownload: () => _download(photo),
                            onDelete: () => _confirmDelete(photo),
                            onFlag: () => _confirmFlagObscene(photo),
                            onWarn: () => _warn(photo),
                            onBan: () => _ban(photo),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const DiscoveryListSkeleton(rowCount: 6),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: _refresh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoModerationCard extends StatelessWidget {
  const _PhotoModerationCard({
    required this.photo,
    required this.dateFormat,
    required this.busy,
    required this.onPreview,
    required this.onDownload,
    required this.onDelete,
    required this.onFlag,
    required this.onWarn,
    required this.onBan,
  });

  final AdminRealisationPhotoSummary photo;
  final DateFormat dateFormat;
  final bool busy;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onFlag;
  final VoidCallback onWarn;
  final VoidCallback onBan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminDiscoveryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onPreview,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (photo.isVideo)
                      ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.videocam_outlined,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: photo.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                          color: Color(0x11000000),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: theme.colorScheme.errorContainer,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    if (photo.isVideo)
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.play_circle_outline, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            photo.prestataireLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            dateFormat.format(photo.createdAt.toLocal()),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _MiniAction(
                  icon: Icons.download_outlined,
                  label: DiscProfile.adminRealisationPhotosDownload,
                  onTap: onDownload,
                ),
                _MiniAction(
                  icon: Icons.delete_outline,
                  label: DiscProfile.adminRealisationPhotosDelete,
                  onTap: onDelete,
                  color: theme.colorScheme.error,
                ),
                _MiniAction(
                  icon: Icons.report_outlined,
                  label: DiscProfile.adminRealisationPhotosFlagObscene,
                  onTap: onFlag,
                  color: AppColors.errorLight,
                ),
                _MiniAction(
                  icon: Icons.warning_amber_outlined,
                  label: DiscProfile.adminRealisationPhotosWarn,
                  onTap: onWarn,
                ),
                _MiniAction(
                  icon: Icons.block,
                  label: DiscProfile.adminRealisationPhotosBan,
                  onTap: onBan,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _ModerationNoteDialog extends StatefulWidget {
  const _ModerationNoteDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    this.initialText = '',
    this.required = false,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String initialText;
  final bool required;

  @override
  State<_ModerationNoteDialog> createState() => _ModerationNoteDialogState();
}

class _ModerationNoteDialogState extends State<_ModerationNoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.hint,
          ),
          validator: widget.required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return DiscProfile.adminUsersBanReasonRequired;
                  }
                  return null;
                }
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(DiscProfile.adminUsersBanCancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.pop(context, _controller.text.trim());
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
