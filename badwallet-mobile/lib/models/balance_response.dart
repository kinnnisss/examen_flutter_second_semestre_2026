class BalanceResponse {
  const BalanceResponse({
    required this.phoneNumber,
    required this.code,
    required this.currency,
    required this.balance,
  });

  final String phoneNumber;
  final String code;
  final String currency;
  final double balance;

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      code: json['code'] as String? ?? '',
      currency: json['currency'] as String? ?? 'XOF',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
