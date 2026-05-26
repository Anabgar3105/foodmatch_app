/// Utility class for displaying errors to users.
///
/// Provides multiple error presentation methods:
/// - SnackBar for non-blocking notifications
/// - Dialog for important errors with optional retry
/// - Error widget for full-screen error states
///
/// All methods automatically handle error categorization and emoji display.
library;
import 'package:flutter/material.dart';
import 'package:foodmatch_app/main.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';

/// Utility class for displaying errors in the UI.
class ErrorDisplay {
  /// Displays an error as a floating snackbar.
  ///
  /// Shows error message with emoji and color-coded background.
  /// Automatically dismisses after 4 seconds.
  ///
  /// Parameters:
  ///   - [context]: Build context for showing snackbar
  ///   - [error]: The [AppError] to display
  static void showSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              ErrorHandler.getErrorEmoji(error),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.userMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Displays an error as an adaptive dialog.
  ///
  /// Shows error message with emoji in dialog title.
  /// Includes "Retry" button for retryable errors.
  ///
  /// Parameters:
  ///   - [context]: Build context for showing dialog
  ///   - [error]: The [AppError] to display
  ///   - [onRetry]: Optional callback for retry action
  static Future<void> showDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) async {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              ErrorHandler.getErrorEmoji(error),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Algo salió mal')),
          ],
        ),
        content: Text(error.userMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (ErrorHandler.shouldRetry(error) && onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }

  /// Creates a full-screen error widget.
  ///
  /// Displays error emoji, title, message, and optional retry button.
  /// Used for displaying errors in place of normal content.
  ///
  /// Parameters:
  ///   - [error]: The [AppError] to display
  ///   - [onRetry]: Optional callback for retry action
  ///   - [iconSize]: Size of error emoji (default 64)
  ///
  /// Returns: A centered widget displaying the error
  static Widget errorWidget({
    required AppError error,
    VoidCallback? onRetry,
    double iconSize = 64,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ErrorHandler.getErrorEmoji(error),
              style: TextStyle(fontSize: iconSize),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops, algo salió mal',
              style: Theme.of(
                navigatorKey.currentContext!,
              ).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                navigatorKey.currentContext!,
              ).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (ErrorHandler.shouldRetry(error) && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }

  /// Gets the appropriate background color for error type.
  ///
  /// Returns different colors for auth, network, image, and other errors.
  ///
  /// Parameters:
  ///   - [error]: The [AppError] to get color for
  ///
  /// Returns: Color appropriate for error type
  static Color _getErrorColor(AppError error) {
    if (error.isAuthError) return const Color(0xFFD32F2F);
    if (error.isNetworkError || error.isTimeoutError) {
      return const Color(0xFFF57C00);
    }
    if (error.isImageError) return const Color(0xFF1976D2);
    return const Color(0xFFFF7A59);
  }
}

/// Extension methods for easy error display.
///
/// Adds convenience methods to [AppError] for quick error presentation.
extension ErrorExtension on AppError {
  /// Shows this error as a snackbar.
  ///
  /// Parameters:
  ///   - [context]: Build context for showing snackbar
  void showAsSnackBar(BuildContext context) {
    ErrorDisplay.showSnackBar(context, this);
  }

  /// Shows this error as a dialog.
  ///
  /// Parameters:
  ///   - [context]: Build context for showing dialog
  ///   - [onRetry]: Optional callback for retry action
  Future<void> showAsDialog(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    await ErrorDisplay.showDialog(context, this, onRetry: onRetry);
  }

  /// Converts this error to a widget for display.
  ///
  /// Parameters:
  ///   - [onRetry]: Optional callback for retry action
  ///
  /// Returns: Error display widget
  Widget toWidget({VoidCallback? onRetry}) {
    return ErrorDisplay.errorWidget(error: this, onRetry: onRetry);
  }
}
