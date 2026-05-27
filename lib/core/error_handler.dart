import 'package:flutter/foundation.dart';
import 'package:foodmatch_app/models/app_error.dart';

/// Manejador centralizado de errores para la aplicación.
///
/// Este servicio convierte errores técnicos en mensajes amigables
/// para el usuario final. Mapea códigos de error del backend a
/// mensajes descriptivos y acciones sugeridas.
class ErrorHandler {
  /// Mapeo de códigos de error del backend a mensajes amigables
  static const Map<String, String> _errorMessages = {
    // Errores de validación
    'INVALID_INPUT':
        'Los datos proporcionados no son válidos. Revisa e intenta de nuevo.',
    'MISSING_FIELD':
        'Falta completar algunos campos. Verifica que todo esté lleno.',
    'INVALID_EMAIL':
        'El correo electrónico no parece ser válido. Verifica el formato.',
    'WEAK_PASSWORD':
        'La contraseña no es lo suficientemente segura. Debe tener al menos 8 caracteres, una mayúscula y un número.',

    // Errores de autenticación
    'INVALID_CREDENTIALS':
        'Usuario o contraseña incorrectos. Intenta nuevamente.',
    'TOKEN_EXPIRED':
        'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.',
    'TOKEN_INVALID': 'Hay un problema con tu sesión. Inicia sesión de nuevo.',

    // Errores de autorización
    'INSUFFICIENT_PERMISSIONS': 'No tienes permiso para realizar esta acción.',

    // Errores de recursos
    'RESOURCE_NOT_FOUND':
        'El recurso que buscas no existe o ha sido eliminado.',
    'USER_NOT_FOUND': 'El usuario no existe.',
    'RECIPE_NOT_FOUND': 'La receta que buscas no existe o ha sido eliminada.',

    // Errores de conflicto
    'DUPLICATE_EMAIL': 'Este correo electrónico ya está registrado. Usa otro.',
    'DUPLICATE_USERNAME': 'Este nombre de usuario ya está en uso. Elige otro.',
    'RESOURCE_ALREADY_EXISTS': 'Este recurso ya existe.',

    // Errores de imagen
    'IMAGE_UPLOAD_FAILED':
        'Hubo un problema al subir la imagen. Intenta de nuevo.',
    'INVALID_IMAGE_FORMAT':
        'El formato de la imagen no es válido. Usa JPG o PNG.',
    'IMAGE_TOO_LARGE': 'La imagen es demasiado grande. Elige una más pequeña.',

    // Errores del servidor
    'INTERNAL_SERVER_ERROR':
        'Algo salió mal en nuestros servidores. Intenta más tarde.',
    'EXTERNAL_SERVICE_ERROR':
        'Hay problemas para conectar con un servicio. Intenta más tarde.',
  };

  static const Map<int, String> _httpErrorMessages = {
    400: 'Los datos enviados no son válidos. Verifica e intenta de nuevo.',
    401: 'Tu sesión ha expirado. Inicia sesión de nuevo.',
    403: 'No tienes permisos para hacer esto.',
    404: 'Lo que buscas no existe o ha sido eliminado.',
    409: 'Ese recurso ya existe. Intenta con datos diferentes.',
    500: 'Algo salió mal en nuestros servidores. Intentalo de nuevo más tarde.',
    503: 'El servidor está en mantenimiento. Intenta de nuevo en unos minutos.',
  };

  /// Converts generic errors to user-friendly [AppError].
  ///
  /// Detects error type (network, timeout, JSON parsing, etc.)
  /// and provides appropriate user message and flags.
  ///
  /// Parameters:
  ///   - [error]: The error to handle
  ///
  /// Returns: [AppError] with user-friendly message
  static AppError handle(dynamic error) {
    debugPrint('ErrorHandler - Error capturado: $error');

    if (error.toString().contains('Connection refused') ||
        error.toString().contains('Network is unreachable') ||
        error.toString().contains('Failed host lookup')) {
      return AppError(
        userMessage:
            'No hay conexión a internet. Verifica tu conexión y intenta de nuevo.',
        technicalMessage: error.toString(),
        isNetworkError: true,
      );
    }

    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timed out')) {
      return AppError(
        userMessage: 'La conexión tardó demasiado. Intenta de nuevo más tarde.',
        technicalMessage: error.toString(),
        isTimeoutError: true,
      );
    }

    if (error.toString().contains('FormatException') ||
        error.toString().contains('JSON')) {
      return AppError(
        userMessage:
            'Hubo un problema al procesar los datos. Intenta de nuevo.',
        technicalMessage: error.toString(),
      );
    }

