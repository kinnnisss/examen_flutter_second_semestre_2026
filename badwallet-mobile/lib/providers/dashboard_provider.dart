import 'package:flutter/foundation.dart';

import '../core/utils/error_messages.dart';
import '../models/balance_response.dart';
import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._walletService);

  final WalletService _walletService;

  BalanceResponse? _balance;
  List<WalletTransaction> _transactions = const [];
  bool _isLoading = false;
  String? _error;
  String? _phone;

  BalanceResponse? get balance => _balance;
  List<WalletTransaction> get transactions => _transactions;

  List<WalletTransaction> get recentTransactions =>
      _transactions.take(5).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _balance != null;

  Future<void> refresh(String phone) async {
    _phone = phone;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final results = await Future.wait([
        _walletService.getBalance(phone),
        _walletService.getTransactions(phone),
      ]);

      _balance = results[0] as BalanceResponse;
      _transactions = results[1] as List<WalletTransaction>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorMessages.from(e);
      notifyListeners();
    }
  }

  Future<void> reload() async {
    if (_phone != null) {
      await refresh(_phone!);
    }
  }

  void reset() {
    _balance = null;
    _transactions = const [];
    _error = null;
    _isLoading = false;
    _phone = null;
    notifyListeners();
  }
}
