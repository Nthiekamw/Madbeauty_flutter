import 'package:flutter/material.dart';

/// Métadonnées d'une étape (titre + icône).
class PrestataireHubStepMeta {
  const PrestataireHubStepMeta({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}
