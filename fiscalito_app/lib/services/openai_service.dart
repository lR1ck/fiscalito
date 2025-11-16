import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para integración con OpenAI API
///
/// Maneja toda la comunicación con GPT-4o-mini para el chat de Fiscalito.
/// Incluye manejo robusto de errores y timeout de 10 segundos.
class OpenAIService {
  /// URL del endpoint de chat completions
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Modelo a utilizar (gpt-4o-mini)
  static const String _model = 'gpt-4o-mini';

  /// Timeout para requests (10 segundos)
  static const Duration _timeout = Duration(seconds: 10);

  /// API key cargada desde .env
  late final String _apiKey;

  /// System prompt optimizado para Fiscalito
  static const String _systemPrompt = '''Eres Fiscalito, asistente fiscal mexicano experto en SAT.
Explicas términos fiscales en lenguaje simple y claro.

REGLAS:
- Siempre español de México
- Amigable pero profesional
- Ejemplos prácticos
- Si no sabes, recomienda contador
- Nunca asesoría legal profesional

CONTEXTO SAT:
- RFC = Tax ID mexicano
- CFDI = Factura electrónica
- RESICO = Régimen fiscal simplificado
- Declaración mensual: día 17''';

  /// Constructor que carga la API key desde .env
  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no encontrada en .env');
    }
  }

  /// Envía un mensaje al chat y retorna la respuesta
  ///
  /// [messages] Lista de mensajes con formato:
  /// ```dart
  /// [
  ///   {'role': 'user', 'content': 'Hola'},
  ///   {'role': 'assistant', 'content': 'Hola, ¿cómo puedo ayudarte?'},
  ///   {'role': 'user', 'content': '¿Qué es el RFC?'},
  /// ]
  /// ```
  ///
  /// Retorna el mensaje de respuesta de la AI.
  ///
  /// Lanza excepciones con mensajes en español para diferentes errores:
  /// - TimeoutException: 'La conexión tardó demasiado. Intenta de nuevo.'
  /// - SocketException: 'Sin conexión a internet. Verifica tu red.'
  /// - HTTP 401: 'API key inválida. Contacta al administrador.'
  /// - HTTP 429: 'Demasiadas solicitudes. Espera un momento.'
  /// - Otros: 'Error al conectar con el asistente.'
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      // Agregar system prompt al inicio si no existe
      final messagesWithSystem = [
        {'role': 'system', 'content': _systemPrompt},
        ...messages,
      ];

      // Construir el body del request
      final body = jsonEncode({
        'model': _model,
        'messages': messagesWithSystem,
        'temperature': 0.7,
        'max_tokens': 500,
      });

      // Realizar el request con timeout
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: body,
          )
          .timeout(_timeout);

      // Manejo de códigos HTTP
      if (response.statusCode == 401) {
        throw Exception('API key inválida. Contacta al administrador.');
      }

      if (response.statusCode == 429) {
        throw Exception('Demasiadas solicitudes. Espera un momento.');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Error del servidor (${response.statusCode}). Intenta de nuevo.');
      }

      // Parsear respuesta
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      // Extraer el mensaje de la respuesta
      final messageContent = data['choices']?[0]?['message']?['content'];

      if (messageContent == null || messageContent.isEmpty) {
        throw Exception('Respuesta vacía del servidor.');
      }

      return messageContent.toString().trim();
    } on TimeoutException {
      throw Exception('La conexión tardó demasiado. Intenta de nuevo.');
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu red.');
    } on FormatException {
      throw Exception('Respuesta inválida del servidor.');
    } catch (e) {
      // Si el error ya tiene un mensaje personalizado, propagarlo
      if (e.toString().contains('API key inválida') ||
          e.toString().contains('Demasiadas solicitudes') ||
          e.toString().contains('Error del servidor') ||
          e.toString().contains('Respuesta vacía') ||
          e.toString().contains('La conexión tardó') ||
          e.toString().contains('Sin conexión') ||
          e.toString().contains('Respuesta inválida')) {
        rethrow;
      }

      // Error genérico para cualquier otra excepción
      throw Exception('Error al conectar con el asistente: ${e.toString()}');
    }
  }
}
