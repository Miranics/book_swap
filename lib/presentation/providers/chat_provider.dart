import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  List<ChatThread> _chatThreads = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._chatRepository);

  List<ChatThread> get chatThreads => _chatThreads;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to user's chat threads
  void listenToUserChats(String userId) {
    _chatRepository.getUserChatThreads(userId).listen((threads) {
      _chatThreads = threads;
      notifyListeners();
    });
  }

  // Listen to messages in a thread
  void listenToMessages(String threadId) {
    _chatRepository.getMessages(threadId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  // Get or create chat thread
  Future<String> getOrCreateChatThread({
    required String userId1,
    required String userId1Name,
    required String userId2,
    required String userId2Name,
    String? swapId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final threadId = await _chatRepository.getOrCreateChatThread(
        userId1: userId1,
        userId1Name: userId1Name,
        userId2: userId2,
        userId2Name: userId2Name,
        swapId: swapId,
      );
      _isLoading = false;
      notifyListeners();
      return threadId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String threadId,
    required ChatMessage message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _chatRepository.sendMessage(threadId: threadId, message: message);
      _isLoading = false;
      notifyListeners();
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
