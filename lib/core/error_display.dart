import 'package:flutter/material.dart';
import 'package:foodmatch_app/main.dart';
import '../models/app_error.dart';
import '../core/error_handler.dart';


class ErrorDisplay {
  static void showSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(ErrorHandler.getErrorEmoji(error), style: const TextStyle(fontSize: 18)),
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
            Text(ErrorHandler.getErrorEmoji(error), style: const TextStyle(fontSize: 24)),
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
              style: Theme.of(navigatorKey.currentContext!).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium,
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

  static Color _getErrorColor(AppError error) {
    if (error.isAuthError) return const Color(0xFFD32F2F);
    if (error.isNetworkError || error.isTimeoutError) return const Color(0xFFF57C00);
    if (error.isImageError) return const Color(0xFF1976D2);
    return const Color(0xFFFF7A59);
  }
}

extension ErrorExtension on AppError {
  void showAsSnackBar(BuildContext context) {
    ErrorDisplay.showSnackBar(context, this);
  }

  Future<void> showAsDialog(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    await ErrorDisplay.showDialog(context, this, onRetry: onRetry);
  }

  Widget toWidget({VoidCallback? onRetry}) {
    return ErrorDisplay.errorWidget(error: this, onRetry: onRetry);
  }
}


