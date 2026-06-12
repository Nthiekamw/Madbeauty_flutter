class AdminBugReport {
  const AdminBugReport({
    required this.id,
    required this.reporterUserId,
    this.reporterEmail,
    this.reporterDisplayName,
    required this.title,
    required this.category,
    required this.description,
    this.stepsToReproduce,
    this.appVersion,
    this.platform,
    this.deviceInfo,
    this.currentScreen,
    this.screenshotUrl,
    required this.status,
    this.adminNotes,
    this.reporterMessage,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  final String id;
  final String reporterUserId;
  final String? reporterEmail;
  final String? reporterDisplayName;
  final String title;
  final String category;
  final String description;
  final String? stepsToReproduce;
  final String? appVersion;
  final String? platform;
  final String? deviceInfo;
  final String? currentScreen;
  final String? screenshotUrl;
  final String status;
  final String? adminNotes;
  final String? reporterMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  bool get isPending => status == 'pending' || status == 'in_progress';

  String get reporterLabel {
    final name = reporterDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = reporterEmail?.trim();
    if (email != null && email.isNotEmpty) return email;
    return reporterUserId;
  }
}
