import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/balance_response.dart';
import '../models/transfer_result.dart';
import '../models/wallet.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  WalletService(this._client);

  final ApiClient _client;

  String _encode(String phone) => Uri.encodeComponent(phone);

  Future<Wallet> getWallet(String phone) async {
    final data = await _client.get(ApiEndpoints.walletByPhone(_encode(phone)));
    return Wallet.fromJson(data as Map<String, dynamic>);
  }

  Future<BalanceResponse> getBalance(String phone) async {
    final data = await _client.get(ApiEndpoints.walletBalance(_encode(phone)));
    return BalanceResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<List<WalletTransaction>> getTransactions(String phone) async {
    final data = await _client.get(
      ApiEndpoints.walletTransactions(_encode(phone)),
    );
    final list = (data as List<dynamic>? ?? const []);
    return list
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransferResult> transfer({
    required String senderPhone,
    required String receiverPhone,
    required int amount,
  }) async {
    final data = await _client.post(
      ApiEndpoints.transfer,
      data: {
        'senderPhone': senderPhone,
        'receiverPhone': receiverPhone,
        'amount': amount,
      },
    );
    return TransferResult.fromJson(data as Map<String, dynamic>);
  }
}
