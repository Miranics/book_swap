import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/book_repository.dart';
import '../../domain/models/book_model.dart';
import '../../services/storage_service.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  final StorageService _storageService;

  List<BookModel> _allBooks = [];
  List<BookModel> _userBooks = [];
  BookModel? _selectedBook;
  bool _isLoading = false;
  String? _error;

  BookProvider(this._bookRepository, this._storageService);

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get userBooks => _userBooks;
  BookModel? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to all books
  void listenToAllBooks() {
    _bookRepository.getAllBooks().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
  }

  // Listen to user's books
  void listenToUserBooks(String userId) {
    _bookRepository.getUserBooks(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  // Create a new book
  Future<String> createBook(BookModel book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookId = await _bookRepository.createBook(book);
      _isLoading = false;
      notifyListeners();
      return bookId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> uploadBookCover({
    required XFile file,
    required String userId,
  }) async {
    try {
      return await _storageService.uploadBookCover(
        file: file,
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update a book
  Future<void> updateBook(String bookId, BookModel book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookRepository.updateBook(bookId, book);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete a book
  Future<void> deleteBook(String bookId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookRepository.deleteBook(bookId);
      _userBooks.removeWhere((book) => book.id == bookId);
      _allBooks.removeWhere((book) => book.id == bookId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get a single book
  Future<void> getBook(String bookId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBook = await _bookRepository.getBook(bookId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Search books
  Future<List<BookModel>> searchBooks(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _bookRepository.searchBooks(query);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
