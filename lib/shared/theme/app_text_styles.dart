import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: AppColors.outline,
            height: 1.4,
          );
}
