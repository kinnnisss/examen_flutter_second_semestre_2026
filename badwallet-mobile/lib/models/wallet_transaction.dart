/// Type de transaction, miroir de l'enum `TransactionType` du backend.
enum TransactionType {
  deposit,
  withdrawal,
  transfer,
  billPayment,
  unknown;

  static TransactionType fromApi(String? raw) {
    switch (raw) {
      case 'DEPOSIT':
        return TransactionType.deposit;
      case 'WITHDRAWAL':
        return TransactionType.withdrawal;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'BILL_PAYMENT':
        return TransactionType.billPayment;
      default:
        return TransactionType.unknown;
    }
  }

  /// Libellé français pour l'UI.
  String get label {
    switch (this) {
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.billPayment:
        return 'Paiement facture';
      case TransactionType.unknown:
        return 'Transaction';
    }
  }

  /// `true` si la transaction augmente le solde (entrée d'argent).
  bool get isCredit => this == TransactionType.deposit;
}

/// Modèle `WalletTransaction`, miroir du `TransactionResponse` du backend.
///
/// Réponse réelle (GET /api/wallets/{phoneNumber}/transactions) — liste :
/// ```json
/// [
///   {
///     "id": 10,
///     "type": "TRANSFER",
///     "amount": 5000.00,
///     "fee": 0.00,
///     "currency": "XOF",
///     "paymentMethod": null,
///     "description": "Transfert vers +221770000000",
///     "createdAt": "2026-06-30T12:00:00"
///   }
/// ]
/// ```
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.fee,
    required this.currency,
    this.paymentMethod,
    this.description,
    this.createdAt,
  });

  final int id;
  final TransactionType type;
  final double amount;
  final double fee;
  final String currency;
  final String? paymentMethod;
  final String? description;
  final DateTime? createdAt;

  /// Type brut conservé tel quel pour le débogage / l'affichage avancé.
  String get rawType => type.name;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['id'] as num).toInt(),
      type: TransactionType.fromApi(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      paymentMethod: json['paymentMethod'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
