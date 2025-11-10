import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/swap_model.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a swap offer
  Future<String> createSwap(SwapModel swap) async {
    try {
      final docRef = await _firestore.collection('swaps').add(swap.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's swap offers (as sender)
  Stream<List<SwapModel>> getUserSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('senderUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get swap offers for a user (as recipient)
  Stream<List<SwapModel>> getReceivedSwaps(String userId) {
    return _firestore
        .collection('swaps')
        .where('recipientUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get swaps for a specific book
  Stream<List<SwapModel>> getBookSwaps(String bookId) {
    return _firestore
        .collection('swaps')
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get a single swap by ID
  Future<SwapModel?> getSwap(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      if (doc.exists) {
        return SwapModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update swap status
  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.toFirestoreString(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete a swap
  Future<void> deleteSwap(String swapId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all swaps (for admin/debugging)
  Stream<List<SwapModel>> getAllSwaps() {
    return _firestore
        .collection('swaps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
