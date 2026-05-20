import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';

/// Bouton OAuth Google cohérent avec la charte MadBeauty.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: AuthFormStyles.buttonBorderRadius,
        ),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
          width: 1.2,
        ),
        backgroundColor: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleMark(color: theme.colorScheme.onSurface),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGlyphPainter(color: color)),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  _GoogleGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final r = size.width * 0.38;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      0.4,
      4.8,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(c.dx + r * 0.55, c.dy + r * 0.55),
      Offset(size.width - 1, size.height - 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
