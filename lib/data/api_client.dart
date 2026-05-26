import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../core/app_routes.dart';
import '../core/error_handler.dart';
import '../models/app_error.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

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

  /// Procesa una respuesta de error del API y lanza AppError
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

  void _handleSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
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

  bool _isUnauthorized(int statusCode) => statusCode == 401;
  bool _isForbidden(int statusCode) => statusCode == 403;

  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (_isUnauthorized(res.statusCode) ) {
        try{
            final decoded = jsonDecode(res.body);
            if(decoded['message'].contains('sesión')) {
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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handle('TimeoutException: La conexión tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

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
      throw ErrorHandler.handleImageUploadError('TimeoutException: Subida de imagen tardó demasiado');
    } on AppError {
      rethrow;
    } catch (e) {
      throw ErrorHandler.handleImageUploadError(e);
    }
  }
}
