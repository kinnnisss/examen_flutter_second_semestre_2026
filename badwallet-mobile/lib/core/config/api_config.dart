/// Configuration API centralisée de BadWallet.
///
/// L'URL de base de l'API est définie UNIQUEMENT ici. Aucun service métier ne
/// doit coder en dur `localhost` ou une adresse IP : tout passe par
/// [ApiConfig.baseUrl].
///
/// ─────────────────────────────────────────────────────────────────────────
///  COMMENT CHANGER L'URL
/// ─────────────────────────────────────────────────────────────────────────
///  • Émulateur Android  -> http://10.0.2.2:8080   (valeur par défaut)
///  • Simulateur iOS     -> http://127.0.0.1:8080
///  • Téléphone physique  -> http://[IP_LOCALE_DU_PC]:8080
///
///  Deux façons de surcharger l'URL :
///
///  1) Au build / run (recommandé, rien à recompiler manuellement) :
///        flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
///
///  2) En modifiant la constante [_defaultBaseUrl] ci-dessous.
class ApiConfig {
  const ApiConfig._();

  /// URL utilisée par défaut sur émulateur Android.
  /// 10.0.2.2 est l'alias de la machine hôte (votre PC) depuis l'émulateur.
  static const String _defaultBaseUrl = 'http://10.0.2.2:8080';

  /// URL de base effective.
  ///
  /// Si `--dart-define=API_BASE_URL=...` est fourni, il est prioritaire.
  /// Sinon on retombe sur [_defaultBaseUrl] (émulateur Android).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Préfixe commun des endpoints REST.
  static const String apiPrefix = '/api';

  /// Timeouts réseau.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
