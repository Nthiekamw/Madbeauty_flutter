import 'package:flutter/material.dart';

import 'weekly_jour_horaire.dart';

/// Jour d'horaire sérialisable pour le brouillon local du hub.
class HoraireDayDraft {
  const HoraireDayDraft({
    required this.jourSemaine,
    required this.enabled,
    required this.debutHour,
    required this.debutMinute,
    required this.finHour,
    required this.finMinute,
    required this.capaciteSimultanee,
  });

  final int jourSemaine;
  final bool enabled;
  final int debutHour;
  final int debutMinute;
  final int finHour;
  final int finMinute;
  final int capaciteSimultanee;

  Map<String, dynamic> toJson() => {
        'jourSemaine': jourSemaine,
        'enabled': enabled,
        'debutHour': debutHour,
        'debutMinute': debutMinute,
        'finHour': finHour,
        'finMinute': finMinute,
        'capaciteSimultanee': capaciteSimultanee,
      };

  static HoraireDayDraft? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final jour = json['jourSemaine'] as int?;
    if (jour == null) return null;
    return HoraireDayDraft(
      jourSemaine: jour,
      enabled: json['enabled'] as bool? ?? false,
      debutHour: json['debutHour'] as int? ?? 9,
      debutMinute: json['debutMinute'] as int? ?? 0,
      finHour: json['finHour'] as int? ?? 18,
      finMinute: json['finMinute'] as int? ?? 0,
      capaciteSimultanee: json['capaciteSimultanee'] as int? ?? 1,
    );
  }

  static HoraireDayDraft fromWeekly(WeeklyJourHoraire jour) => HoraireDayDraft(
        jourSemaine: jour.jourSemaine,
        enabled: jour.enabled,
        debutHour: jour.debut.hour,
        debutMinute: jour.debut.minute,
        finHour: jour.fin.hour,
        finMinute: jour.fin.minute,
        capaciteSimultanee: jour.capaciteSimultanee,
      );

  WeeklyJourHoraire toWeekly() => WeeklyJourHoraire(
        jourSemaine: jourSemaine,
        enabled: enabled,
        debut: TimeOfDay(hour: debutHour, minute: debutMinute),
        fin: TimeOfDay(hour: finHour, minute: finMinute),
        capaciteSimultanee: capaciteSimultanee,
      );
}

List<WeeklyJourHoraire> weeklyHorairesFromDrafts(List<HoraireDayDraft> drafts) {
  if (drafts.isEmpty) return WeeklyJourHoraire.defaultWeek();
  final byJour = {for (final d in drafts) d.jourSemaine: d};
  return WeeklyJourHoraire.defaultWeek().map((template) {
    final draft = byJour[template.jourSemaine];
    return draft?.toWeekly() ?? template;
  }).toList();
}

