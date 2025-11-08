import '../../domain/models/chat_model.dart';

/// Mock Chat Repository for web demo
class MockChatRepository {
  static final MockChatRepository _instance = MockChatRepository._internal();
  
  factory MockChatRepository() {
    return _instance;
  }

  MockChatRepository._internal();

  final List<ChatThread> _threads = [];
  final Map<String, List<ChatMessage>> _messages = {};

  Stream<List<ChatThread>> getUserChatThreads(String userId) async* {
    yield _threads
        .where((t) => t.userId1 == userId || t.userId2 == userId)
        .toList();
  }

  Stream<List<ChatMessage>> getMessages(String threadId) async* {
    yield _messages[threadId] ?? [];
  }

  Future<String> getOrCreateChatThread({
    required String userId1,
    required String userId1Name,
    required String userId2,
    required String userId2Name,
    String? swapId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Check if thread already exists
    final existing = _threads.firstWhere(
      (t) => (t.userId1 == userId1 && t.userId2 == userId2) ||
             (t.userId1 == userId2 && t.userId2 == userId1),
      orElse: () => ChatThread(
        id: '',
        userId1: '',
        userId2: '',
      ),
    );

    if (existing.id.isNotEmpty) {
      return existing.id;
    }

    // Create new thread
    final threadId = 'thread_${DateTime.now().millisecondsSinceEpoch}';
    final thread = ChatThread(
      id: threadId,
      userId1: userId1,
      userId1Name: userId1Name,
      userId2: userId2,
      userId2Name: userId2Name,
      swapId: swapId,
      lastMessage: 'Chat started',
      lastMessageAt: DateTime.now(),
    );

    _threads.add(thread);
    _messages[threadId] = [];
    return threadId;
  }

  Future<void> sendMessage({
    required String threadId,
    required ChatMessage message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!_messages.containsKey(threadId)) {
      _messages[threadId] = [];
    }

    final msgWithId = message.copyWith(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
    );

    _messages[threadId]!.add(msgWithId);

    // Update thread's last message
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      _threads[threadIndex] = _threads[threadIndex].copyWith(
        lastMessage: message.message,
        lastMessageAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteChatThread(String threadId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _threads.removeWhere((t) => t.id == threadId);
    _messages.remove(threadId);
  }
}
