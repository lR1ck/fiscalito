import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/quick_replies.dart';
import '../../services/openai_service.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de chat con el asistente AI Fiscalito
///
/// Feature principal de la app. Permite conversar con la AI
/// para resolver dudas fiscales, explicar términos del SAT, etc.
///
/// Integrado con OpenAI GPT-4o-mini para respuestas reales.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Controller del input de texto
  final _messageController = TextEditingController();

  /// Lista de mensajes del chat
  final List<_ChatMessage> _messages = [];

  /// Bandera para mostrar indicador de "escribiendo..."
  bool _isTyping = false;

  /// Servicio de OpenAI
  late final OpenAIService _openAIService;

  /// Bandera para deshabilitar input mientras se procesa
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Inicializar servicio de OpenAI
    try {
      _openAIService = OpenAIService();
    } catch (e) {
      // Si falla la inicialización (ej: API key no encontrada), mostrar error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorSnackBar(
              'Error de configuración. Verifica tu API key en .env');
        }
      });
    }

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
  ///
  /// [customText] Texto opcional para enviar directamente (usado por quick replies)
  Future<void> _sendMessage({String? customText}) async {
    final text = customText ?? _messageController.text.trim();

    if (text.isEmpty || _isProcessing) return;

    setState(() {
      // Agregar mensaje del usuario
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      // Limpiar input solo si no es custom text
      if (customText == null) {
        _messageController.clear();
      }

      // Mostrar indicador de "escribiendo..." y deshabilitar input
      _isTyping = true;
      _isProcessing = true;
    });

    try {
      // ==================== CONTEXTO DE USUARIO ====================
      // IMPORTANTE: Se obtiene el usuario actual en CADA llamada a _sendMessage()
      // para garantizar que el contexto (nombre, RFC, régimen fiscal) se envíe
      // a OpenAI en TODOS los mensajes, sin importar cuántos lleve la conversación.
      //
      // Esto asegura que la AI NUNCA "olvide" quién es el usuario.
      // =============================================================

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUserModel;

      // Debug: Verificar que tenemos usuario antes de enviar
      // TODO: Comentar/eliminar en producción
      if (currentUser != null) {
        print('[ChatScreen] Enviando mensaje con contexto de usuario:');
        print('  - Usuario: ${currentUser.name}');
        print('  - Régimen: ${currentUser.tieneRegimenFiscal ? currentUser.regimenFiscalFormateado : "No configurado"}');
      } else {
        print('[ChatScreen] ADVERTENCIA: Usuario es null, la AI no tendrá contexto personalizado');
      }

      // Construir historial de conversación para OpenAI
      // Incluye todos los mensajes intercambiados hasta ahora
      final conversationHistory = _messages
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      // Llamar a OpenAI API con contexto del usuario
      // NOTA CRÍTICA: El parámetro 'user' se pasa en CADA llamada,
      // garantizando que OpenAIService reconstruya el system prompt
      // con contexto actualizado en cada request a la API.
      final response = await _openAIService.sendMessage(
        conversationHistory,
        user: currentUser, // ← Se pasa SIEMPRE, en cada mensaje
      );

      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _isProcessing = false;
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
        _isProcessing = false;
      });

      // Mostrar error amigable al usuario
      String errorMessage = 'Error al conectar con el asistente';

      if (e.toString().contains('Sin conexión a internet')) {
        errorMessage = 'Sin conexión a internet. Verifica tu red.';
      } else if (e.toString().contains('API key inválida')) {
        errorMessage = 'Error de configuración. Verifica tu API key.';
      } else if (e.toString().contains('Demasiadas solicitudes')) {
        errorMessage = 'Demasiadas solicitudes. Espera un momento.';
      } else if (e.toString().contains('La conexión tardó')) {
        errorMessage = 'La conexión tardó demasiado. Intenta de nuevo.';
      }

      _showErrorSnackBar(errorMessage);
    }
  }

  /// Muestra un SnackBar con mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Determina si se deben mostrar las quick replies
  ///
  /// Se muestran solo cuando:
  /// 1. No hay mensajes de usuario en el historial (solo mensaje de bienvenida)
  /// 2. No se está procesando un mensaje
  bool _shouldShowQuickReplies() {
    // Verificar si hay algún mensaje del usuario
    final hasUserMessages = _messages.any((msg) => msg.isUser);

    // Mostrar solo si no hay mensajes de usuario y no se está procesando
    return !hasUserMessages && !_isProcessing;
  }

  /// Construye el widget de quick replies (sugerencias rápidas)
  ///
  /// Muestra chips horizontales con preguntas predeterminadas
  /// según el régimen fiscal del usuario.
  Widget _buildQuickReplies() {
    // Obtener el régimen fiscal del usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUserModel;
    final regimenCodigo = currentUser?.regimenFiscalCodigo ?? '';

    // Obtener las quick replies según el régimen
    final quickReplies = QuickRepliesHelper.getQuickReplies(regimenCodigo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        border: Border(
          top: BorderSide(
            color: AppTheme.textDisabled.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título de las sugerencias
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppTheme.primaryMagenta,
              ),
              const SizedBox(width: 6),
              Text(
                'Sugerencias',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Lista horizontal de chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickReplies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final reply = quickReplies[index];
                return _buildQuickReplyChip(reply);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un chip individual de quick reply
  ///
  /// [text] Texto del chip (pregunta sugerida)
  Widget _buildQuickReplyChip(String text) {
    return InkWell(
      onTap: () => _sendMessage(customText: text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryMagenta,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: AppTheme.primaryMagenta,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward,
              size: 14,
              color: AppTheme.primaryMagenta,
            ),
          ],
        ),
      ),
    );
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

          // Quick Replies (solo cuando no hay mensajes de usuario)
          if (_shouldShowQuickReplies()) _buildQuickReplies(),

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
                  // Usar MarkdownBody para mensajes de IA, Text para usuario
                  message.isUser
                      ? Text(
                          message.text,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            // Texto normal (párrafos)
                            p: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            // Negritas **texto**
                            strong: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            // Listas con bullets
                            listBullet: const TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 16,
                            ),
                            // Código inline `código`
                            code: TextStyle(
                              color: AppTheme.primaryMagenta,
                              backgroundColor:
                                  AppTheme.surfaceElevated.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            // Espaciado entre bloques (párrafos, listas, etc.)
                            blockSpacing: 12.0,
                            // Indentación de listas
                            listIndent: 24.0,
                            // Tamaño de fuente para listas
                            listBulletPadding: const EdgeInsets.only(right: 8),
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
                enabled: !_isProcessing,
                decoration: InputDecoration(
                  hintText: _isProcessing
                      ? 'Fiscalito está escribiendo...'
                      : 'Pregúntame sobre el SAT...',
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
                onSubmitted: _isProcessing ? null : (_) => _sendMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Botón de enviar
            Container(
              decoration: BoxDecoration(
                color: _isProcessing
                    ? AppTheme.textDisabled
                    : AppTheme.primaryMagenta,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: AppTheme.textPrimary,
                      ),
                onPressed: _isProcessing ? null : _sendMessage,
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
