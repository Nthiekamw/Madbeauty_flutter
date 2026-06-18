class AdminBookingPlatformFeeSettings {
  const AdminBookingPlatformFeeSettings({
    required this.feeCents,
    required this.freeBookingCount,
  });

  final int feeCents;
  final int freeBookingCount;

  factory AdminBookingPlatformFeeSettings.fromJson(Map<String, dynamic> json) {
    return AdminBookingPlatformFeeSettings(
      feeCents: (json['fee_cents'] as num?)?.toInt() ?? 0,
      freeBookingCount: (json['free_booking_count'] as num?)?.toInt() ?? 2,
    );
  }
}
