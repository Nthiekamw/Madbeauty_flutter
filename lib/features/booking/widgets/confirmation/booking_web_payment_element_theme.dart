import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

import '../../../../shared/theme/app_colors.dart';

/// Apparence Stripe Payment Element alignée sur MadBeauty.
ElementAppearance bookingWebPaymentElementAppearance(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ElementAppearance(
    theme: ElementTheme.stripe,
    labels: ElementAppearanceLabels.floating,
    variables: {
      'colorPrimary': _colorHex(AppColors.brandBrown),
      'colorBackground': _colorHex(
        isDark ? AppColors.darkSurfaceContainerHigh : AppColors.cardSurfaceLight,
      ),
      'colorText': _colorHex(
        isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      ),
      'colorTextSecondary': _colorHex(
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
      ),
      'colorDanger': _colorHex(
        isDark ? AppColors.errorDark : AppColors.errorLight,
      ),
      'borderRadius': '12px',
      'spacingUnit': '4px',
      'fontSizeBase': '15px',
    },
  );
}

/// Carte uniquement — pas de Klarna / Amazon Pay sur la réservation.
const List<String> bookingWebPaymentMethodOrder = ['card'];

String _colorHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
