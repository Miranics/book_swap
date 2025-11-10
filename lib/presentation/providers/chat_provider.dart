import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;

  List<ChatThread> _chatThreads = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  final Map<String, UserModel> _userProfiles = {};
  bool _isDisposed = false;

  ChatProvider(this._chatRepository, this._authRepository);

  List<ChatThread> get chatThreads => _chatThreads;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, UserModel> get userProfiles => Map.unmodifiable(_userProfiles);

  // Listen to user's chat threads
  void listenToUserChats(String userId) {
    _chatRepository.getUserChatThreads(userId).listen((threads) {
      _chatThreads = List.of(threads)
        ..sort((a, b) {
          final aTime = a.lastMessageAt ?? a.createdAt;
          final bTime = b.lastMessageAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
      for (final thread in _chatThreads) {
        _loadUserProfile(thread.userId1);
        _loadUserProfile(thread.userId2);
      }
      notifyListeners();
    });
  }

  // Listen to messages in a thread
  void listenToMessages(String threadId) {
    _chatRepository.getMessages(threadId).listen((messages) {
      _messages = messages;
      for (final message in messages) {
        _loadUserProfile(message.senderId);
      }
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
      _loadUserProfile(userId1);
      _loadUserProfile(userId2);
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

  Future<void> markThreadAsRead({
    required String threadId,
    required String userId,
  }) async {
    try {
      await _chatRepository.markThreadAsRead(threadId: threadId, userId: userId);

      final threadIndex = _chatThreads.indexWhere((thread) => thread.id == threadId);
      if (threadIndex != -1) {
        final currentThread = _chatThreads[threadIndex];
        final updatedThread = currentThread.copyWith(
          unreadCounts: {
            ...currentThread.unreadCounts,
            userId: 0,
          },
        );
        _chatThreads[threadIndex] = updatedThread;
      }

      _messages = _messages
          .map((chatMessage) => chatMessage.recipientId == userId && !chatMessage.isRead
              ? chatMessage.copyWith(isRead: true)
              : chatMessage)
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void cacheUserProfile(UserModel user) {
    final existing = _userProfiles[user.id];
    if (existing != null &&
        existing.profileImageUrl == user.profileImageUrl &&
        existing.displayName == user.displayName) {
      return;
    }
    _userProfiles[user.id] = user;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _loadUserProfile(String userId) {
    if (userId.isEmpty || _userProfiles.containsKey(userId)) {
      return;
    }
    _authRepository.getUserProfileById(userId).then((profile) {
      if (profile != null && !_isDisposed) {
        _userProfiles[userId] = profile;
        notifyListeners();
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
