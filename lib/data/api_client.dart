import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Método genérico para enviar datos por POST y recibir un JSON
  Future<Map<String, dynamic>> postJsonObject(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
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
        'La conexión está tardando más de lo esperado y no hemos podido completar la solicitud. Por favor, inténtalo de nuevo más tarde.',
      );
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Método genérico para hacer GET y recibir una lista
  Future<List<dynamic>> getJsonList(Uri url) async {
    try {
      final res = await _client
          .get(url, headers: {'Accept': 'application/json'})
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
}
