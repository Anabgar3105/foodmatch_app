/// HTTP client for communicating with the FoodMatch API.
///
/// Handles all API requests with automatic header management,
/// token inclusion, and error handling.
///
/// Features:
/// - Automatic JWT token inclusion in Authorization header
/// - Centralized error handling and conversion to AppError
/// - Support for JSON and form data requests
/// - Image upload with multipart/form-data
/// - Timeout handling and network error detection
library;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../core/app_routes.dart';
import '../core/error_handler.dart';
import '../models/app_error.dart';

/// Client for making HTTP requests to the FoodMatch API.
class ApiClient {
  /// HTTP client instance
  final http.Client _client;

  /// Creates an [ApiClient] instance.
  ///
  /// Optionally accepts a custom [http.Client] for testing.
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Gets HTTP headers including authentication token.
  ///
  /// Returns a map with:
  /// - Content-Type: application/json
  /// - Accept: application/json
  /// - Authorization: Bearer < token > (if available)
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Processes API error responses and throws [AppError].
  ///
  /// Decodes error JSON and creates categorized error object.
  /// Rethrows if error is already [AppError].
  ///
  /// Parameters:
  ///   - [response]: The HTTP response with error status
  ///
  /// Throws: [AppError] with appropriate categorization
  void _throwApiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final code = decoded['code'] as String?;
      final message = decoded['message'] as String?;

      throw ErrorHandler.handleApiError(
        code: code,
        message: message,
        statusCode: response.statusCode,
        technicalMessage: decoded['error'],
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleApiError(
        code: response.statusCode.toString(),
        statusCode: response.statusCode,
        message: 'Error ${response.statusCode}',
      );
    }
  }

  /// Handles session expiration by clearing token and redirecting to login.
  ///
  /// Shows notification and navigates to login screen.
  void _handleSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.',
          ),
          backgroundColor: Color(0xFFFF7A59),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  /// Checks if status code indicates unauthorized access.
  bool _isUnauthorized(int statusCode) => statusCode == 401;

  /// Checks if status code indicates forbidden access.
  bool _isForbidden(int statusCode) => statusCode == 403;

  /// Makes a POST request and returns JSON object response.
  ///
  /// Automatically includes authentication header.
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///   - [body]: JSON body to send
  ///
  /// Returns: Parsed JSON response as [Map]
  ///
  /// Throws: [AppError] on HTTP errors, timeout, or invalid JSON
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'].contains('sesión')) {
            _handleSessionExpired();
          }
        } catch (e) {
          _throwApiError(res);
        }
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200 && res.statusCode != 201) {
        _throwApiError(res);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ErrorHandler.handle('Se esperaba objeto JSON');
      }
      return decoded;
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Makes a POST request without returning response body.
  ///
  /// Used for fire-and-forget operations.
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///   - [body]: Optional JSON body to send
  ///
  /// Throws: [AppError] on HTTP errors or timeout
  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        _handleSessionExpired();
        _throwApiError(res);
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200 &&
          res.statusCode != 201 &&
          res.statusCode != 204) {
        _throwApiError(res);
      }
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Makes a GET request and returns JSON array response.
  ///
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///
  /// Returns: Parsed JSON array as [List]
  ///
  /// Throws: [AppError] on HTTP errors, timeout, or invalid JSON
  Future<List<dynamic>> getJsonList(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        _handleSessionExpired();
        _throwApiError(res);
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200) {
        _throwApiError(res);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        throw ErrorHandler.handle('Se esperaba lista JSON');
      }
      return decoded;
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Makes a DELETE request.
  ///
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///
  /// Throws: [AppError] on HTTP errors or timeout
  Future<void> delete(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        _handleSessionExpired();
        _throwApiError(res);
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200 && res.statusCode != 204) {
        _throwApiError(res);
      }
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Makes a GET request and returns JSON object response.
  ///
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///
  /// Returns: Parsed JSON response as [Map]
  ///
  /// Throws: [AppError] on HTTP errors, timeout, or invalid JSON
  Future<Map<String, dynamic>> getJsonObject(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        _handleSessionExpired();
        _throwApiError(res);
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200) {
        _throwApiError(res);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ErrorHandler.handle('Se esperaba objeto JSON');
      }
      return decoded;
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Makes a PUT request and returns JSON object response.
  ///
  /// Used for updating existing resources.
  /// Timeout: 20 seconds.
  ///
  /// Parameters:
  ///   - [url]: The endpoint URL
  ///   - [body]: JSON body to send
  ///
  /// Returns: Parsed JSON response as [Map]
  ///
  /// Throws: [AppError] on HTTP errors, timeout, or invalid JSON
  Future<Map<String, dynamic>> putJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode)) {
        _handleSessionExpired();
        _throwApiError(res);
      }

      if (_isForbidden(res.statusCode)) {
        _throwApiError(res);
      }

      if (res.statusCode != 200 && res.statusCode != 201) {
        _throwApiError(res);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw ErrorHandler.handle('Se esperaba objeto JSON');
      }
      return decoded;
    } on TimeoutException {
      throw ErrorHandler.handle(
        'TimeoutException: La conexión tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Uploads an image file using multipart/form-data.
  ///
  /// Automatically includes authentication header.
  /// Timeout: 30 seconds.
  ///
  /// Parameters:
  ///   - [url]: The upload endpoint URL
  ///   - [filePath]: Local path to the image file
  ///
  /// Returns: The uploaded image URL from the server
  ///
  /// Throws: [AppError] with image error flag on failure
  Future<String> uploadImage(Uri url, String filePath) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (_isUnauthorized(response.statusCode)) {
        _handleSessionExpired();
        _throwApiError(response);
      }

      if (_isForbidden(response.statusCode)) {
        _throwApiError(response);
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        _throwApiError(response);
      }

      final decoded = jsonDecode(response.body);
      return decoded['url'];
    } on TimeoutException {
      throw ErrorHandler.handleImageUploadError(
        'TimeoutException: Subida de imagen tardó demasiado',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handleImageUploadError(e);
    }
  }
}
