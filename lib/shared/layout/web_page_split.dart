import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Deux colonnes web : occupe la largeur sans laisser de vide à droite.
class WebPageSplit extends StatelessWidget {
  const WebPageSplit({
    super.key,
    required this.leading,
    required this.trailing,
    this.leadingWidth = 360,
    this.gap = 28,
  });

  final Widget leading;
  final Widget trailing;
  final double leadingWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebTwoPane) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leading,
          SizedBox(height: gap),
          trailing,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: leadingWidth,
          child: leading,
        ),
        SizedBox(width: gap),
        Expanded(child: trailing),
      ],
    );
  }
}

/// Liste 1 colonne (mobile) / 2 colonnes (web large) pour remplir la page.
class WebPairedList extends StatelessWidget {
  const WebPairedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.gap = 12,
    this.physics,
    this.controller,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double gap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    if (!DiscoveryResponsive.of(context).useWebTwoPane || itemCount == 0) {
      return ListView.separated(
        controller: controller,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: gap),
        itemBuilder: itemBuilder,
      );
    }

    final rows = (itemCount / 2).ceil();
    return ListView.separated(
      controller: controller,
      physics: physics,
      padding: padding,
      itemCount: rows,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: (context, row) {
        final left = row * 2;
        final right = left + 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: itemBuilder(context, left)),
              SizedBox(width: gap),
              Expanded(
                child: right < itemCount
                    ? itemBuilder(context, right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
