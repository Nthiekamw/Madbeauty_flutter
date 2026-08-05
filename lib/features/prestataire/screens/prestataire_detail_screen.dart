import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../booking/providers/is_own_prestataire_profile_provider.dart';
import '../../messaging/messaging_navigation.dart';
import '../../messaging/models/client_presta_chat_access.dart';
import '../../messaging/providers/client_presta_chat_access_provider.dart';
import '../../trust/widgets/report_content_sheet.dart';
import '../../../services/supabase/likes/prestataire_like_providers.dart';
import '../../../services/supabase/trust/content_report_service.dart';
import '../logic/prestataire_share.dart';
import '../providers/boutique/boutique_providers.dart';
import '../providers/catalog/prestataire_detail_provider.dart';
import '../widgets/profile/overview/sections/prestataire_client_experience_section.dart';
import '../widgets/public/detail/prestataire_client_engagement_row.dart';
import '../logic/prestataire_services_grouping.dart';
import '../widgets/public/detail/prestataire_detail_sections.dart';
import '../widgets/public/detail/prestataire_detail_shell.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../widgets/public/prestataire_detail_messaging_section.dart';
import '../widgets/public/prestataire_public_horaires_section.dart';
import '../../reviews/models/client_review_list_item.dart';
import '../../reviews/widgets/edit_review_sheet.dart';
import '../widgets/public/prestataire_public_reviews_live_section.dart';
import '../../../shared/layout/web_flow_page_frame.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';

class PrestataireDetailScreen extends ConsumerStatefulWidget {
  const PrestataireDetailScreen({super.key, required this.prestataireId});

  final String prestataireId;

  @override
  ConsumerState<PrestataireDetailScreen> createState() =>
      _PrestataireDetailScreenState();
}

