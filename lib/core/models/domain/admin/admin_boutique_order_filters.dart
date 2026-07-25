/// Filtres liste admin des commandes boutique.
class AdminBoutiqueOrderFilters {
  const AdminBoutiqueOrderFilters({
    this.statut,
    this.paymentStatus,
    this.fromDate,
    this.toDate,
    this.search,
    this.limit = 200,
  });

  final String? statut;
  final String? paymentStatus;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? search;
  final int limit;

  static const allStatuts = <String>[
    '',
    'pending_payment',
    'pay_on_site',
    'paid',
    'preparing',
    'ready',
    'completed',
    'canceled',
  ];

  static const allPaymentStatuses = <String>[
    '',
    'unpaid',
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  AdminBoutiqueOrderFilters copyWith({
    String? statut,
    String? paymentStatus,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    int? limit,
    bool clearStatut = false,
    bool clearPaymentStatus = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearSearch = false,
  }) {
    return AdminBoutiqueOrderFilters(
      statut: clearStatut ? null : (statut ?? this.statut),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      search: clearSearch ? null : (search ?? this.search),
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminBoutiqueOrderFilters &&
        other.statut == statut &&
        other.paymentStatus == paymentStatus &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.search == search &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(
        statut,
        paymentStatus,
        fromDate,
        toDate,
        search,
        limit,
      );
}
