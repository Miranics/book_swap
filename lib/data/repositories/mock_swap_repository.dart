import '../../domain/models/swap_model.dart';

/// Mock Swap Repository for web demo
class MockSwapRepository {
  static final MockSwapRepository _instance = MockSwapRepository._internal();
  
  factory MockSwapRepository() {
    return _instance;
  }

  MockSwapRepository._internal();

  final List<SwapModel> _swaps = [];

  Stream<List<SwapModel>> getUserSwaps(String userId) async* {
    yield _swaps.where((s) => s.senderUserId == userId).toList();
  }

  Stream<List<SwapModel>> getReceivedSwaps(String userId) async* {
    yield _swaps.where((s) => s.recipientUserId == userId).toList();
  }

  Future<void> createSwap(SwapModel swap) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newSwap = swap.copyWith(
      id: 'swap_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _swaps.add(newSwap);
  }

  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _swaps.indexWhere((s) => s.id == swapId);
    if (index != -1) {
      _swaps[index] = _swaps[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteSwap(String swapId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _swaps.removeWhere((s) => s.id == swapId);
  }
}
