import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';
import '../../../services/supabase/admin/admin_realisation_photos_service.dart';
import '../../../shared/utils/app_url_launcher.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/prestataire/network_video_preview.dart';
import '../logic/admin_realisation_photos_grouping.dart';
import '../providers/admin_realisation_photos_provider.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_realisation_photo_user_section.dart';
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: InteractiveViewer(
            child: AspectRatio(
              aspectRatio: 1,
              child: photo.isVideo
                  ? NetworkVideoPreview(
                      url: photo.url,
                      autoPlay: true,
                      muted: false,
                      loop: false,
                      fit: BoxFit.contain,
                      showControls: true,
                      placeholderIconSize: 48,
                    )
                  : CachedNetworkImage(
                      imageUrl: photo.url,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePhotoAction(
    AdminRealisationPhotoSummary photo,
    AdminRealisationPhotoMenuAction action,
  ) async {
    switch (action) {
      case AdminRealisationPhotoMenuAction.preview:
        _preview(photo);
      case AdminRealisationPhotoMenuAction.download:
        await _download(photo);
      case AdminRealisationPhotoMenuAction.delete:
        await _confirmDelete(photo);
      case AdminRealisationPhotoMenuAction.flagObscene:
        await _confirmFlagObscene(photo);
      case AdminRealisationPhotoMenuAction.warn:
        await _warn(photo);
      case AdminRealisationPhotoMenuAction.ban:
        await _ban(photo);
    }
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
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
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

                final groups = groupAdminRealisationPhotosByUser(items);
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return AdminRealisationPhotoUserSection(
                        group: groups[index],
                        dateFormat: _dateFormat,
                        busyIds: _busyIds,
                        onAction: _handlePhotoAction,
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
