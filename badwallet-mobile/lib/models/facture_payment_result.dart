class FacturePaymentResult {
  const FacturePaymentResult({
    required this.walletCode,
    required this.serviceName,
    required this.paidFactureReferences,
    required this.totalPaid,
    this.paidAt,
  });

  final String walletCode;
  final String serviceName;
  final List<String> paidFactureReferences;
  final double totalPaid;
  final DateTime? paidAt;

  factory FacturePaymentResult.fromJson(Map<String, dynamic> json) {
    final refs = (json['paidFactureReferences'] as List<dynamic>? ?? const []);
    return FacturePaymentResult(
      walletCode: json['walletCode'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      paidFactureReferences: refs.map((e) => e.toString()).toList(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(json['paidAt'] as String)
          : null,
    );
  }
}
