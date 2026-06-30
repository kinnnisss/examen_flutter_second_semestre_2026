class TransferResult {
  const TransferResult({
    required this.senderTransactionId,
    required this.receiverTransactionId,
    required this.senderPhone,
    required this.receiverPhone,
    required this.transferredAmount,
    required this.senderNewBalance,
    required this.receiverNewBalance,
    required this.currency,
    this.createdAt,
  });

  final int senderTransactionId;
  final int receiverTransactionId;
  final String senderPhone;
  final String receiverPhone;
  final double transferredAmount;
  final double senderNewBalance;
  final double receiverNewBalance;
  final String currency;
  final DateTime? createdAt;

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      senderTransactionId: (json['senderTransactionId'] as num).toInt(),
      receiverTransactionId: (json['receiverTransactionId'] as num).toInt(),
      senderPhone: json['senderPhone'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      transferredAmount: (json['transferredAmount'] as num?)?.toDouble() ?? 0,
      senderNewBalance: (json['senderNewBalance'] as num?)?.toDouble() ?? 0,
      receiverNewBalance: (json['receiverNewBalance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
