import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/balance_response.dart';
import '../models/wallet.dart';
import '../models/wallet_transaction.dart';

/// Service d'accès aux endpoints "wallet" de BadWallet API.
///
/// Toutes les URL passent par [ApiEndpoints] / [ApiClient] : aucune adresse
/// n'est codée en dur ici. Le service ne fait que mapper les réponses JSON
/// réelles vers les modèles Dart.
class WalletService {
  WalletService(this._client);

  final ApiClient _client;

  /// Le numéro de téléphone (format `+221...`) sert d'identifiant et contient
  /// un `+` : on l'encode pour rester valide dans le chemin de l'URL.
  String _encode(String phone) => Uri.encodeComponent(phone);

  /// GET /api/wallets/{phone}
  ///
  /// Utilisé à la connexion pour vérifier que le wallet existe.
  /// Lève une `ApiException` (404) si le wallet est introuvable.
  Future<Wallet> getWallet(String phone) async {
    final data = await _client.get(ApiEndpoints.walletByPhone(_encode(phone)));
    return Wallet.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/wallets/{phone}/balance
  Future<BalanceResponse> getBalance(String phone) async {
    final data = await _client.get(ApiEndpoints.walletBalance(_encode(phone)));
    return BalanceResponse.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/wallets/{phone}/transactions
  ///
  /// L'API renvoie une **liste** (non paginée) de transactions.
  Future<List<WalletTransaction>> getTransactions(String phone) async {
    final data = await _client.get(
      ApiEndpoints.walletTransactions(_encode(phone)),
    );
    final list = (data as List<dynamic>? ?? const []);
    return list
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
