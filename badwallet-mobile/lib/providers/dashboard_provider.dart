import 'package:flutter/foundation.dart';

import '../core/utils/error_messages.dart';
import '../models/balance_response.dart';
import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';

/// État du tableau de bord : solde + dernières transactions.
///
/// Les données proviennent des endpoints réels via [WalletService]. La méthode
/// [refresh] est appelée à l'ouverture du Dashboard et lors du pull-to-refresh,
/// ce qui actualise l'UI via `notifyListeners` (sans redémarrer l'app).
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

  /// Les 5 transactions les plus récentes (l'API renvoie déjà l'historique
  /// trié du plus récent au plus ancien).
  List<WalletTransaction> get recentTransactions =>
      _transactions.take(5).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _balance != null;

  /// Charge / recharge le solde et l'historique pour le [phone] donné.
  Future<void> refresh(String phone) async {
    _phone = phone;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Les deux appels en parallèle pour un rafraîchissement plus rapide.
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

  /// Recharge avec le dernier numéro connu (utile après un retour d'écran).
  Future<void> reload() async {
    if (_phone != null) {
      await refresh(_phone!);
    }
  }

  /// Réinitialise l'état (à la déconnexion).
  void reset() {
    _balance = null;
    _transactions = const [];
    _error = null;
    _isLoading = false;
    _phone = null;
    notifyListeners();
  }
}
