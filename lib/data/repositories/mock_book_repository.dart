import '../../domain/models/book_model.dart';

/// Mock Book Repository for web demo (no Firestore dependency)
class MockBookRepository {
  static final MockBookRepository _instance = MockBookRepository._internal();
  
  factory MockBookRepository() {
    return _instance;
  }

  MockBookRepository._internal();

  // In-memory storage
  final List<BookModel> _books = [
    BookModel(
      id: 'book_1',
      title: 'Flutter by Example',
      author: 'John Smith',
      condition: BookCondition.likeNew,
      coverImageUrl: 'https://via.placeholder.com/200x300?text=Flutter+Book',
      userId: 'demo_user_2',
      userName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    BookModel(
      id: 'book_2',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      condition: BookCondition.good,
      coverImageUrl: 'https://via.placeholder.com/200x300?text=Clean+Code',
      userId: 'demo_user_2',
      userName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    BookModel(
      id: 'book_3',
      title: 'The Pragmatic Programmer',
      author: 'David Thomas',
      condition: BookCondition.new_,
      coverImageUrl: 'https://via.placeholder.com/200x300?text=Pragmatic',
      userId: 'demo_user_1',
      userName: 'Demo User',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BookModel(
      id: 'book_4',
      title: 'Design Patterns',
      author: 'Gang of Four',
      condition: BookCondition.used,
      coverImageUrl: 'https://via.placeholder.com/200x300?text=Design+Patterns',
      userId: 'demo_user_2',
      userName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  Stream<List<BookModel>> getAllBooks() async* {
    yield _books;
    await Future.delayed(const Duration(seconds: 1));
    yield _books;
  }

  Stream<List<BookModel>> getUserBooks(String userId) async* {
    yield _books.where((b) => b.userId == userId).toList();
  }

  Future<void> createBook(BookModel book) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newBook = book.copyWith(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _books.add(newBook);
  }

  Future<void> updateBook(BookModel book) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book.copyWith(updatedAt: DateTime.now());
    }
  }

  Future<void> deleteBook(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _books.removeWhere((b) => b.id == bookId);
  }

  Stream<List<BookModel>> searchBooks(String query) async* {
    final results = _books
        .where((b) =>
            b.title.toLowerCase().contains(query.toLowerCase()) ||
            b.author.toLowerCase().contains(query.toLowerCase()))
        .toList();
    yield results;
  }
}
