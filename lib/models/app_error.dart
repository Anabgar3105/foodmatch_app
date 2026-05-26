/// Represents an application error with user-friendly and technical messages.
///
/// This class encapsulates error information throughout the application,
/// allowing for consistent error handling and user communication.
///
/// Properties:
/// - [code]: Error code from backend or system
/// - [technicalMessage]: Detailed technical error information for debugging
/// - [userMessage]: Human-readable message for display to users
/// - [httpStatusCode]: HTTP status code if applicable
/// - [isNetworkError]: True if error is due to network connectivity
/// - [isTimeoutError]: True if error is due to request timeout
/// - [isAuthError]: True if error is related to authentication/authorization
/// - [isImageError]: True if error is related to image upload/processing
class AppError {
  /// Error code from API or internal system
  final String? code;

  /// Technical message for debugging purposes
  final String? technicalMessage;

  /// User-friendly message for display in UI
  final String userMessage;

  /// HTTP status code if this is an API error
  final int? httpStatusCode;

  /// Whether the error is due to network connectivity issues
  final bool isNetworkError;

  /// Whether the error is due to request timeout
  final bool isTimeoutError;

  /// Whether the error is related to authentication/authorization
  final bool isAuthError;

  /// Whether the error is related to image operations
  final bool isImageError;

  /// Creates an [AppError] instance.
  ///
  /// The [userMessage] parameter is required.
  /// Other parameters are optional and default to false/null.
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

  /// Returns the user-friendly message when converting to string.
  @override
  String toString() => userMessage;
}
