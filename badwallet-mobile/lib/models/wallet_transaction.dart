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
}

enum TransactionDirection { credit, debit, neutral }
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

  /// Sens de la transaction, déduit uniquement de données fiables du backend.
  ///
  ///  • DEPOSIT                       -> crédit (vert)
  ///  • WITHDRAWAL / BILL_PAYMENT     -> débit (rouge)
  ///  • TRANSFER                      -> selon la description :
  ///        "Transfert reçu..."   -> crédit
  ///        "Transfert envoyé..." -> débit
  ///        sinon                 -> neutre (on ne devine pas)
  TransactionDirection get direction {
    switch (type) {
      case TransactionType.deposit:
        return TransactionDirection.credit;
      case TransactionType.withdrawal:
      case TransactionType.billPayment:
        return TransactionDirection.debit;
      case TransactionType.transfer:
        final d = (description ?? '').toLowerCase();
        if (d.contains('reçu') || d.contains('recu')) {
          return TransactionDirection.credit;
        }
        if (d.contains('envoyé') || d.contains('envoye')) {
          return TransactionDirection.debit;
        }
        return TransactionDirection.neutral;
      case TransactionType.unknown:
        return TransactionDirection.neutral;
    }
  }

  /// Libellé affiché, précisant le sens d'un transfert quand il est connu.
  String get displayLabel {
    if (type == TransactionType.transfer) {
      switch (direction) {
        case TransactionDirection.credit:
          return 'Transfert reçu';
        case TransactionDirection.debit:
          return 'Transfert envoyé';
        case TransactionDirection.neutral:
          return 'Transfert';
      }
    }
    return type.label;
  }

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