    if (error is AppError) {
      return error;
    }

    return AppError(
      userMessage: 'Algo salió mal. Intenta de nuevo más tarde.',
      technicalMessage: error.toString(),
    );
  }

  /// Handles API errors from HTTP responses.
  ///
  /// Maps backend error codes to user-friendly messages.
  /// Automatically detects error type (auth, image, etc.).
  ///
  /// Parameters:
  ///   - [code]: Backend error code
  ///   - [message]: Backend error message
  ///   - [statusCode]: HTTP status code
  ///   - [technicalMessage]: Technical error details for debugging
  ///
  /// Returns: [AppError] with appropriate categorization
  static AppError handleApiError({
    required String? code,
    required String? message,
    required int? statusCode,
    String? technicalMessage,
  }) {
    debugPrint(
      'ErrorHandler - API Error: code=$code, status=$statusCode, message=$message',
    );

    bool isImageError = code?.contains('IMAGE') ?? false;

    bool isAuthError =
        code == 'TOKEN_EXPIRED' ||
        code == 'TOKEN_INVALID' ||
        code == 'INVALID_CREDENTIALS' ||
        statusCode == 401;

    String userMessage =
        _errorMessages[code] ??
        _httpErrorMessages[statusCode] ??
        message ??
        'Algo salió mal. Intenta de nuevo.';

    return AppError(
      code: code,
      technicalMessage: technicalMessage ?? message,
      userMessage: userMessage,
      httpStatusCode: statusCode,
      isAuthError: isAuthError,
      isImageError: isImageError,
    );
  }

  /// Handles image picker library errors.
  ///
  /// Provides user-friendly messages for permission denials
  /// and cancellations.
  ///
  /// Parameters:
  ///   - [error]: The error from image picker
  ///
  /// Returns: [AppError] with image error flag
  static AppError handleImagePickerError(dynamic error) {
    debugPrint('ErrorHandler - Image Picker Error: $error');

    if (error.toString().contains('Permission')) {
      return AppError(
        userMessage:
            'Necesitamos permiso para acceder a tus fotos. Actívalo en configuración.',
        technicalMessage: error.toString(),
        isImageError: true,
      );
    }

    if (error.toString().contains('cancelled')) {
      return AppError(
        userMessage: 'Se canceló la selección de imagen.',
        technicalMessage: error.toString(),
        isImageError: true,
      );
    }

    return AppError(
      userMessage: 'No se pudo seleccionar la imagen. Intenta de nuevo.',
      technicalMessage: error.toString(),
      isImageError: true,
    );
  }

  /// Handles image upload errors from backend.
  ///
  /// Detects file size and format issues.
  ///
  /// Parameters:
  ///   - [error]: The error from image upload
  ///
  /// Returns: [AppError] with image error flag
  static AppError handleImageUploadError(dynamic error) {
    debugPrint('ErrorHandler - Image Upload Error: $error');

    if (error.toString().contains('File is too large')) {
      return AppError(
        userMessage: 'La imagen es muy grande. Elige una más pequeña.',
        technicalMessage: error.toString(),
        isImageError: true,
      );
    }

    if (error.toString().contains('Unsupported')) {
      return AppError(
        userMessage: 'El formato de la imagen no es compatible. Usa JPG o PNG.',
        technicalMessage: error.toString(),
        isImageError: true,
      );
    }

    return AppError(
      userMessage: 'No se pudo subir la imagen. Intenta de nuevo.',
      technicalMessage: error.toString(),
      isImageError: true,
    );
  }

  /// Returns an emoji representing the error type.
  ///
  /// Used in error dialogs and snackbars for visual indication.
  ///
  /// Parameters:
  ///   - [error]: The [AppError] to get emoji for
  ///
  /// Returns: An emoji string (📡, ⏱️, 🔐, 🖼️, or ⚠️)
  static String getErrorEmoji(AppError error) {
    if (error.isNetworkError) return '📡';
    if (error.isTimeoutError) return '⏱️';
    if (error.isAuthError) return '🔐';
    if (error.isImageError) return '🖼️';
    return '⚠️';
  }

  /// Determines if an error is retryable.
  ///
  /// Network and timeout errors are typically retryable.
  /// Auth and server errors usually are not.
  ///
  /// Parameters:
  ///   - [error]: The [AppError] to check
  ///
  /// Returns: true if the operation should be retried
  static bool shouldRetry(AppError error) {
    return error.isNetworkError || error.isTimeoutError;
  }
}
