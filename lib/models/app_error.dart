class AppError {
  final String? code;

  final String? technicalMessage;

  final String userMessage;

  final int? httpStatusCode;

  final bool isNetworkError;

  final bool isTimeoutError;

  final bool isAuthError;

  final bool isImageError;

  AppError({
    this.code,
    this.technicalMessage,
    required this.userMessage,
    this.httpStatusCode,
    this.isNetworkError = false,
    this.isTimeoutError = false,
    this.isAuthError = false,
    this.isImageError = false,
  });

  @override
  String toString() => userMessage;
}
