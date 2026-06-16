class BugReportMessage {
  const BugReportMessage({
    required this.id,
    required this.bugReportId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.deliveredAt,
  });

  final String id;
  final String bugReportId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? deliveredAt;

  factory BugReportMessage.fromRow(Map<String, dynamic> row) {
    return BugReportMessage(
      id: row['id'] as String? ?? '',
      bugReportId: row['bug_report_id'] as String? ?? '',
      senderId: row['sender_id'] as String? ?? '',
      content: row['content'] as String? ?? '',
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRead: row['is_read'] as bool? ?? false,
      deliveredAt: DateTime.tryParse((row['delivered_at'] as String?) ?? ''),
    );
  }
}