class _PrestataireDetailScreenState
    extends ConsumerState<PrestataireDetailScreen> {
  final _scrollController = ScrollController();
  final _sectionBodyKey = GlobalKey();
  PrestataireDetailSection _selectedSection =
      PrestataireDetailSection.services;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectSection(PrestataireDetailSection section) {
    if (_selectedSection == section) {
      _ensureSectionBodyVisible();
      return;
    }
    setState(() => _selectedSection = section);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureSectionBodyVisible();
    });
  }

  void _ensureSectionBodyVisible() {
    final ctx = _sectionBodyKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  Widget _publicProfileBackLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => context.popOrGoHome(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prestataireDetailProvider(widget.prestataireId));
    final isOwnAsync = ref.watch(
      isOwnPrestataireProfileProvider(widget.prestataireId),
    );
    final isOwnProfile = isOwnAsync.maybeWhen(data: (v) => v, orElse: () => false);
    final theme = Theme.of(context);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.goHome();
      },
      child: PrestataireBrandScaffold(
        body: async.when(
        data: (data) {
          if (data == null) {
            return PrestataireBrandScaffold(
              appBar: prestataireBrandAppBar(
                context: context,
                title: const Text(DiscPrestaDetail.screenTitle),
                leading: _publicProfileBackLeading(context),
                automaticallyImplyLeading: false,
              ),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    DiscPrestaDetail.missing,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          final displayTitle = _profileDisplayTitle(data.profile);
          final minPrice = data.services.isEmpty
              ? null
              : data.services
                  .map((s) => s.prix)
                  .reduce((a, b) => a < b ? a : b);

          final produitsAsync =
              ref.watch(publicProduitsBoutiqueProvider(data.profile.id));
          final packsAsync =
              ref.watch(publicPacksOffreDetailProvider(data.profile.id));
          final hasBoutique = produitsAsync.maybeWhen(
            data: (list) => list.isNotEmpty,
            orElse: () => false,
          );
          final hasOffres = packsAsync.maybeWhen(
            data: (list) => list.isNotEmpty,
            orElse: () => false,
          );
          final visibleSections = <PrestataireDetailSection>[
            PrestataireDetailSection.services,
            PrestataireDetailSection.gallery,
            if (hasBoutique) PrestataireDetailSection.boutique,
            if (hasOffres) PrestataireDetailSection.offres,
            PrestataireDetailSection.about,
            PrestataireDetailSection.reviews,
          ];
          final selectedSection =
              visibleSections.contains(_selectedSection)
                  ? _selectedSection
                  : PrestataireDetailSection.services;
          if (selectedSection != _selectedSection) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _selectedSection = selectedSection);
            });
          }

          final chatAccess = !isOwnProfile
              ? ref.watch(clientPrestaChatAccessProvider(data.profile.id))
              : null;
          final canMessage = chatAccess?.maybeWhen(
                data: (a) => a.kind == ClientPrestaChatAccessKind.ready,
                orElse: () => false,
              ) ??
              false;

          return WebFlowPageFrame(
            child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      prestataireLikesCountProvider(widget.prestataireId),
                    );
                    ref.invalidate(
                      prestataireDetailProvider(widget.prestataireId),
                    );
                    await ref.read(
                      prestataireDetailProvider(widget.prestataireId).future,
                    );
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      PrestataireDetailHero(
                        profile: data.profile,
                        displayTitle: displayTitle,
                        avatarUrl: data.avatarUrl,
                        onShare: () => sharePrestataireProfile(
                          context: context,
                          prestataireId: data.profile.id,
                          displayName: displayTitle,
                          publicSlug: data.profile.publicSlug,
                        ),
                        onReport: isOwnProfile
                            ? null
                            : () => showReportContentSheet(
                                  context,
                                  targetType:
                                      ContentReportTargetType.prestataireProfile,
                                  targetId: data.profile.id,
                                ),
                      ),
                      SliverToBoxAdapter(
                        child: PrestataireDetailIdentityCard(
                          profile: data.profile,
                          servicesCount: data.services.length,
                          isOwnProfile: isOwnProfile,
                          onBook: () => context.pushBooking(
                            prestataireId: data.profile.id,
                          ),
                          onMessage: canMessage
                              ? () => openChatWithPrestataire(
                                    context,
                                    ref,
                                    data.profile.id,
                                  )
                              : null,
                        ),
                      ),
                      if (!isOwnProfile)
                        SliverToBoxAdapter(
                          child: PrestataireClientEngagementRow(
                            prestataireId: data.profile.id,
                          ),
                        ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: PrestataireDetailSectionNavDelegate(
                          selected: selectedSection,
                          onSelected: _selectSection,
                          visibleSections: visibleSections,
                          height: PrestataireDetailSectionNavDelegate.heightFor(
                            context,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: KeyedSubtree(
                          key: _sectionBodyKey,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: KeyedSubtree(
                              key: ValueKey(selectedSection),
                              child: _DetailSectionBody(
                                section: selectedSection,
                                data: data,
                                isOwnProfile: isOwnProfile,
                                onOpenGallery: () => _selectSection(
                                  PrestataireDetailSection.gallery,
                                ),
                                onOpenServices: () => _selectSection(
                                  PrestataireDetailSection.services,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
              if (!isOwnProfile)
                PrestataireDetailBottomBar(
                  minPrice: minPrice,
                  onBook: () => context.pushBooking(
                    prestataireId: data.profile.id,
                  ),
                ),
            ],
          ),
          );
        },
        error: (_, __) => PrestataireBrandScaffold(
          appBar: prestataireBrandAppBar(
            context: context,
            title: const Text(DiscPrestaDetail.screenTitle),
            leading: _publicProfileBackLeading(context),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Text(
              DiscPrestaDetail.loadErr,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        loading: () => PrestataireBrandScaffold(
          appBar: prestataireBrandAppBar(
            context: context,
            title: const Text(DiscPrestaDetail.screenTitle),
            leading: _publicProfileBackLeading(context),
            automaticallyImplyLeading: false,
          ),
          body: const DiscoveryDetailSkeleton(),
        ),
      ),
      ),
    );
  }
}

class _DetailSectionBody extends StatelessWidget {
  const _DetailSectionBody({
    required this.section,
    required this.data,
    required this.isOwnProfile,
    this.onOpenGallery,
    this.onOpenServices,
  });

  final PrestataireDetailSection section;
  final PrestataireDetailData data;
  final bool isOwnProfile;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onOpenServices;

  bool get _hasAboutContent {
    final p = data.profile;
    return p.description?.trim().isNotEmpty == true ||
        p.bio?.trim().isNotEmpty == true ||
        p.experienceProfessionnelle?.trim().isNotEmpty == true ||
        p.anneesExperience?.trim().isNotEmpty == true ||
        p.lieuTravail != null;
  }

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      PrestataireDetailSection.services => PrestataireDetailSectionCard(
          icon: Icons.content_cut_rounded,
          title: DiscPrestaDetail.svcTitle,
          trailing: data.services.isNotEmpty
              ? Text(
                  '${data.services.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
          child: data.services.isEmpty
              ? const PrestataireDetailEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: DiscPrestaDetail.noSvcsTitle,
                  body: DiscPrestaDetail.noSvcsBody,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrestataireDetailServicesGrouped(
                      groups: groupServicesByMain(
                        data.services,
                        otherGroupTitle: DiscPrestaDetail.servicesOtherGroup,
                      ),
                      canBook: !isOwnProfile,
                      onBook: (serviceId) => context.pushBooking(
                        prestataireId: data.profile.id,
                        serviceId: serviceId,
                      ),
                    ),
                    if (data.photos.isNotEmpty && onOpenGallery != null) ...[
                      const SizedBox(height: 16),
                      _ServicesGalleryTeaser(
                        photos: data.photos,
                        onOpenGallery: onOpenGallery!,
                      ),
                    ],
                  ],
                ),
        ),
      PrestataireDetailSection.boutique => PrestataireDetailBoutiqueBlock(
          prestataireId: data.profile.id,
          prestataireName: _profileDisplayTitle(data.profile),
          canShop: !isOwnProfile,
          mode: PrestataireDetailBoutiqueMode.produits,
        ),
      PrestataireDetailSection.offres => PrestataireDetailBoutiqueBlock(
          prestataireId: data.profile.id,
          prestataireName: _profileDisplayTitle(data.profile),
          canShop: !isOwnProfile,
          mode: PrestataireDetailBoutiqueMode.packs,
        ),
      PrestataireDetailSection.gallery => PrestataireDetailSectionCard(
          icon: Icons.photo_library_outlined,
          title: DiscPrestaDetail.galleryTitle,
          trailing: data.services.isNotEmpty && onOpenServices != null
              ? TextButton(
                  onPressed: onOpenServices,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(DiscPrestaDetail.gallerySeeServices),
                )
              : null,
          child: data.photos.isEmpty
              ? const PrestataireDetailEmptyState(
                  icon: Icons.photo_library_outlined,
                  title: DiscPrestaDetail.noPhotosTitle,
                  body: DiscPrestaDetail.noPhotosBody,
                )
              : PrestataireDetailGalleryGrouped(sections: data.gallerySections),
        ),
      PrestataireDetailSection.about => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isOwnProfile)
              PrestataireDetailMessagingSection(
                prestataireId: data.profile.id,
              ),
            if (isOwnProfile) const PrestataireDetailOwnProfileBanner(),
            if (_hasAboutContent)
              PrestataireDetailSectionCard(
                icon: Icons.person_outline_rounded,
                title: DiscPrestaDetail.aboutTitle,
                child: PrestataireDetailAboutBlock(profile: data.profile),
              ),
            if (data.profile.confortClient.isNotEmpty ||
                data.profile.conditionsService.isNotEmpty)
              PrestataireDetailSectionCard(
                icon: Icons.spa_outlined,
                title: DiscPrestaDetail.comfortTitle,
                child: PrestataireClientExperienceSection(
                  comfortIds: data.profile.confortClient,
                  conditionIds: data.profile.conditionsService,
                  padding: EdgeInsets.zero,
                ),
              ),
            if (data.specialtyGroups.isNotEmpty)
              PrestataireDetailSectionCard(
                icon: Icons.auto_awesome_rounded,
                title: DiscPrestaDetail.specialtiesTitle,
                child: PrestataireDetailSpecialtiesByService(
                  groups: data.specialtyGroups,
                ),
              ),
            PrestataireDetailSectionCard(
              icon: Icons.schedule_outlined,
              title: DiscPrestaDetail.horairesTitle,
              child: PrestatairePublicHorairesSection(horaires: data.horaires),
            ),
          ],
        ),
      PrestataireDetailSection.reviews => PrestataireDetailSectionCard(
          icon: Icons.star_outline_rounded,
          title: DiscPrestaDetail.reviewsTitle,
          child: PrestatairePublicReviewsLiveSection(
            prestataireId: data.profile.id,
            onReviewTap: isOwnProfile
                ? (review) => showViewReviewSheet(
                      context,
                      item: ClientReviewListItem(review: review),
                    )
                : null,
          ),
        ),
    };
  }
}

class _ServicesGalleryTeaser extends StatelessWidget {
  const _ServicesGalleryTeaser({
    required this.photos,
    required this.onOpenGallery,
  });

  final List<PhotoRealisation> photos;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = photos.take(8).toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DiscPrestaDetail.servicesGalleryLinkTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onOpenGallery,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(DiscPrestaDetail.servicesSeeGallery),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PrestataireDetailGalleryStrip(photos: preview),
          ],
        ),
      ),
    );
  }
}

String _profileDisplayTitle(PrestataireProfile profile) {
  final display = normalizeSingleLineText(profile.nomAffiche);
  final salon = normalizeSingleLineText(profile.nomSalon);
  if (display.isNotEmpty) return display;
  if (salon.isNotEmpty) return salon;
  return DiscPrestaDetail.screenTitle;
}
