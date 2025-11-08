enum BookCondition { new_, likeNew, good, used }

extension BookConditionExtension on BookCondition {
  String get displayName {
    switch (this) {
      case BookCondition.new_:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  static BookCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return BookCondition.new_;
      case 'likenew':
        return BookCondition.likeNew;
      case 'good':
        return BookCondition.good;
      case 'used':
        return BookCondition.used;
      default:
        return BookCondition.used;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case BookCondition.new_:
        return 'new';
      case BookCondition.likeNew:
        return 'likenew';
      case BookCondition.good:
        return 'good';
      case BookCondition.used:
        return 'used';
    }
  }
}

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? coverImageUrl;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.coverImageUrl,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookConditionExtension.fromString(map['condition'] ?? 'used'),
      coverImageUrl: map['coverImageUrl'],
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
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
      'title': title,
      'author': author,
      'condition': condition.toFirestoreString(),
      'coverImageUrl': coverImageUrl,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? coverImageUrl,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
