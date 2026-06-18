class AdminUserSupportThread {
  const AdminUserSupportThread({
    required this.threadId,
    required this.userId,
    this.userEmail,
    this.userDisplayName,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.updatedAt,
  });

  final String threadId;
  final String userId;
  final String? userEmail;
  final String? userDisplayName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime updatedAt;

  String get userLabel {
    final name = userDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = userEmail?.trim();
    if (email != null && email.isNotEmpty) return email;
    return userId;
  }

  factory AdminUserSupportThread.fromRow(Map<String, dynamic> row) {
    return AdminUserSupportThread(
      threadId: row['thread_id'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      userEmail: row['user_email'] as String?,
      userDisplayName: row['user_display_name'] as String?,
      lastMessage: row['last_message'] as String?,
      lastMessageAt: DateTime.tryParse(
        (row['last_message_at'] as String?) ?? '',
      ),
      unreadCount: (row['unread_count'] as num?)?.toInt() ?? 0,
      updatedAt:
          DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
