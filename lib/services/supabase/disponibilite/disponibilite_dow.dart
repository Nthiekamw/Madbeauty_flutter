/// Conversion jour Dart â†” PostgreSQL `extract(dow)` (0 = dimanche).
abstract final class DisponibiliteDow {
  DisponibiliteDow._();

  static int fromDartWeekday(int dartWeekday) {
    return dartWeekday == DateTime.sunday ? 0 : dartWeekday;
  }

  static int toDartWeekday(int pgDow) {
    return pgDow == 0 ? DateTime.sunday : pgDow;
  }
}

