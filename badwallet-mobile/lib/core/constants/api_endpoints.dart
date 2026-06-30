import '../config/api_config.dart';

/// Chemins relatifs des endpoints exposés par BadWallet API.
///
/// Tous les chemins sont relatifs à [ApiConfig.baseUrl] (la baseUrl est gérée
/// par Dio). On centralise ici pour éviter toute duplication de chaîne.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String _wallets = '${ApiConfig.apiPrefix}/wallets';
  static const String _external = '${ApiConfig.apiPrefix}/external';

  // ── Wallets ───────────────────────────────────────────────────────────
  /// POST   /api/wallets                 -> création
  /// GET    /api/wallets?page=&size=     -> liste paginée
  static const String wallets = _wallets;

  /// GET    /api/wallets/{phoneNumber}
  static String walletByPhone(String phoneNumber) => '$_wallets/$phoneNumber';

  /// GET    /api/wallets/{phoneNumber}/balance
  static String walletBalance(String phoneNumber) =>
      '$_wallets/$phoneNumber/balance';

  /// GET    /api/wallets/{phoneNumber}/transactions
  static String walletTransactions(String phoneNumber) =>
      '$_wallets/$phoneNumber/transactions';

  /// POST   /api/wallets/{walletId}/deposit
  static String deposit(int walletId) => '$_wallets/$walletId/deposit';

  /// POST   /api/wallets/withdraw
  static const String withdraw = '$_wallets/withdraw';

  /// POST   /api/wallets/transfer
  static const String transfer = '$_wallets/transfer';

  // ── Factures externes (bills) ─────────────────────────────────────────
  /// GET /api/external/factures/{walletCode}/current?unite=
  static String currentFactures(String walletCode) =>
      '$_external/factures/$walletCode/current';

  /// GET /api/external/factures/{walletCode}/periode?debut=&fin=
  static String facturesByPeriod(String walletCode) =>
      '$_external/factures/$walletCode/periode';
}
