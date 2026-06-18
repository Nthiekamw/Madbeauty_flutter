/// Frais plateforme par réservation (réglages admin).
class BookingPlatformFeeSettings {
  const BookingPlatformFeeSettings({
    required this.feeCents,
    required this.freeBookingCount,
  });

  static const defaults = BookingPlatformFeeSettings(
    feeCents: 0,
    freeBookingCount: 2,
  );

  final int feeCents;
  final int freeBookingCount;

  bool get hasPlatformFee => feeCents > 0;

  factory BookingPlatformFeeSettings.fromJson(Map<String, dynamic> json) {
    return BookingPlatformFeeSettings(
      feeCents: (json['fee_cents'] as num?)?.toInt().clamp(0, 100000) ?? 0,
      freeBookingCount:
          (json['free_booking_count'] as num?)?.toInt().clamp(0, 100) ?? 2,
    );
  }
}
