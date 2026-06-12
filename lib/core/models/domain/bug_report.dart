class BugReport {
  const BugReport({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.stepsToReproduce,
    required this.status,
    this.reporterMessage,
    this.screenshotUrl,
    this.appVersion,
    this.platform,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String? stepsToReproduce;
  final String status;
  final String? reporterMessage;
  final String? screenshotUrl;
  final String? appVersion;
  final String? platform;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  bool get isTerminal => status == 'resolved' || status == 'closed';
}
