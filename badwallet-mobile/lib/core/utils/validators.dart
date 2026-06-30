/// Validateurs de saisie pour BadWallet.
class Validators {
  const Validators._();

  /// Numéro local sénégalais : 9 chiffres commençant par 7
  /// (70/75/76/77/78...). Ex : `771234567`.
  static final RegExp _senegalLocal = RegExp(r'^7[0-8][0-9]{7}$');

  /// Format international accepté par le backend : `+` puis 8 à 15 chiffres.
  static final RegExp _international = RegExp(r'^\+[1-9][0-9]{7,14}$');

  /// Valide un numéro de téléphone tel que saisi par l'utilisateur.
  ///
  /// Accepte :
  ///   • un local sénégalais à 9 chiffres (`77 123 45 67`) ;
  ///   • un numéro international complet (`+221771234567`).
  ///
  /// Retourne `null` si valide, sinon un message d'erreur.
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
