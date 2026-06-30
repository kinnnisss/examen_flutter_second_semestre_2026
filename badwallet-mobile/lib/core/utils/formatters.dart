import 'package:intl/intl.dart';

/// Utilitaires de formatage pour BadWallet (montants, téléphone, dates).
class Formatters {
  const Formatters._();

  /// Formate un montant en francs CFA (XOF) à la sénégalaise.
  ///
  /// Exemple : `150000` -> `150 000 FCFA`.
  /// Le XOF n'a pas de sous-unité : on n'affiche pas de décimales.
  static String xof(num amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 0,
    );
    final formatted = formatter.format(amount).trim();
    return symbol.isEmpty ? formatted : '$formatted $symbol';
  }

  /// Variante compacte pour les grands montants : `1,5 M FCFA`.
  static String xofCompact(num amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat.compact(locale: 'fr_FR');
    final formatted = formatter.format(amount);
    return symbol.isEmpty ? formatted : '$formatted $symbol';
  }

  /// Met en forme un numéro de téléphone sénégalais pour l'affichage.
  ///
  /// L'API attend un format international strict (`+221779998877`). Cette
  /// méthode est purement cosmétique :
  ///   `+221779998877` -> `+221 77 999 88 77`
  ///   `779998877`     -> `77 999 88 77`
  static String phoneSenegal(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');

    // Indicatif Sénégal +221 suivi de 9 chiffres.
    if (digits.startsWith('221') && digits.length == 12) {
      final local = digits.substring(3); // 9 chiffres
      return '+221 ${_groupSenegalLocal(local)}';
    }

    // Numéro local à 9 chiffres (77XXXXXXX).
    if (digits.length == 9) {
      final local = _groupSenegalLocal(digits);
      return hasPlus ? '+$local' : local;
    }

    // Format inconnu : on renvoie tel quel.
    return trimmed;
  }

  /// Découpe un local sénégalais à 9 chiffres en `77 999 88 77`.
  static String _groupSenegalLocal(String local) {
    if (local.length != 9) return local;
    return '${local.substring(0, 2)} '
        '${local.substring(2, 5)} '
        '${local.substring(5, 7)} '
        '${local.substring(7, 9)}';
  }

  /// Normalise une saisie utilisateur vers le format API `+221XXXXXXXXX`.
  ///
  /// Renvoie `null` si le numéro ne peut pas être interprété de façon fiable.
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

  /// Date courte : `30/06/2026`.
  static String date(DateTime date) =>
      DateFormat('dd/MM/yyyy', 'fr_FR').format(date);

  /// Date + heure : `30/06/2026 14:05`.
  static String dateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);

  /// Mois lisible : `juin 2026`.
  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'fr_FR').format(date);
}
