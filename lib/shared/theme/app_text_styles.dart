import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.4,
          );
}
