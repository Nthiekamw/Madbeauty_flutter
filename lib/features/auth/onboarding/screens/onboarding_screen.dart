import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/app_router.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/layout/auth_brand_background.dart';
import '../../widgets/onboarding_page_content.dart';

/// Tour d'horizon (4 pages) avant l'écran Bienvenue.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _pageCount = 4;

  static const _slides = [
    OnboardingSlide(
      showLogo: true,
      title: AuthStrings.onboardingPage1Title,
      body: AuthStrings.onboardingPage1Body,
    ),
    OnboardingSlide(
      icon: Icons.calendar_month_outlined,
      title: AuthStrings.onboardingPage2Title,
      body: AuthStrings.onboardingPage2Body,
    ),
    OnboardingSlide(
      icon: Icons.storefront_outlined,
      title: AuthStrings.onboardingPage3Title,
      body: AuthStrings.onboardingPage3Body,
    ),
    OnboardingSlide(
      icon: Icons.insights_outlined,
      title: AuthStrings.onboardingPage4Title,
      body: AuthStrings.onboardingPage4Body,
      stats: [
        OnboardingStatItem(
          value: AuthStrings.onboardingStatClientsValue,
          label: AuthStrings.onboardingStatClientsLabel,
          icon: Icons.people_outline_rounded,
        ),
        OnboardingStatItem(
          value: AuthStrings.onboardingStatPrestatairesValue,
          label: AuthStrings.onboardingStatPrestatairesLabel,
          icon: Icons.storefront_outlined,
        ),
        OnboardingStatItem(
          value: AuthStrings.onboardingStatReservationsValue,
          label: AuthStrings.onboardingStatReservationsLabel,
          icon: Icons.event_available_outlined,
        ),
        OnboardingStatItem(
          value: AuthStrings.onboardingStatRatingValue,
          label: AuthStrings.onboardingStatRatingLabel,
          icon: Icons.star_rounded,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await LocalCacheService.instance.setOnboardingCompleted();
    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  void _next() {
    if (_index < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final progress = (_index + 1) / _pageCount;
    final isLast = _index == _pageCount - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBrandBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                  child: Row(
                    children: [
                      Text(
                        AuthStrings.onboardingStep(_index + 1, _pageCount),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          AuthStrings.onboardingSkip,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor:
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                      color: primary,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) =>
                        OnboardingPageContent(slide: _slides[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (i) {
                      final active = i == _index;
                      return Semantics(
                        label: 'Page ${i + 1} sur $_pageCount',
                        selected: active,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: active ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: active
                                ? primary
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: AuthFormStyles.buttonBorderRadius,
                      ),
                    ),
                    child: Text(
                      isLast
                          ? AuthStrings.onboardingCtaEnd
                          : AuthStrings.onboardingCtaNext,
                    ),
                  ),
                ),
                if (_index > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: Text(
                          AuthStrings.onboardingBack,
                          style: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
