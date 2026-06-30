import '../config/api_config.dart';

class ApiEndpoints {
  const ApiEndpoints._();

  static const String _wallets = '${ApiConfig.apiPrefix}/wallets';
  static const String _external = '${ApiConfig.apiPrefix}/external';

  static const String wallets = _wallets;

  static String walletByPhone(String phoneNumber) => '$_wallets/$phoneNumber';

  static String walletBalance(String phoneNumber) =>
      '$_wallets/$phoneNumber/balance';

  static String walletTransactions(String phoneNumber) =>
      '$_wallets/$phoneNumber/transactions';

  static String deposit(int walletId) => '$_wallets/$walletId/deposit';

  static const String withdraw = '$_wallets/withdraw';

  static const String transfer = '$_wallets/transfer';

  static String currentFactures(String walletCode) =>
      '$_external/factures/$walletCode/current';

  static String facturesByPeriod(String walletCode) =>
      '$_external/factures/$walletCode/periode';
}
