import '../network/api_exception.dart';

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
