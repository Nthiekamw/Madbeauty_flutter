import 'package:flutter/widgets.dart';

/// Unité responsive (largeur / 100) comme dans Madbeauty_flutter.
class PrototypeLayout {
  PrototypeLayout(this.context);

  final BuildContext context;

  double get width => MediaQuery.sizeOf(context).width;

  double get rem => width / 100;

  double sp(double factor) => rem * factor;

  EdgeInsets horizontalPage({double factor = 4}) =>
      EdgeInsets.symmetric(horizontal: sp(factor));
}
