import '../network/api_exception.dart';

/// Transforme une erreur (typiquement [ApiException]) en message affichable.
///
/// Si l'API a renvoyé des erreurs de validation champ par champ, elles sont
/// concaténées de façon lisible.
class ErrorMessages {
  const ErrorMessages._();

  static String from(Object error) {
    if (error is ApiException) {
      if (error.hasValidationErrors) {
        final details = error.validationErrors!.values.join('\n');
        return '${error.message}\n$details';
      }
      return error.message;
    }
    return 'Une erreur inattendue est survenue.';
  }
}
