import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../services/supabase/reel/reel_service.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../../prestataire/providers/profile/prestataire_profile_form_provider.dart';
import '../../prestataire/widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../providers/reel_feed_provider.dart';

/// Gestion des Reels côté prestataire (Profil).
class PrestataireReelManageScreen extends ConsumerStatefulWidget {
  const PrestataireReelManageScreen({super.key});

  @override
  ConsumerState<PrestataireReelManageScreen> createState() =>
      _PrestataireReelManageScreenState();
}

class _PrestataireReelManageScreenState
    extends ConsumerState<PrestataireReelManageScreen> {
  bool _publishing = false;

  Future<void> _publish(String prestataireId) async {
    final choice = await showModalBottomSheet<_PublishKind>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(DiscReel.publishPickPhotos),
                onTap: () => Navigator.pop(ctx, _PublishKind.photos),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text(DiscReel.publishPickVideo),
                onTap: () => Navigator.pop(ctx, _PublishKind.video),
              ),
            ],
          ),
        );
      },
    );
    if (choice == null || !mounted) return;

    final picker = ImagePicker();
    final List<XFile> picked;
    if (choice == _PublishKind.photos) {
      picked = await picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 85,
        limit: ReelService.maxMediaPerPost,
      );
    } else {
      final video = await picker.pickVideo(source: ImageSource.gallery);
      picked = video == null ? const [] : [video];
    }
    if (picked.isEmpty || !mounted) return;

    final limited = picked.take(ReelService.maxMediaPerPost).toList();
    final captionCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscReel.publishTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              choice == _PublishKind.photos
                  ? DiscReel.publishPhotosCount(limited.length)
                  : limited.first.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionCtrl,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: DiscReel.publishCaptionLabel,
                hintText: DiscReel.publishCaptionHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DiscReel.publishSubmit),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) {
      captionCtrl.dispose();
      return;
    }

    setState(() => _publishing = true);
    try {
      final uploads = <StorageUploadFile>[];
      for (final file in limited) {
        uploads.add(await StorageUploadFile.fromXFile(file));
      }
      await ref.read(reelServiceProvider).publish(
            prestataireId: prestataireId,
            files: uploads,
            caption: captionCtrl.text,
          );
      captionCtrl.dispose();
      ref.invalidate(prestataireReelPostsProvider(prestataireId));
      if (!mounted) return;
      AppSnackBar.success(context, DiscReel.publishSuccess);
    } catch (e) {
      captionCtrl.dispose();
      if (!mounted) return;
      final msg = e is AppFailure ? e.message : DiscReel.publishError;
      AppSnackBar.error(context, msg);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _delete(String prestataireId, ReelPostOwned post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscReel.deleteConfirmTitle),
        content: const Text(DiscReel.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(DiscReel.deleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(reelServiceProvider).deletePost(post.id);
      ref.invalidate(prestataireReelPostsProvider(prestataireId));
      if (!mounted) return;
      AppSnackBar.success(context, DiscReel.deleteSuccess);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, DiscReel.deleteError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final padding = PrestataireProfileInsets.page(context);

    return Scaffold(
      appBar: AppBar(title: const Text(DiscReel.manageTitle)),
      floatingActionButton: profileAsync.maybeWhen(
        data: (data) {
          final id = data.prestataireId;
          if (id == null || id.isEmpty) return null;
          return FloatingActionButton.extended(
            onPressed: _publishing ? null : () => _publish(id),
            icon: _publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: const Text(DiscReel.publishCta),
          );
        },
        orElse: () => null,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.error_outline,
          title: DiscReel.manageLoadError,
          body: DiscReel.retry,
          actionLabel: DiscReel.retry,
          onAction: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        data: (data) {
          final id = data.prestataireId;
          if (id == null || id.isEmpty) {
            return DiscoveryEmptyState(
              icon: Icons.lock_outline,
              title: DiscReel.publishNotEligibleTitle,
              body: DiscReel.publishNotEligibleBody,
            );
          }
          final postsAsync = ref.watch(prestataireReelPostsProvider(id));
          return postsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => DiscoveryEmptyState(
              icon: Icons.wifi_off_rounded,
              title: DiscReel.manageLoadError,
              body: DiscReel.retry,
              actionLabel: DiscReel.retry,
              onAction: () =>
                  ref.invalidate(prestataireReelPostsProvider(id)),
            ),
            data: (posts) {
              if (posts.isEmpty) {
                return DiscoveryEmptyState(
                  icon: Icons.movie_filter_outlined,
                  title: DiscReel.manageEmptyTitle,
                  body: DiscReel.manageEmptyBody,
                  actionLabel: DiscReel.publishCta,
                  onAction: _publishing ? null : () => _publish(id),
                );
              }
              final maxW = DiscoveryResponsive.of(context).contentMaxWidth;
              return ListView.separated(
                padding: padding.copyWith(bottom: 96),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: DiscoverySurfaceCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 3 / 4,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  RealisationMediaCover(
                                    mediaType: post.mediaType,
                                    imageUrl: post.mediaUrl,
                                    playVideoPreview: post.mediaType ==
                                        RealisationMediaType.video,
                                    showPlayBadge: post.mediaType ==
                                        RealisationMediaType.video,
                                  ),
                                  if (post.hasMultipleMedia)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.scrimDark54,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.collections_outlined,
                                                size: 14,
                                                color: AppColors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${post.media.length}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Text(
                                post.caption?.isNotEmpty == true
                                    ? post.caption!
                                    : DiscReel.statusPublished,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${DiscReel.likesCount(post.likesCount)} · '
                                '${DiscReel.commentsCount(post.commentsCount)} · '
                                '${DiscReel.viewsCount(post.viewsCount)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(id, post),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

enum _PublishKind { photos, video }
