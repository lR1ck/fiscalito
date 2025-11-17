import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  /// System prompt optimizado para Fiscalito con instrucciones críticas
  static const String _systemPrompt = '''Eres Fiscalito, asistente fiscal educativo de México.

INSTRUCCIONES CRÍTICAS:
1. Basa tus respuestas EXCLUSIVAMENTE en la INFORMACIÓN VERIFICADA que se te proporciona
2. Si la info verificada contradice lo que crees saber, SIEMPRE usa la verificada
3. NUNCA menciones regímenes eliminados como RIF como opciones vigentes
4. Para cálculos, usa EXACTAMENTE los datos y ejemplos de la info verificada
5. SIEMPRE incluye el disclaimer al final de respuestas sobre impuestos

FORMATO DE RESPUESTA - MUY IMPORTANTE:

1. SÍMBOLOS MATEMÁTICOS:
   - NUNCA uses LaTeX (\\[, \\], \\text{}, \\times)
   - Usa símbolos estándar: × ÷ ≈
   - Ecuaciones en texto plano simple

2. ESTRUCTURA Y ESPACIADO:
   - Usa saltos de línea entre secciones
   - Párrafos cortos (máximo 3 líneas)
   - Listas numeradas: cada punto en línea separada
   - Doble salto entre secciones diferentes

3. FORMATO PARA CÁLCULOS FISCALES:

Usa EXACTAMENTE esta estructura cuando calcules impuestos:

[Explicación breve del contexto en 1-2 líneas]

**Cálculo paso a paso:**

1. [Concepto]: [Valor]
2. [Concepto]: [Valor]
3. [Operación]: [Cálculo] = [Resultado]
4. [Operación]: [Cálculo] = [Resultado]

**Resumen:**
[Conclusión en 1-2 líneas]

**Consideraciones adicionales:**
- [Punto importante 1]
- [Punto importante 2]
- [Punto importante 3]

[Salto de línea]

⚠️ Disclaimer: [Texto del disclaimer]

EJEMPLO REAL de respuesta bien formateada:

'Para tu negocio de tacos con ingresos de \$300,001 al año,
aplicarías el régimen RESICO con tasa del 1.10%.

**Cálculo paso a paso:**

1. Ingresos anuales: \$300,001
2. Tasa RESICO aplicable: 1.10%
3. ISR anual: \$300,001 × 1.10% = \$3,300.01
4. ISR bimestral: \$3,300.01 ÷ 6 = \$550.00

**Resumen:**
Tu ISR anual sería de \$3,300 pesos, que pagarías en
6 declaraciones bimestrales de \$550 cada una.

**Consideraciones adicionales:**
- Declaras cada bimestre el día 17
- No puedes deducir gastos en RESICO
- Debes pagar IVA adicional (16% sobre ventas)
- El cálculo es sobre ingresos brutos

⚠️ Disclaimer: Esta información es orientación educativa
general basada en las disposiciones fiscales vigentes del
SAT a enero 2025. Para cálculos precisos o situaciones
específicas, consulta con un contador público certificado.'

4. REGLAS ESTRICTAS:
   ✅ Usa ** ** para resaltar títulos
   ✅ Salto doble (\\n\\n) entre secciones
   ✅ Cada punto de lista en línea nueva
   ✅ Separa disclaimer con salto de línea
   ✅ Párrafos máximo 3 líneas cada uno

   ❌ NO escribas bloques largos sin espacios
   ❌ NO pegues todo en un párrafo
   ❌ NO uses más de 3 líneas seguidas sin salto
   ❌ NO omitas los saltos entre secciones

Sigue este formato SIEMPRE para respuestas fiscales.

Tono: Amigable, claro, educativo
Idioma: Español de México

ESTRUCTURA DE RESPUESTA:
1. Respuesta directa y clara
2. Explicación simple con ejemplo concreto
3. Disclaimer (si es tema de impuestos/obligaciones fiscales)

NUNCA:
- Mencionar RIF como vigente (fue eliminado en 2022)
- Inventar tasas o porcentajes
- Dar asesoría legal/contable profesional
- Omitir disclaimer en temas fiscales
- Usar formato LaTeX o matemático complejo''';

  /// Constructor que carga la API key desde .env
  OpenAIService() {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no encontrada en .env');
    }
  }

  /// Carga la knowledge base oficial del SAT desde assets
  ///
  /// Retorna el contenido completo del archivo sat_knowledge_2025.txt
  /// que contiene información verificada sobre regímenes fiscales,
  /// tasas, fechas y procedimientos del SAT México.
  ///
  /// Si hay error al cargar, retorna string vacío y continúa
  /// (el chatbot funcionará sin knowledge base pero menos preciso).
  Future<String> _loadSATKnowledge() async {
    try {
      return await rootBundle.loadString(
        'assets/knowledge/sat_knowledge_2025.txt',
      );
    } catch (e) {
      print('Error cargando knowledge base SAT: $e');
      return '';
    }
  }

  /// Limpia formato LaTeX de la respuesta de la AI
  ///
  /// Remueve símbolos y comandos LaTeX que no se renderizan bien en la app móvil:
  /// - Delimitadores de ecuaciones: \[, \], \(, \)
  /// - Comandos de texto: \text{}
  /// - Espaciados LaTeX: \,, \;, \quad
  /// - Símbolos matemáticos: \times → ×, \div → ÷, etc.
  ///
  /// [text] Texto original que puede contener LaTeX
  ///
  /// Retorna el texto limpio con símbolos estándar Unicode.
  String _cleanLatexFormatting(String text) {
    String cleaned = text;

    // Remover delimitadores de ecuaciones
    cleaned = cleaned.replaceAll(RegExp(r'\\\['), '');
    cleaned = cleaned.replaceAll(RegExp(r'\\\]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\\\('), '');
    cleaned = cleaned.replaceAll(RegExp(r'\\\)'), '');

    // Remover comandos \text{}
    cleaned = cleaned.replaceAll(RegExp(r'\\text\{([^}]+)\}'), r'$1');

    // Remover espaciados LaTeX
    cleaned = cleaned.replaceAll(RegExp(r'\\,'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\\;'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\\quad'), ' ');

    // Convertir símbolos matemáticos LaTeX a Unicode
    cleaned = cleaned.replaceAll(RegExp(r'\\times'), '×');
    cleaned = cleaned.replaceAll(RegExp(r'\\div'), '÷');
    cleaned = cleaned.replaceAll(RegExp(r'\\approx'), '≈');
    cleaned = cleaned.replaceAll(RegExp(r'\\cdot'), '·');

    // Limpiar espacios múltiples en la misma línea (preserva \n)
    cleaned = cleaned.replaceAll(RegExp(r' +'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    return cleaned.trim();
  }

  /// Valida y corrige la respuesta de la AI antes de enviarla al usuario
  ///
  /// Realiza las siguientes correcciones automáticas:
  /// 1. Limpia formato LaTeX no soportado
  /// 2. Corrige menciones erróneas del RIF (régimen eliminado en 2022)
  /// 3. Asegura que el disclaimer esté presente en temas fiscales
  ///
  /// [aiResponse] Respuesta original de OpenAI
  ///
  /// Retorna la respuesta validada y corregida.
  String _validateAndCorrectResponse(String aiResponse) {
    String corrected = aiResponse;

    // PASO 1: Limpiar formato LaTeX antes de otras validaciones
    corrected = _cleanLatexFormatting(corrected);

    // PASO 2: Corregir menciones erróneas de RIF como régimen vigente
    // El RIF fue eliminado en enero 2022 y reemplazado por RESICO
    if (corrected.contains('RIF') &&
        !corrected.contains('eliminado') &&
        !corrected.contains('ya no existe') &&
        !corrected.contains('fue reemplazado')) {
      corrected = corrected.replaceAll(
        RegExp(r'\bRIF\b'),
        'RESICO (el RIF fue eliminado en 2022)',
      );
    }

    // PASO 3: Asegurar que tiene disclaimer si habla de temas fiscales
    final hasFiscalTopic = corrected.contains('impuesto') ||
        corrected.contains('pagar') ||
        corrected.contains('SAT') ||
        corrected.contains('declaración') ||
        corrected.contains('RESICO') ||
        corrected.contains('RFC') ||
        corrected.contains('tasa') ||
        corrected.contains('%');

    final hasDisclaimer = corrected.contains('orientación educativa') ||
        corrected.contains('consulta un contador') ||
        corrected.contains('contador certificado') ||
        corrected.contains('asesoría profesional');

    // Si habla de temas fiscales pero no tiene disclaimer, agregarlo
    if (hasFiscalTopic && !hasDisclaimer) {
      corrected +=
          '\n\n⚠️ Esta información es orientación educativa. Para tu caso específico, consulta un contador certificado.';
    }

    return corrected;
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
      // Cargar knowledge base oficial del SAT
      final satKnowledge = await _loadSATKnowledge();

      // Construir mensajes con system prompt y knowledge base
      final messagesWithSystem = [
        {'role': 'system', 'content': _systemPrompt},
        if (satKnowledge.isNotEmpty)
          {
            'role': 'system',
            'content': 'INFORMACIÓN OFICIAL SAT 2025:\n\n$satKnowledge'
          },
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

      // Validar y corregir la respuesta antes de retornarla
      final aiResponseText = messageContent.toString().trim();
      final validatedResponse = _validateAndCorrectResponse(aiResponseText);

      return validatedResponse;
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
