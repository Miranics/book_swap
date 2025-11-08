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
}

class ChatThread {
  final String id;
  final String userId1;
  final String userId1Name;
  final String userId2;
  final String userId2Name;
  final String? swapId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;

  ChatThread({
    required this.id,
    required this.userId1,
    required this.userId1Name,
    required this.userId2,
    required this.userId2Name,
    this.swapId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
  });

  factory ChatThread.fromMap(Map<String, dynamic> map, String id) {
    return ChatThread(
      id: id,
      userId1: map['userId1'] ?? '',
      userId1Name: map['userId1Name'] ?? 'Unknown',
      userId2: map['userId2'] ?? '',
      userId2Name: map['userId2Name'] ?? 'Unknown',
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
      'swapId': swapId,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }
}
