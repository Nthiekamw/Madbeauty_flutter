import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_button.dart';

class BookingSuccessView extends StatefulWidget {
  const BookingSuccessView({
    super.key,
    required this.onViewReservations,
    required this.onGoHome,
    this.onAddToCalendar,
    this.body = DiscBk.doneBody,
  });

  final VoidCallback onViewReservations;
  final VoidCallback onGoHome;
  final VoidCallback? onAddToCalendar;
  final String body;

  @override
  State<BookingSuccessView> createState() => _BookingSuccessViewState();
}

class _BookingSuccessViewState extends State<BookingSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottomInset),
      child: Column(
        children: [
          const Spacer(),
          // Icône animée
          ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Halo extérieur
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
                // Cercle principal
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 56,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Textes
          FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                Text(
                  DiscBk.doneHeadline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 32),
                // Badges info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoBadge(
                      icon: Icons.notifications_active_outlined,
                      label: 'Confirmé',
                      color: primary,
                      theme: theme,
                    ),
                    const SizedBox(width: 10),
                    _InfoBadge(
                      icon: Icons.event_available_rounded,
                      label: 'Réservé',
                      color: AppColors.success,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          const SizedBox(height: 16),

          // CTA
          FadeTransition(
            opacity: _fade,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: AppButton(
                onPressed: widget.onViewReservations,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note_rounded, size: 20),
                    const SizedBox(width: 10),
                    const Text(DiscBk.doneSeeMine),
                  ],
                ),
              ),
            ),
          ),
          if (widget.onAddToCalendar != null) ...[
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _fade,
              child: AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: widget.onAddToCalendar,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available_outlined, size: 20),
                    SizedBox(width: 10),
                    Text(DiscBk.addToCalendar),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _fade,
            child: AppButton(
              variant: AppButtonVariant.secondary,
              onPressed: widget.onGoHome,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_outlined, size: 20),
                  const SizedBox(width: 10),
                  const Text(DiscBk.doneGoHome),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

