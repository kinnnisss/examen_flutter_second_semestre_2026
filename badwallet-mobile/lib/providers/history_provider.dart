import 'package:flutter/foundation.dart';

import '../core/utils/error_messages.dart';
import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._walletService);

  final WalletService _walletService;

  List<WalletTransaction> _all = const [];
  bool _isLoading = false;
  String? _error;
  String? _phone;

  TransactionType? _typeFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _all.isNotEmpty;

  TransactionType? get typeFilter => _typeFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get hasActiveFilters =>
      _typeFilter != null || _startDate != null || _endDate != null;

  List<WalletTransaction> get transactions {
    final filtered = _all.where(_matchesFilters).toList()
      ..sort((a, b) {
        final da = a.createdAt;
        final db = b.createdAt;
        if (da == null && db == null) return 0;
        if (da == null) return 1; 
        if (db == null) return -1;
        return db.compareTo(da); 
      });
    return filtered;
  }

  bool _matchesFilters(WalletTransaction t) {
    if (_typeFilter != null && t.type != _typeFilter) return false;

    final date = t.createdAt;
    if (_startDate != null) {
      if (date == null || date.isBefore(_startDate!)) return false;
    }
    if (_endDate != null) {
      final endOfDay = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      if (date == null || date.isAfter(endOfDay)) return false;
    }
    return true;
  }

  Future<void> refresh(String phone) async {
    _phone = phone;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _walletService.getTransactions(phone);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorMessages.from(e);
      notifyListeners();
    }
  }

  Future<void> reload() async {
    if (_phone != null) await refresh(_phone!);
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void resetFilters() {
    _typeFilter = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  void reset() {
    _all = const [];
    _error = null;
    _isLoading = false;
    _phone = null;
    resetFilters();
  }
}
