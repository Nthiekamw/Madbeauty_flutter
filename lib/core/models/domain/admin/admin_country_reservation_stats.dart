class AdminCountryReservationStats {
  const AdminCountryReservationStats({
    required this.countryCode,
    required this.reservationsTotal,
    required this.reservationsThisMonth,
    required this.prestatairesCount,
    required this.revenueCapturedCents,
  });

  final String countryCode;
  final int reservationsTotal;
  final int reservationsThisMonth;
  final int prestatairesCount;
  final int revenueCapturedCents;

  factory AdminCountryReservationStats.fromJson(Map<String, dynamic> json) {
    int readInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    return AdminCountryReservationStats(
      countryCode: (json['country_code'] as String?)?.trim().toUpperCase() ?? 'XX',
      reservationsTotal: readInt('reservations_total'),
      reservationsThisMonth: readInt('reservations_this_month'),
      prestatairesCount: readInt('prestataires_count'),
      revenueCapturedCents: readInt('revenue_captured_cents'),
    );
  }
}
