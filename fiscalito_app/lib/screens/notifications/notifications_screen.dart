import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de notificaciones
///
/// Muestra todas las notificaciones del usuario organizadas
/// por fecha: recordatorios, alertas del SAT, actualizaciones de la app.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Lista de notificaciones mock
  final List<_Notification> _notifications = [
    _Notification(
      id: '1',
      title: 'Declaración mensual próxima',
      body: 'Tu declaración mensual vence el 17 de diciembre. No olvides presentarla a tiempo.',
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    _Notification(
      id: '2',
      title: 'Nueva actualización disponible',
      body: 'Fiscalito v1.0.1 ya está disponible. Incluye mejoras en el chat con AI.',
      type: NotificationType.update,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    _Notification(
      id: '3',
      title: 'Alerta del SAT',
      body: 'El SAT ha publicado nuevas reglas para la deducción de viáticos. Revisa los cambios.',
      type: NotificationType.satAlert,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    _Notification(
      id: '4',
      title: 'Recordatorio: Pago provisional',
      body: 'Tu pago provisional de ISR vence en 3 días. Monto estimado: \$2,500.00',
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ),
    _Notification(
      id: '5',
      title: 'Nueva factura recibida',
      body: 'Has recibido un CFDI de "Servicios Profesionales XYZ" por \$3,500.00',
      type: NotificationType.update,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    _Notification(
      id: '6',
      title: 'Cambios en el régimen RESICO',
      body: 'El SAT anunció cambios en las tasas del RESICO para 2026. Consulta más información.',
      type: NotificationType.satAlert,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    _Notification(
      id: '7',
      title: 'Declaración anual 2025',
      body: 'Recuerda que la declaración anual vence el 30 de abril de 2026.',
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
    _Notification(
      id: '8',
      title: 'Respaldo de datos completado',
      body: 'Tus facturas y datos fiscales han sido respaldados exitosamente.',
      type: NotificationType.update,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    ),
  ];

  /// Contador de notificaciones no leídas
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          // Botón marcar todas como leídas
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Marcar todas'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _notifications.length + 1, // +1 para el header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }
                return _buildNotificationTile(_notifications[index - 1]);
              },
            ),
    );
  }

  /// Construye el header con resumen
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryMagenta.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: AppTheme.primaryMagenta,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $_unreadCount sin leer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_notifications.length} notificaciones en total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un tile de notificación
  Widget _buildNotificationTile(_Notification notification) {
    final color = _getTypeColor(notification.type);
    final icon = _getTypeIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorRed,
        child: const Icon(
          Icons.delete,
          color: AppTheme.textPrimary,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Opacity(
        opacity: notification.isRead ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: AppTheme.cardDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _markAsRead(notification),
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono según tipo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Contenido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                ),
                              ),
                              // Indicador no leída
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryMagenta,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.body,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin notificaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No tienes notificaciones nuevas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Marca una notificación como leída
  void _markAsRead(_Notification notification) {
    if (notification.isRead) return;

    setState(() {
      notification.isRead = true;
    });
  }

  /// Marca todas las notificaciones como leídas
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Helpers

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return AppTheme.warningOrange;
      case NotificationType.satAlert:
        return AppTheme.errorRed;
      case NotificationType.update:
        return AppTheme.infoBlue;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.satAlert:
        return Icons.warning;
      case NotificationType.update:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      final months = [
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic'
      ];
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    }
  }
}

// Modelos

/// Modelo para notificaciones
class _Notification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

/// Tipos de notificaciones
enum NotificationType {
  reminder, // Recordatorios (naranja)
  satAlert, // Alertas del SAT (rojo)
  update, // Actualizaciones (azul)
}
