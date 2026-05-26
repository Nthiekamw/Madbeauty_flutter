import 'package:flutter/material.dart';

/// Deux champs côte à côte (prénom/nom, ville/CP, etc.).
class RegisterFieldRow extends StatelessWidget {
  const RegisterFieldRow({
    super.key,
    required this.left,
    required this.right,
    this.gap = 10,
  });

  final Widget left;
  final Widget right;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(child: right),
      ],
    );
  }
}
