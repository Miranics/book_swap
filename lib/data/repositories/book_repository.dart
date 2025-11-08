import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new book listing
  Future<String> createBook(BookModel book) async {
    try {
      final docRef = await _firestore.collection('books').add(book.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all books (browse listings)
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user's own books
  Stream<List<BookModel>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get a single book by ID
  Future<BookModel?> getBook(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update a book
  Future<void> updateBook(String bookId, BookModel book) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        ...book.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Search books by title or author
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();

      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
