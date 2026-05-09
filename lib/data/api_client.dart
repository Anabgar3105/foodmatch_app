import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Método genérico para enviar datos por POST y recibir un JSON
  Future<Map<String, dynamic>> postJsonObject(Uri url, Map<String, dynamic> body) async {
    try {
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10)); 

      if (res.statusCode != 200 && res.statusCode != 201) {
        // Intentamos extraer el mensaje de error del backend
        String errorMsg = 'Error HTTP ${res.statusCode}';
        try {
          final decoded = jsonDecode(res.body);
          if (decoded['message'] != null) errorMsg = decoded['message'];
        } catch (_) {}
        throw Exception(errorMsg); // Lanzamos excepción si falla la red o el estado
      }

      final decoded = jsonDecode(res.body); // Decodificamos a JSON
      
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Se esperaba objeto JSON, Llegó: ${decoded.runtimeType}');
      }
      return decoded;

    } on TimeoutException {
      throw Exception('La conexión está tardando más de lo esperado y no hemos podido completar la solicitud. Por favor, inténtalo de nuevo más tarde.');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}