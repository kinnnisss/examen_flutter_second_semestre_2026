import 'package:flutter/foundation.dart';

import '../core/utils/error_messages.dart';
import '../models/transfer_result.dart';
import '../services/wallet_service.dart';

class TransfersProvider extends ChangeNotifier {
  TransfersProvider(this._walletService);

  final WalletService _walletService;

  bool _isLoading = false;
  String? _error;
  TransferResult? _lastResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  TransferResult? get lastResult => _lastResult;

  Future<bool> transfer({
    required String senderPhone,
    required String receiverPhone,
    required int amount,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastResult = await _walletService.transfer(
        senderPhone: senderPhone,
        receiverPhone: receiverPhone,
        amount: amount,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = ErrorMessages.from(e);
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _lastResult = null;
    notifyListeners();
  }
}
