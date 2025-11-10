import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _createThreadKey(String userId1, String userId2) {
    final participants = [userId1, userId2]..sort();
    return participants.join('_');
  }

  // Create or get chat thread
  Future<String> getOrCreateChatThread({
    required String userId1,
    required String userId1Name,
    required String userId2,
    required String userId2Name,
    String? swapId,
  }) async {
    try {
      final threadKey = _createThreadKey(userId1, userId2);

      // Try to find existing chat thread
      final querySnapshot = await _firestore
          .collection('chatThreads')
          .where('threadKey', isEqualTo: threadKey)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      final now = DateTime.now();

      // Create new chat thread if it doesn't exist
      final chatThread = ChatThread(
        id: '', // Will be set by Firestore
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

      final docRef = await _firestore
          .collection('chatThreads')
          .add(chatThread.toMap());

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String threadId,
    required ChatMessage message,
  }) async {
    try {
      // Add message to subcollection
      await _firestore
          .collection('chatThreads')
          .doc(threadId)
          .collection('messages')
          .add(message.toMap());

      // Update thread's last message
      await _firestore.collection('chatThreads').doc(threadId).update({
        'lastMessage': message.message,
        'lastMessageAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get messages from a thread
  Stream<List<ChatMessage>> getMessages(String threadId) {
    return _firestore
        .collection('chatThreads')
        .doc(threadId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user's chat threads
  Stream<List<ChatThread>> getUserChatThreads(String userId) {
    return _firestore
        .collection('chatThreads')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatThread.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get a specific chat thread
  Future<ChatThread?> getChatThread(String threadId) async {
    try {
      final doc = await _firestore.collection('chatThreads').doc(threadId).get();
      if (doc.exists) {
        return ChatThread.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Delete a chat thread
  Future<void> deleteChatThread(String threadId) async {
    try {
      // Delete all messages in the thread
      final messagesSnapshot = await _firestore
          .collection('chatThreads')
          .doc(threadId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the thread itself
      await _firestore.collection('chatThreads').doc(threadId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
