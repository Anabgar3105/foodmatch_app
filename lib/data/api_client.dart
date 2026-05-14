import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Método genérico para enviar datos por POST y recibir un JSON
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(
          errorMsg,
        ); 
      }

      final decoded = jsonDecode(res.body); 

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Se esperaba objeto JSON, Llegó: ${decoded.runtimeType}',
        );
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

  // Método genérico para enviar datos por POST y no esperar respuesta (void)
  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      // Si hay body lo codificamos, si no, lo mandamos nulo
      final res = await _client
          .post(url, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200 && res.statusCode != 201 && res.statusCode != 204) {
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

      if (res.statusCode != 200) {
        throw Exception('GET ${url.path} -> ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! List) {
        throw Exception(
          'Se esperaba lista JSON, Llegó: ${decoded.runtimeType}',
        );
      }

      return decoded;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Método genérico para hacer DELETE
  Future<void> delete(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 20));

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

  // Método genérico para hacer GET
  Future<Map<String, dynamic>> getJsonObject(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg);
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Se esperaba objeto JSON, Llegó: ${decoded.runtimeType}',
        );
      }

      return decoded;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
