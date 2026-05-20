import 'package:flutter/material.dart';

import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          );

  /// Wordmark / splash (ex. « MadBeauty »).
  static TextStyle brand(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontFamily: AppFonts.brand,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
          );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.4,
          );
}
