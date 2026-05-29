import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../../router/navigation_extensions.dart';
import '../app/app_snack_bar.dart';

/// Cœur favori avec animation scale + changement de couleur.
class PrestataireFavoriteButton extends ConsumerStatefulWidget {
  const PrestataireFavoriteButton({
    super.key,
    required this.prestataireId,
    this.compact = false,
    this.style = PrestataireFavoriteButtonStyle.overlay,
  });

  final String prestataireId;
  final bool compact;
  final PrestataireFavoriteButtonStyle style;

  @override
  ConsumerState<PrestataireFavoriteButton> createState() =>
      _PrestataireFavoriteButtonState();
}

enum PrestataireFavoriteButtonStyle {
  /// Sur photo de carte (fond sombre semi-transparent).
  overlay,

  /// Sur le hero de la fiche (fond clair, icône blanche / rouge).
  hero,
}

class _PrestataireFavoriteButtonState
    extends ConsumerState<PrestataireFavoriteButton>
    with SingleTickerProviderStateMixin {
  static const _favoriteColor = Color(0xFFE11D48);

  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.38), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.38, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    if (_busy) return;

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscFavori.loginRequired);
      context.pushLogin();
      return;
    }

    setState(() => _busy = true);
    _pulse.forward(from: 0);

    try {
      await ref
          .read(clientFavoritePrestataireIdsProvider.notifier)
          .toggle(widget.prestataireId);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscFavori.toggleError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite =
        ref.watch(isPrestataireFavoriteProvider(widget.prestataireId));
    final iconSize = widget.compact ? 20.0 : 24.0;
    final pad = widget.compact ? 6.0 : 8.0;

    final Color iconColor;
    final Color? backgroundColor;
    final Color? borderColor;

    switch (widget.style) {
      case PrestataireFavoriteButtonStyle.overlay:
        iconColor = isFavorite ? _favoriteColor : Colors.white;
        backgroundColor = Colors.black.withValues(alpha: 0.38);
        borderColor = Colors.white.withValues(alpha: isFavorite ? 0.5 : 0.28);
      case PrestataireFavoriteButtonStyle.hero:
        iconColor = isFavorite ? _favoriteColor : Colors.white;
        backgroundColor = Colors.white.withValues(alpha: 0.18);
        borderColor = Colors.white.withValues(alpha: 0.45);
    }

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: backgroundColor,
        shape: CircleBorder(
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _busy ? null : _onPressed,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: isFavorite
                ? DiscFavori.unfavoriteTooltip
                : DiscFavori.favoriteTooltip,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  size: iconSize,
                  color: iconColor,
                  shadows: widget.style == PrestataireFavoriteButtonStyle.overlay &&
                          !isFavorite
                      ? [
                          Shadow(
                            color: theme.shadowColor.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
