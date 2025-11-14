import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de chat con el asistente AI Fiscalito
///
/// Feature principal de la app. Permite conversar con la AI
/// para resolver dudas fiscales, explicar términos del SAT, etc.
///
/// Por ahora muestra UI básica sin integración con OpenAI.
/// La integración real se agregará en la siguiente fase.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Controller del input de texto
  final _messageController = TextEditingController();

  /// Lista de mensajes del chat (mock data por ahora)
  final List<_ChatMessage> _messages = [];

  /// Bandera para mostrar indicador de "escribiendo..."
  bool _isTyping = false;

  /// Respuestas mock del AI según keywords
  final Map<String, String> _mockResponses = {
    'rfc': 'El RFC (Registro Federal de Contribuyentes) es tu identificador único ante el SAT. '
        'Es como tu "huella digital" fiscal. Tiene 13 caracteres: 4 letras de tu nombre, '
        '6 dígitos de tu fecha de nacimiento y 3 caracteres de homoclave.\n\n'
        '¿Necesitas ayuda con tu RFC?',
    'resico': 'El RESICO (Régimen Simplificado de Confianza) es como la "opción fácil" '
        'para declarar impuestos que el SAT creó en 2022.\n\n'
        'Imagínalo así: antes tenías que hacer cálculos complicados cada mes. Con RESICO, '
        'el SAT te cobra una tasa fija (1% a 2.5%) sobre tus ingresos.\n\n'
        '¿Es para ti? Si ganas menos de \$3.5 millones al año, probablemente sí.',
    'cfdi': 'El CFDI (Comprobante Fiscal Digital por Internet) es básicamente una factura electrónica.\n\n'
        'Es un archivo XML que contiene toda la información de una compra/venta: '
        'quién vendió, quién compró, cuánto, qué se vendió, etc.\n\n'
        'Todos los negocios en México deben emitir CFDIs. ¿Tienes dudas sobre cómo usarlos?',
    'declaración': 'La declaración mensual es como un "reporte de calificaciones" que le mandas al SAT.\n\n'
        'Le dices: "Este mes gané \$X, gasté \$Y, entonces te debo \$Z de impuestos."\n\n'
        'Fechas importantes:\n'
        '• Personas físicas: Día 17 de cada mes\n'
        '• El 6to dígito de tu RFC determina tu fecha exacta\n\n'
        '¿Quieres que te recuerde cuándo declarar?',
    'sat': 'El SAT (Servicio de Administración Tributaria) es como el "IRS mexicano". '
        'Es la institución que recauda impuestos en México.\n\n'
        'Sé que a veces parece complicado, pero estoy aquí para ayudarte a entender '
        'todo en lenguaje simple. ¿Qué proceso del SAT te genera dudas?',
    'impuestos': 'En México, los impuestos principales son:\n\n'
        '• ISR (Impuesto Sobre la Renta): Un porcentaje de lo que ganas\n'
        '• IVA (Impuesto al Valor Agregado): 16% que se agrega a productos/servicios\n\n'
        'Piensa en ellos como la "mensualidad" que pagamos para tener servicios públicos.\n\n'
        '¿Quieres saber cuánto debes pagar?',
    'factura': 'Para facturar necesitas:\n\n'
        '1. Estar dado de alta en el SAT (tener RFC)\n'
        '2. Tener tu e.firma (antes FIEL)\n'
        '3. Usar un sistema de facturación autorizado\n\n'
        'Las facturas se entregan en formato XML + PDF.\n\n'
        '¿Necesitas ayuda para empezar a facturar?',
  };

  @override
  void initState() {
    super.initState();
    // Agregar mensaje de bienvenida con delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: '¡Hola! Soy Fiscalito, tu asistente fiscal personal. 👋\n\n'
                  'Estoy aquí para ayudarte con:\n'
                  '• Explicar términos del SAT\n'
                  '• Resolver dudas sobre impuestos\n'
                  '• Guiarte en trámites fiscales\n\n'
                  '¿En qué puedo ayudarte hoy?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Envía un mensaje al chat
  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      // Agregar mensaje del usuario
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      // Limpiar input
      _messageController.clear();

      // Mostrar indicador de "escribiendo..."
      _isTyping = true;
    });

    // TODO: Aquí se llamaría a OpenAI API
    // Por ahora, simulamos una respuesta inteligente basada en keywords
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Buscar keyword en el mensaje
      String response = _getSmartResponse(text.toLowerCase());

      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    });
  }

  /// Genera una respuesta inteligente basada en keywords
  String _getSmartResponse(String userMessage) {
    // Buscar keywords en el mensaje
    for (var entry in _mockResponses.entries) {
      if (userMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    // Respuestas genéricas si no hay match
    final genericResponses = [
      'Entiendo tu consulta. Aunque esta es una respuesta simulada, '
          'cuando integremos OpenAI recibirás información detallada sobre temas fiscales.\n\n'
          'Mientras tanto, prueba preguntarme sobre:\n'
          '• RFC\n• RESICO\n• CFDI\n• Declaraciones\n• Impuestos',
      'Esa es una buena pregunta. En la versión completa de Fiscalito, '
          'podré darte una respuesta detallada y personalizada.\n\n'
          '¿Te gustaría saber sobre algún término fiscal específico como RFC, CFDI o RESICO?',
      'Gracias por preguntar. Estoy aquí para ayudarte con dudas fiscales.\n\n'
          'Algunas palabras clave que reconozco:\n'
          '• SAT\n• Factura\n• Declaración\n• Impuestos\n\n'
          '¿Sobre cuál quieres saber más?',
    ];

    // Rotar entre respuestas genéricas
    return genericResponses[_messages.length % genericResponses.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sin botón de back porque estamos en bottom nav
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryMagenta.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.primaryMagenta,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fiscalito AI',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Asistente fiscal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Mostrar opciones (limpiar chat, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opciones próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Inicia una conversación',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Mostrar indicador de "escribiendo..." al principio (reverse=true)
                      if (index == 0 && _isTyping) {
                        return _buildTypingIndicator();
                      }

                      final messageIndex = _isTyping ? index - 1 : index;
                      final message = _messages[_messages.length - 1 - messageIndex];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Input de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Construye una burbuja de mensaje
  Widget _buildMessageBubble(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar de la AI (solo si no es usuario)
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryMagenta.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.primaryMagenta,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Burbuja de mensaje
          Flexible(
            child: Container(
              decoration: message.isUser
                  ? AppTheme.chatUserBubbleDecoration()
                  : AppTheme.chatAiBubbleDecoration(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? AppTheme.textPrimary.withOpacity(0.7)
                          : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar del usuario (solo si es usuario)
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryMagenta,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye el indicador de "escribiendo..."
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar de la AI
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryMagenta.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: AppTheme.primaryMagenta,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),

          // Indicador animado
          Container(
            decoration: AppTheme.chatAiBubbleDecoration(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un punto animado del indicador
  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final offset = (index * 0.2) % 1.0;
        final opacity = ((value + offset) % 1.0).clamp(0.3, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  /// Construye el input de mensajes
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Row(
          children: [
            // Input field
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Pregúntame sobre el SAT...',
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Botón de enviar
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryMagenta,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: AppTheme.textPrimary,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea la hora del mensaje
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Modelo simple para mensajes del chat
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
