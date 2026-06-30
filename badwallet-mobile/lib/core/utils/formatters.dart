import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static String xof(num amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 0,
    );
    final formatted = formatter.format(amount).trim();
    return symbol.isEmpty ? formatted : '$formatted $symbol';
  }

  static String xofCompact(num amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat.compact(locale: 'fr_FR');
    final formatted = formatter.format(amount);
    return symbol.isEmpty ? formatted : '$formatted $symbol';
  }

  static String phoneSenegal(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('221') && digits.length == 12) {
      final local = digits.substring(3);
      return '+221 ${_groupSenegalLocal(local)}';
    }

    if (digits.length == 9) {
      final local = _groupSenegalLocal(digits);
      return hasPlus ? '+$local' : local;
    }

    return trimmed;
  }

  static String _groupSenegalLocal(String local) {
    if (local.length != 9) return local;
    return '${local.substring(0, 2)} '
        '${local.substring(2, 5)} '
        '${local.substring(5, 7)} '
        '${local.substring(7, 9)}';
  }

  static String? toApiPhone(String raw, {String defaultIndicatif = '221'}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (hasPlus) return '+$digits';
    if (digits.length == 9) return '+$defaultIndicatif$digits';
    return '+$digits';
  }

  static String date(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'fr_FR').format(date);

  static String dateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'fr_FR').format(date);
}
