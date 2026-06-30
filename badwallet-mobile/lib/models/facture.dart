enum BillService {
  ism,
  woyafal,
  unknown;

  static BillService fromApi(String? raw) {
    switch (raw) {
      case 'ISM':
        return BillService.ism;
      case 'WOYAFAL':
        return BillService.woyafal;
      default:
        return BillService.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case BillService.ism:
        return 'ISM';
      case BillService.woyafal:
        return 'WOYAFAL';
      case BillService.unknown:
        return '';
    }
  }

  String get label {
    switch (this) {
      case BillService.ism:
        return 'ISM';
      case BillService.woyafal:
        return 'WOYAFAL';
      case BillService.unknown:
        return 'Service';
    }
  }
}

enum BillStatus {
  unpaid,
  paid,
  unknown;

  static BillStatus fromApi(String? raw) {
    switch (raw) {
      case 'UNPAID':
        return BillStatus.unpaid;
      case 'PAID':
        return BillStatus.paid;
      default:
        return BillStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case BillStatus.unpaid:
        return 'Impayée';
      case BillStatus.paid:
        return 'Payée';
      case BillStatus.unknown:
        return 'Inconnu';
    }
  }
}

class Facture {
  const Facture({
    required this.reference,
    required this.walletCode,
    required this.serviceName,
    required this.unite,
    required this.amount,
    required this.status,
    this.billingMonth,
    this.dueDate,
    this.paidAt,
  });

  final String reference;
  final String walletCode;
  final BillService serviceName;
  final String unite;
  final double amount;
  final BillStatus status;
  final DateTime? billingMonth;
  final DateTime? dueDate;
  final DateTime? paidAt;

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      reference: json['reference'] as String? ?? '',
      walletCode: json['walletCode'] as String? ?? '',
      serviceName: BillService.fromApi(json['serviceName'] as String?),
      unite: json['unite'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: BillStatus.fromApi(json['status'] as String?),
      billingMonth: _parseDate(json['billingMonth']),
      dueDate: _parseDate(json['dueDate']),
      paidAt: _parseDate(json['paidAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
