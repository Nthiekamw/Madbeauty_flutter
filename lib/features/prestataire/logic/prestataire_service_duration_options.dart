import '../../../core/constants/app_strings.dart';

/// Durées proposées dans le formulaire prestataire (minutes).
abstract final class PrestataireServiceDurationOptions {
  PrestataireServiceDurationOptions._();

  static const presetMinutes = [30, 60, 90, 120];

  static bool isPreset(int minutes) => presetMinutes.contains(minutes);

  static String labelForMinutes(int minutes) {
    return switch (minutes) {
      30 => DiscPrestaForm.svcDuration30,
      60 => DiscPrestaForm.svcDuration1h,
      90 => DiscPrestaForm.svcDuration1h30,
      120 => DiscPrestaForm.svcDuration2h,
      _ => DiscPrestaForm.svcDurationCustomValue(minutes),
    };
  }
}
