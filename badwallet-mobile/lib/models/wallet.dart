/// Modèle `Wallet`, miroir du `WalletResponse` du backend.
///
/// Réponse réelle (GET /api/wallets/{phoneNumber}) :
/// ```json
/// {
///   "id": 1,
///   "phoneNumber": "+221779998877",
///   "email": "user@example.com",
///   "code": "WALLET01",
///   "currency": "XOF",
///   "balance": 150000.00,
///   "createdAt": "2026-06-30T12:00:00"
/// }
/// ```
class Wallet {
  const Wallet({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.code,
    required this.currency,
    required this.balance,
    this.createdAt,
  });

  final int id;
  final String phoneNumber;
  final String email;
  final String code;
  final String currency;
  final double balance;
  final DateTime? createdAt;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: (json['id'] as num).toInt(),
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String? ?? '',
      code: json['code'] as String? ?? '',
      currency: json['currency'] as String? ?? 'XOF',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'email': email,
    'code': code,
    'currency': currency,
    'balance': balance,
    'createdAt': createdAt?.toIso8601String(),
  };
}
