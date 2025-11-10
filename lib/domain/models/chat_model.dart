class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      recipientId: map['recipientId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatThread {
  final String id;
  final String userId1;
  final String userId1Name;
  final String userId2;
  final String userId2Name;
  final String threadKey;
  final List<String> participants;
  final String? swapId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final Map<String, int> unreadCounts;

  ChatThread({
    required this.id,
    required this.userId1,
    required this.userId1Name,
    required this.userId2,
    required this.userId2Name,
    required this.threadKey,
    required this.participants,
    required this.unreadCounts,
    this.swapId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map, String id) {
    final rawUnread = map['unreadCounts'];
    final unreadCounts = <String, int>{};
    if (rawUnread is Map) {
      rawUnread.forEach((key, value) {
        if (key is String) {
          if (value is int) {
            unreadCounts[key] = value;
          } else if (value is num) {
            unreadCounts[key] = value.toInt();
          }
        }
      });
    }

    return ChatThread(
      id: id,
      userId1: map['userId1'] ?? '',
      userId1Name: map['userId1Name'] ?? 'Unknown',
      userId2: map['userId2'] ?? '',
      userId2Name: map['userId2Name'] ?? 'Unknown',
      threadKey: map['threadKey'] ?? '',
      participants: List<String>.from(map['participants'] ?? const []),
      unreadCounts: unreadCounts,
      swapId: map['swapId'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastMessageAt: map['lastMessageAt'] != null 
          ? DateTime.parse(map['lastMessageAt'])
          : null,
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId1': userId1,
      'userId1Name': userId1Name,
      'userId2': userId2,
      'userId2Name': userId2Name,
      'threadKey': threadKey,
      'participants': participants,
      'unreadCounts': unreadCounts,
      'swapId': swapId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  ChatThread copyWith({
    String? id,
    String? userId1,
    String? userId1Name,
    String? userId2,
    String? userId2Name,
    String? threadKey,
    List<String>? participants,
    Map<String, int>? unreadCounts,
    String? swapId,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
  }) {
    return ChatThread(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId1Name: userId1Name ?? this.userId1Name,
      userId2: userId2 ?? this.userId2,
      userId2Name: userId2Name ?? this.userId2Name,
      threadKey: threadKey ?? this.threadKey,
      participants: participants ?? List<String>.from(this.participants),
      unreadCounts: unreadCounts ?? Map<String, int>.from(this.unreadCounts),
      swapId: swapId ?? this.swapId,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
