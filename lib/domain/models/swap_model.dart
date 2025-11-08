enum SwapStatus { pending, accepted, rejected, completed }

extension SwapStatusExtension on SwapStatus {
  String get displayName {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.completed:
        return 'Completed';
    }
  }

  static SwapStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return SwapStatus.pending;
      case 'accepted':
        return SwapStatus.accepted;
      case 'rejected':
        return SwapStatus.rejected;
      case 'completed':
        return SwapStatus.completed;
      default:
        return SwapStatus.pending;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case SwapStatus.pending:
        return 'pending';
      case SwapStatus.accepted:
        return 'accepted';
      case SwapStatus.rejected:
        return 'rejected';
      case SwapStatus.completed:
        return 'completed';
    }
  }
}

class SwapModel {
  final String id;
  final String senderUserId;
  final String senderUserName;
  final String recipientUserId;
  final String recipientUserName;
  final String bookId;
  final String bookTitle;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapModel({
    required this.id,
    required this.senderUserId,
    required this.senderUserName,
    required this.recipientUserId,
    required this.recipientUserName,
    required this.bookId,
    required this.bookTitle,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory SwapModel.fromMap(Map<String, dynamic> map, String id) {
    return SwapModel(
      id: id,
      senderUserId: map['senderUserId'] ?? '',
      senderUserName: map['senderUserName'] ?? 'Unknown',
      recipientUserId: map['recipientUserId'] ?? '',
      recipientUserName: map['recipientUserName'] ?? 'Unknown',
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      status: SwapStatusExtension.fromString(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUserId': senderUserId,
      'senderUserName': senderUserName,
      'recipientUserId': recipientUserId,
      'recipientUserName': recipientUserName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'status': status.toFirestoreString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SwapModel copyWith({
    String? id,
    String? senderUserId,
    String? senderUserName,
    String? recipientUserId,
    String? recipientUserName,
    String? bookId,
    String? bookTitle,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapModel(
      id: id ?? this.id,
      senderUserId: senderUserId ?? this.senderUserId,
      senderUserName: senderUserName ?? this.senderUserName,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      recipientUserName: recipientUserName ?? this.recipientUserName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
