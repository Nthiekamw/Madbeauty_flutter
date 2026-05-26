import 'package:flutter/material.dart';

import '../../../core/constants/strings/discovery/disc_presta_horaires.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';

/// État d’un jour pour l’éditeur d’horaires hebdomadaire.
class WeeklyJourHoraire {
  WeeklyJourHoraire({
    required this.jourSemaine,
    required this.enabled,
    required this.debut,
    required this.fin,
  });

  final int jourSemaine;
  bool enabled;
  TimeOfDay debut;
  TimeOfDay fin;

  static List<WeeklyJourHoraire> defaultWeek() {
    return [
      for (final pg in DiscPrestaHoraires.joursSemainePg)
        WeeklyJourHoraire(
          jourSemaine: pg,
          enabled: pg >= DateTime.monday && pg <= DateTime.friday,
          debut: const TimeOfDay(hour: 9, minute: 0),
          fin: const TimeOfDay(hour: 18, minute: 0),
        ),
    ];
  }

  static List<WeeklyJourHoraire> fromPlages(List<HorairePlage> horaires) {
    final byJour = {for (final h in horaires) h.jourSemaine: h};
    return defaultWeek().map((template) {
      final existing = byJour[template.jourSemaine];
      if (existing == null) {
        return WeeklyJourHoraire(
          jourSemaine: template.jourSemaine,
          enabled: false,
          debut: template.debut,
          fin: template.fin,
        );
      }
      return WeeklyJourHoraire(
        jourSemaine: template.jourSemaine,
        enabled: true,
        debut: existing.heureDebut,
        fin: existing.heureFin,
      );
    }).toList();
  }
}

extension WeeklyJourHoraireListX on List<WeeklyJourHoraire> {
  List<HorairePlage> toPlages() {
    final plages = <HorairePlage>[];
    for (final jour in this) {
      if (!jour.enabled) continue;
      plages.add(
        HorairePlage(
          jourSemaine: jour.jourSemaine,
          heureDebut: jour.debut,
          heureFin: jour.fin,
        ),
      );
    }
    return plages;
  }

  bool validatePlages() {
    for (final jour in this) {
      if (!jour.enabled) continue;
      final startMin = jour.debut.hour * 60 + jour.debut.minute;
      final endMin = jour.fin.hour * 60 + jour.fin.minute;
      if (endMin <= startMin) return false;
    }
    return true;
  }

  bool get hasAnyOpenDay => any((j) => j.enabled);
}
