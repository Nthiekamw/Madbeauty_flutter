class BugReportChatSummary {
  const BugReportChatSummary({
    required this.id,
    required this.title,
    required this.status,
  });

  final String id;
  final String title;
  final String status;

  bool get isTerminal => status == 'resolved' || status == 'closed';

  factory BugReportChatSummary.fromRow(Map<String, dynamic> row) {
    return BugReportChatSummary(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? '',
      status: row['status'] as String? ?? 'pending',
    );
  }
}
