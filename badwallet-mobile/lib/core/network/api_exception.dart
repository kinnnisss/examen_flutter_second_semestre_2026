class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.validationErrors,
    this.isNetworkError = false,
  });

  final String message;

  final int? statusCode;

  final Map<String, String>? validationErrors;

  final bool isNetworkError;

  bool get isNotFound => statusCode == 404;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => (statusCode ?? 0) >= 500;
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
