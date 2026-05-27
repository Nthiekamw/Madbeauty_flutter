import 'package:flutter/material.dart';

/// Plage horaire hebdomadaire (alignée sur `disponibilites.jour_semaine`).
class HorairePlage {
  const HorairePlage({
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
    this.capaciteSimultanee = 1,
  });

  /// 0 = dimanche … 6 = samedi (convention PostgreSQL `DOW`).
  final int jourSemaine;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final int capaciteSimultanee;

  HorairePlage copyWith({
    int? jourSemaine,
    TimeOfDay? heureDebut,
    TimeOfDay? heureFin,
    int? capaciteSimultanee,
  }) {
    return HorairePlage(
      jourSemaine: jourSemaine ?? this.jourSemaine,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      capaciteSimultanee: capaciteSimultanee ?? this.capaciteSimultanee,
    );
  }
}
