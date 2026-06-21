import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/likes/logic/toggle_prestataire_like.dart';
import '../../../features/likes/providers/client_prestataire_likes_provider.dart';
import '../../../shared/theme/app_colors.dart';

/// Pouce « like » client sur un profil prestataire.
class PrestataireLikeButton extends ConsumerStatefulWidget {
  const PrestataireLikeButton({
    super.key,
    required this.prestataireId,
    this.style = PrestataireLikeButtonStyle.overlay,
    this.compact = false,
  });

  final String prestataireId;
  final PrestataireLikeButtonStyle style;
  final bool compact;

  @override
  ConsumerState<PrestataireLikeButton> createState() =>
      _PrestataireLikeButtonState();
}

enum PrestataireLikeButtonStyle { overlay, hero }

class _PrestataireLikeButtonState extends ConsumerState<PrestataireLikeButton>
    with SingleTickerProviderStateMixin {
  static const _likedColor = Color(0xFF2563EB);

  late final AnimationController _scaleController;
  late final Animation<double> _scale;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: 1.22).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await togglePrestataireLike(
        context: context,
        ref: ref,
        prestataireId: widget.prestataireId,
      );
      if (!mounted) return;
      await _scaleController.forward();
      await _scaleController.reverse();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = ref.watch(isPrestataireLikedProvider(widget.prestataireId));
    final theme = Theme.of(context);

    final Color iconColor;
    final Color backgroundColor;
    switch (widget.style) {
      case PrestataireLikeButtonStyle.overlay:
        iconColor = isLiked ? _likedColor : AppColors.white;
        backgroundColor = isLiked
            ? AppColors.white
            : AppColors.onPrimarySurface28;
      case PrestataireLikeButtonStyle.hero:
        iconColor = isLiked ? _likedColor : AppColors.white;
        backgroundColor = theme.colorScheme.surface.withValues(alpha: 0.22);
    }

    final size = widget.compact ? 34.0 : 40.0;
    final iconSize = widget.compact ? 18.0 : 22.0;

    return Tooltip(
      message: isLiked ? DiscLike.unlikeTooltip : DiscLike.likeTooltip,
      child: Semantics(
        button: true,
        label: isLiked ? DiscLike.unlikeTooltip : DiscLike.likeTooltip,
        child: ScaleTransition(
          scale: _scale,
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _busy ? null : _onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
