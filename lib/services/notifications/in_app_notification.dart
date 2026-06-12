/// Notification affichée dans l'application (liste locale persistée).
class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.actionType,
    this.prestataireId,
    this.serviceId,
    this.dateJour,
    this.reservationId,
    this.bookingId,
    this.role,
    this.nav,
    this.bugReportId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? actionType;
  final String? prestataireId;
  final String? serviceId;
  final String? dateJour;
  final String? reservationId;
  final String? bookingId;
  final String? role;
  final String? nav;
  final String? bugReportId;

  InAppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
    String? actionType,
    String? prestataireId,
    String? serviceId,
    String? dateJour,
    String? reservationId,
    String? bookingId,
    String? role,
    String? nav,
    String? bugReportId,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      actionType: actionType ?? this.actionType,
      prestataireId: prestataireId ?? this.prestataireId,
      serviceId: serviceId ?? this.serviceId,
      dateJour: dateJour ?? this.dateJour,
      reservationId: reservationId ?? this.reservationId,
      bookingId: bookingId ?? this.bookingId,
      role: role ?? this.role,
      nav: nav ?? this.nav,
      bugReportId: bugReportId ?? this.bugReportId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
        if (actionType != null) 'actionType': actionType,
        if (prestataireId != null) 'prestataireId': prestataireId,
        if (serviceId != null) 'serviceId': serviceId,
        if (dateJour != null) 'dateJour': dateJour,
        if (reservationId != null) 'reservationId': reservationId,
        if (bookingId != null) 'bookingId': bookingId,
        if (role != null) 'role': role,
        if (nav != null) 'nav': nav,
        if (bugReportId != null) 'bugReportId': bugReportId,
      };

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'MadBeauty',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      read: json['read'] as bool? ?? false,
      actionType: json['actionType'] as String?,
      prestataireId: json['prestataireId'] as String?,
      serviceId: json['serviceId'] as String?,
      dateJour: json['dateJour'] as String?,
      reservationId: json['reservationId'] as String?,
      bookingId: json['bookingId'] as String?,
      role: json['role'] as String?,
      nav: json['nav'] as String?,
      bugReportId: json['bugReportId'] as String?,
    );
  }
}
