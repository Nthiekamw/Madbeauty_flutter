class AdminAnalyticsSummary {
  const AdminAnalyticsSummary({
    required this.usersTotal,
    required this.usersBanned,
    required this.prestatairesTotal,
    required this.prestatairesVerified,
    required this.verificationPending,
    required this.reportsPending,
    required this.reservationsTotal,
    required this.reservationsThisMonth,
    required this.revenueCapturedCents,
    required this.revenueThisMonthCents,
  });

  final int usersTotal;
  final int usersBanned;
  final int prestatairesTotal;
  final int prestatairesVerified;
  final int verificationPending;
  final int reportsPending;
  final int reservationsTotal;
  final int reservationsThisMonth;
  final int revenueCapturedCents;
  final int revenueThisMonthCents;

  factory AdminAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    int readInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    return AdminAnalyticsSummary(
      usersTotal: readInt('users_total'),
      usersBanned: readInt('users_banned'),
      prestatairesTotal: readInt('prestataires_total'),
      prestatairesVerified: readInt('prestataires_verified'),
      verificationPending: readInt('verification_pending'),
      reportsPending: readInt('reports_pending'),
      reservationsTotal: readInt('reservations_total'),
      reservationsThisMonth: readInt('reservations_this_month'),
      revenueCapturedCents: readInt('revenue_captured_cents'),
      revenueThisMonthCents: readInt('revenue_this_month_cents'),
    );
  }
}
