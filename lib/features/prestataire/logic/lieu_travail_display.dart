import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/lieu_travail.dart';

/// Libellés lecture seule pour [LieuTravail] (fiche publique).
abstract final class LieuTravailDisplay {
  LieuTravailDisplay._();

  static String label(LieuTravail? lieu) => switch (lieu) {
        LieuTravail.home => DiscPrestaForm.workLocationHome,
        LieuTravail.client => DiscPrestaForm.workLocationClient,
        LieuTravail.both => DiscPrestaForm.workLocationBoth,
        null => '',
      };

  static IconData icon(LieuTravail lieu) => switch (lieu) {
        LieuTravail.home => Icons.home_outlined,
        LieuTravail.client => Icons.directions_walk_outlined,
        LieuTravail.both => Icons.swap_horiz_outlined,
      };
}

