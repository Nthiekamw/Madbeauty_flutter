import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_network_image.dart';

class _PromoSlide {
  const _PromoSlide({
    required this.url,
    required this.icon,
    required this.tagline,
    required this.body,
  });

  final String url;
  final IconData icon;
  final String tagline;
  final String body;
}

const _kPromoSlides = [
  _PromoSlide(
    url:
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400&h=400&fit=crop&q=80',
    icon: Icons.content_cut_rounded,
    tagline: 'Coiffure & couleur',
    body: 'Trouvez le salon idéal pour votre prochaine transformation.',
  ),
  _PromoSlide(
    url:
        'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400&h=400&fit=crop&q=80',
    icon: Icons.back_hand_outlined,
    tagline: 'Manucure & nail art',
    body: 'Des prestas créatives pour des ongles qui vous ressemblent.',
  ),
  _PromoSlide(
    url:
        'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400&h=400&fit=crop&q=80',
    icon: Icons.face_retouching_natural_rounded,
    tagline: 'Maquillage & glow',
    body: 'Préparez votre look pour une occasion spéciale.',
  ),
  _PromoSlide(
    url:
        'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?w=400&h=400&fit=crop&q=80',
    icon: Icons.spa_rounded,
    tagline: 'Soins & bien-être',
    body: 'Offrez-vous un moment de détente près de chez vous.',
  ),
];

/// Bannière promo catalogue avec carrousel auto-défilant.
class ListingPromoBanner extends StatefulWidget {
  const ListingPromoBanner({super.key});

  @override
  State<ListingPromoBanner> createState() => _ListingPromoBannerState();
}

class _ListingPromoBannerState extends State<ListingPromoBanner> {
  static const _imageExtent = 96.0;
  static const _autoInterval = Duration(seconds: 4);

  late final PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scheduleAutoAdvance();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoInterval, (_) => _advance(animated: true));
  }

  void _advance({required bool animated}) {
    if (!mounted || !_pageController.hasClients) return;
    final next = (_currentPage + 1) % _kPromoSlides.length;
    if (animated) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(next);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _scheduleAutoAdvance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final slide = _kPromoSlides[_currentPage];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 4),
      child: Material(
        color: isDark
            ? primary.withValues(alpha: 0.22)
            : AppColors.filterChipInactive,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primary.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscClientWorkspace.promoTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<int>(_currentPage),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.tagline,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w700,
                                color: primary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              slide.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                                fontSize: 11.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            DiscClientWorkspace.promoCta,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _PromoPageDots(
                            count: _kPromoSlides.length,
                            index: _currentPage,
                            activeColor: primary,
                            inactiveColor: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: _imageExtent,
                  height: _imageExtent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.35 : 0.14,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: _kPromoSlides.length,
                        itemBuilder: (context, index) {
                          return _PromoNetworkImage(
                            slide: _kPromoSlides[index],
                            primary: primary,
                          );
                        },
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

class _PromoPageDots extends StatelessWidget {
  const _PromoPageDots({
    required this.count,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 5),
            width: i == index ? 14 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _PromoNetworkImage extends StatelessWidget {
  const _PromoNetworkImage({
    required this.slide,
    required this.primary,
  });

  final _PromoSlide slide;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget fallback() {
      return ColoredBox(
        color: primary.withValues(alpha: isDark ? 0.2 : 0.12),
        child: Center(
          child: Icon(
            slide.icon,
            size: 36,
            color: primary.withValues(alpha: 0.75),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: AppNetworkImage(
        url: slide.url,
        fit: BoxFit.cover,
        placeholder: fallback(),
        error: fallback(),
      ),
    );
  }
}
