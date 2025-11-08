import 'package:flutter/material.dart';
import '../../data/repositories/swap_repository.dart';
import '../../domain/models/swap_model.dart';

class SwapProvider extends ChangeNotifier {
  final SwapRepository _swapRepository;

  List<SwapModel> _userSwaps = [];
  List<SwapModel> _receivedSwaps = [];
  bool _isLoading = false;
  String? _error;

  SwapProvider(this._swapRepository);

  List<SwapModel> get userSwaps => _userSwaps;
  List<SwapModel> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to user's swaps (as sender)
  void listenToUserSwaps(String userId) {
    _swapRepository.getUserSwaps(userId).listen((swaps) {
      _userSwaps = swaps;
      notifyListeners();
    });
  }

  // Listen to received swaps (as recipient)
  void listenToReceivedSwaps(String userId) {
    _swapRepository.getReceivedSwaps(userId).listen((swaps) {
      _receivedSwaps = swaps;
      notifyListeners();
    });
  }

  // Create a swap offer
  Future<String> createSwap(SwapModel swap) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final swapId = await _swapRepository.createSwap(swap);
      _isLoading = false;
      notifyListeners();
      return swapId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update swap status
  Future<void> updateSwapStatus(String swapId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _swapRepository.updateSwapStatus(swapId, status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete a swap
  Future<void> deleteSwap(String swapId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _swapRepository.deleteSwap(swapId);
      _userSwaps.removeWhere((swap) => swap.id == swapId);
      _receivedSwaps.removeWhere((swap) => swap.id == swapId);
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
