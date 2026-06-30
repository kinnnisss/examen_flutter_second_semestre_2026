import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Convertit les [DioException] en [ApiException] avec un message en français.
///
/// L'API BadWallet renvoie un corps d'erreur structuré (voir backend
/// `ApiErrorResponse`) :
/// ```json
/// {
///   "timestamp": "2026-06-30T12:00:00",
///   "status": 400,
///   "error": "Bad Request",
///   "message": "Solde insuffisant.",
///   "validationErrors": { "amount": "Le montant doit être > 0." }
/// }
/// ```
class ApiErrorMapper {
  const ApiErrorMapper._();

  static ApiException fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          message:
              'Délai de connexion dépassé. Vérifiez votre réseau et que '
              'l\'API est démarrée.',
          isNetworkError: true,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          message:
              'Impossible de joindre le serveur BadWallet. Vérifiez l\'URL de '
              'l\'API et votre connexion.',
          isNetworkError: true,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Requête annulée.', isNetworkError: true);

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificat de sécurité invalide.',
          isNetworkError: true,
        );

      case DioExceptionType.badResponse:
        return _fromResponse(error.response);
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final int? status = response?.statusCode;
    final dynamic data = response?.data;

    String? message;
    Map<String, String>? validationErrors;

    if (data is Map) {
      final dynamic rawMessage = data['message'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        message = rawMessage;
      }

      final dynamic rawErrors = data['validationErrors'];
      if (rawErrors is Map && rawErrors.isNotEmpty) {
        validationErrors = rawErrors.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    }

    message ??= _defaultMessageFor(status);

    return ApiException(
      message: message,
      statusCode: status,
      validationErrors: validationErrors,
    );
  }

  static String _defaultMessageFor(int? status) {
    switch (status) {
      case 400:
        return 'Requête invalide.';
      case 401:
        return 'Authentification requise.';
      case 403:
        return 'Accès refusé.';
      case 404:
        return 'Ressource introuvable.';
      case 500:
        return 'Une erreur interne est survenue sur le serveur.';
      default:
        return 'Une erreur est survenue (code ${status ?? 'inconnu'}).';
    }
  }
}
