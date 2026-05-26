import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../core/app_routes.dart';

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

  void _handleSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión caducada. Por favor, inicia sesión de nuevo.'),
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

      if (_isUnauthorized(res.statusCode)) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null &&
              decoded['message'].toString().toLowerCase().contains('sesión')) {
            _handleSessionExpired();
            throw Exception('Sesión caducada');
          }
        } catch (e) {
          throw Exception(e.toString());
        }
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para realizar esta acción';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Se esperaba objeto JSON');
      }
      return decoded;
    } on TimeoutException {
      throw Exception(
        '¡Ups! Hay problemas de conexión con el servidor. Inténtalo de nuevo más tarde.',
      );
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para realizar esta acción';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200 &&
          res.statusCode != 201 &&
          res.statusCode != 204) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para acceder a este recurso';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200)
        throw Exception('GET ${url.path} -> ${res.statusCode}');

      final decoded = jsonDecode(res.body);
      if (decoded is! List) throw Exception('Se esperaba lista JSON');
      return decoded;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para realizar esta acción';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200 && res.statusCode != 204) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para acceder a este recurso';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>)
        throw Exception('Se esperaba objeto JSON');
      return decoded;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(res.statusCode)) {
        String errorMsg = 'No tienes permisos para editar esta receta';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>)
        throw Exception('Se esperaba objeto JSON');
      return decoded;
    } on TimeoutException {
      throw Exception(
        '¡Ups! Hay problemas de conexión con el servidor. Inténtalo de nuevo más tarde.',
      );
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Sesión caducada');
      }

      if (_isForbidden(response.statusCode)) {
        String errorMsg = 'No tienes permisos para subir imágenes';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      return decoded['url'];
    } catch (e) {
      throw Exception('Fallo al subir imagen: $e');
    }
  }
}
