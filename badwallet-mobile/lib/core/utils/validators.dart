class Validators {
  const Validators._();

  static final RegExp _senegalLocal = RegExp(r'^7[0-8][0-9]{7}$');

  static final RegExp _international = RegExp(r'^\+[1-9][0-9]{7,14}$');

  static String? phone(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return 'Le numéro de téléphone est obligatoire.';
    }

    final hasPlus = raw.startsWith('+');
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (hasPlus) {
      if (!_international.hasMatch('+$digits')) {
        return 'Numéro international invalide (ex : +221771234567).';
      }
      return null;
    }

    if (!_senegalLocal.hasMatch(digits)) {
      return 'Numéro sénégalais invalide (ex : 77 123 45 67).';
    }
    return null;
  }
}
