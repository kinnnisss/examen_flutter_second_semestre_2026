/// Constantes générales de l'application (espacements, rayons, durées).
class AppConstants {
  const AppConstants._();

  static const String appName = 'BadWallet';

  // Espacements
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Rayons
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusPill = 999;

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);

  // Devise par défaut côté API BadWallet.
  static const String defaultCurrency = 'XOF';

  // Clés de stockage sécurisé.
  static const String storageKeyPhone = 'bw_current_phone';
  static const String storageKeyWalletCode = 'bw_current_wallet_code';
}
