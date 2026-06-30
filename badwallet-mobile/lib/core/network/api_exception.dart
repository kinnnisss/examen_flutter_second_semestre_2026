/// Exception métier unifiée renvoyée par la couche réseau.
///
/// Toute erreur Dio (timeout, 400, 404, 500, perte réseau...) est convertie en
/// [ApiException] par [ApiErrorMapper], pour que l'UI ait toujours un message
/// lisible et, si disponible, les erreurs de validation champ par champ.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.validationErrors,
    this.isNetworkError = false,
  });

  /// Message lisible par l'utilisateur (français).
  final String message;

  /// Code HTTP si la requête a abouti (400, 404, 500...). `null` si réseau.
  final int? statusCode;

  /// Erreurs de validation `champ -> message` renvoyées par l'API (HTTP 400).
  final Map<String, String>? validationErrors;

  /// `true` si l'erreur provient d'un problème de connexion (pas de réponse).
  final bool isNetworkError;

  bool get isNotFound => statusCode == 404;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => (statusCode ?? 0) >= 500;
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
