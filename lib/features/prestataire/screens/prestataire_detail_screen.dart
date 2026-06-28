import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
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
import '../providers/catalog/prestataire_detail_provider.dart';
import '../widgets/profile/overview/sections/prestataire_client_experience_section.dart';
import '../widgets/public/detail/prestataire_client_engagement_row.dart';
import '../logic/prestataire_services_grouping.dart';
import '../widgets/public/detail/prestataire_detail_sections.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../widgets/public/detail/prestataire_detail_shell.dart';
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
  PrestataireDetailSection _selectedSection =
      PrestataireDetailSection.services;

  final _servicesKey = GlobalKey();
  final _galleryKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _reviewsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(PrestataireDetailSection section) {
    setState(() => _selectedSection = section);
    final key = switch (section) {
      PrestataireDetailSection.services => _servicesKey,
      PrestataireDetailSection.gallery => _galleryKey,
      PrestataireDetailSection.about => _aboutKey,
      PrestataireDetailSection.reviews => _reviewsKey,
    };
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.12,
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

    return PrestataireBrandScaffold(
      body: async.when(
        data: (data) {
          if (data == null) {
            return PrestataireBrandScaffold(
              appBar: prestataireBrandAppBar(
                context: context,
                title: const Text(DiscPrestaDetail.screenTitle),
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
                          prestataireId: data.profile.id,
                          displayName: displayTitle,
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
                          selected: _selectedSection,
                          onSelected: _scrollToSection,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _DetailContent(
                          data: data,
                          isOwnProfile: isOwnProfile,
                          servicesKey: _servicesKey,
                          galleryKey: _galleryKey,
                          aboutKey: _aboutKey,
                          reviewsKey: _reviewsKey,
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
          ),
          body: const DiscoveryDetailSkeleton(),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.data,
    required this.isOwnProfile,
    required this.servicesKey,
    required this.galleryKey,
    required this.aboutKey,
    required this.reviewsKey,
  });

  final PrestataireDetailData data;
  final bool isOwnProfile;
  final GlobalKey servicesKey;
  final GlobalKey galleryKey;
  final GlobalKey aboutKey;
  final GlobalKey reviewsKey;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: servicesKey,
          child: PrestataireDetailSectionCard(
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
                : PrestataireDetailServicesGrouped(
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
          ),
        ),
        KeyedSubtree(
          key: galleryKey,
          child: PrestataireDetailSectionCard(
            icon: Icons.photo_library_outlined,
            title: DiscPrestaDetail.galleryTitle,
            child: data.photos.isEmpty
                ? const PrestataireDetailEmptyState(
                    icon: Icons.photo_library_outlined,
                    title: DiscPrestaDetail.noPhotosTitle,
                    body: DiscPrestaDetail.noPhotosBody,
                  )
                : PrestataireDetailGalleryGrouped(sections: data.gallerySections),
          ),
        ),
        if (!isOwnProfile)
          PrestataireDetailMessagingSection(
            prestataireId: data.profile.id,
          ),
        if (isOwnProfile) const PrestataireDetailOwnProfileBanner(),
        KeyedSubtree(
          key: aboutKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
        ),
        KeyedSubtree(
          key: reviewsKey,
          child: PrestataireDetailSectionCard(
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
        ),
      ],
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
