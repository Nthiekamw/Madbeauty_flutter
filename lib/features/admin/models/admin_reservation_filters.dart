class AdminReservationFilters {
  const AdminReservationFilters({
    this.statut,
    this.paymentStatus,
    this.fromDate,
    this.toDate,
    this.limit = 100,
  });

  final String? statut;
  final String? paymentStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;

  static const allStatuts = <String>[
    '',
    'en_attente',
    'confirmee',
    'terminee',
    'annulee',
    'sync_pending',
  ];

  static const allPaymentStatuses = <String>[
    '',
    'authorized',
    'captured',
    'failed',
    'canceled',
  ];

  AdminReservationFilters copyWith({
    String? statut,
    String? paymentStatus,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    bool clearStatut = false,
    bool clearPaymentStatus = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return AdminReservationFilters(
      statut: clearStatut ? null : (statut ?? this.statut),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdminReservationFilters &&
      other.statut == statut &&
      other.paymentStatus == paymentStatus &&
      other.fromDate == fromDate &&
      other.toDate == toDate &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(statut, paymentStatus, fromDate, toDate, limit);
}
