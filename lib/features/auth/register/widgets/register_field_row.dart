import 'package:flutter/material.dart';

/// Deux champs côte à côte ; empilés sur écran étroit.
class RegisterFieldRow extends StatelessWidget {
  const RegisterFieldRow({
    super.key,
    required this.left,
    required this.right,
    this.gap = 10,
    this.stackBelowWidth = 400,
  });

  final Widget left;
  final Widget right;
  final double gap;
  final double stackBelowWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackBelowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              SizedBox(height: gap),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
