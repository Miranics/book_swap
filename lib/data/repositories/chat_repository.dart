import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get chat thread
  Future<String> getOrCreateChatThread({
    required String userId1,
    required String userId1Name,
    required String userId2,
    required String userId2Name,
    String? swapId,
  }) async {
    try {
      // Try to find existing chat thread
      final querySnapshot = await _firestore
          .collection('chatThreads')
          .where('userId1', isEqualTo: userId1)
          .where('userId2', isEqualTo: userId2)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      // Create new chat thread if doesn't exist
      final chatThread = ChatThread(
        id: '', // Will be set by Firestore
        userId1: userId1,
        userId1Name: userId1Name,
        userId2: userId2,
        userId2Name: userId2Name,
        swapId: swapId,
        createdAt: DateTime.now(),
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
        .where('userId1', isEqualTo: userId)
        .orderBy('lastMessageAt', descending: true)
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
