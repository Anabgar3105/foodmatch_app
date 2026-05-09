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
      // Inyectamos el token en la cabecera de Autorización
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

      final decoded = jsonDecode(res.body); // Decodificamos a JSON

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Se esperaba objeto JSON, Llegó: ${decoded.runtimeType}',
        );
      }
      return decoded;
    } on TimeoutException {
      throw Exception(
        'La conexión está tardando más de lo esperado y no se ha podido completar la solicitud. Por favor, inténtalo de nuevo más tarde.',
      );
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // NUEVO: Método para hacer POST cuando NO esperamos una respuesta JSON (ej: guardar favorito)
  Future<void> postVoid(Uri url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      // Si hay body lo codificamos, si no, lo mandamos nulo
      final res = await _client
          .post(url, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 20));

      // Aceptamos 200 (OK), 201 (Created) y 204 (No Content) como válidos
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
      throw Exception('Error inesperado: $e');
    }
  }

  // Método genérico para hacer GET y recibir una lista
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
      throw Exception('Error inesperado: $e');
    }
  }

  // Método genérico para hacer DELETE
  Future<void> delete(Uri url) async {
    try {
      final headers = await _getHeaders();
      final res = await _client
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      // 200 (OK) y 204 (No Content) son respuestas válidas para un DELETE
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
      throw Exception('Error inesperado: $e');
    }
  }
}
