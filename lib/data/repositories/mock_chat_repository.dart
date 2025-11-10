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
    yield _threads.where((t) => t.participants.contains(userId)).toList();
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

    final participants = [userId1, userId2]..sort();
    final threadKey = participants.join('_');

    // Check if thread already exists
    for (final t in _threads) {
      if (t.threadKey == threadKey) {
        return t.id;
      }
    }

    // Create new thread
    final threadId = 'thread_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final thread = ChatThread(
      id: threadId,
      userId1: userId1,
      userId1Name: userId1Name,
      userId2: userId2,
      userId2Name: userId2Name,
      threadKey: threadKey,
      participants: [userId1, userId2],
      swapId: swapId,
      createdAt: now,
      lastMessage: 'Chat started',
      lastMessageAt: now,
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

    final msgWithId = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: message.senderId,
      senderName: message.senderName,
      recipientId: message.recipientId,
      message: message.message,
      timestamp: DateTime.now(),
      isRead: message.isRead,
    );

    _messages[threadId]!.add(msgWithId);

    // Update thread's last message
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      final oldThread = _threads[threadIndex];
      _threads[threadIndex] = ChatThread(
        id: oldThread.id,
        userId1: oldThread.userId1,
        userId1Name: oldThread.userId1Name,
        userId2: oldThread.userId2,
        userId2Name: oldThread.userId2Name,
        threadKey: oldThread.threadKey,
        participants: oldThread.participants,
        swapId: oldThread.swapId,
        createdAt: oldThread.createdAt,
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
