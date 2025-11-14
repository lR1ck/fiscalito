import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de configuración de recordatorios
///
/// Permite al usuario configurar cómo y cuándo recibir
/// recordatorios de obligaciones fiscales.
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  /// Configuraciones (guardadas en memoria)
  bool _pushNotificationsEnabled = true;
  bool _emailRemindersEnabled = false;
  int _daysInAdvance = 3; // 1, 3, 5, 7 días

  /// Recordatorios activos mock
  final List<_ActiveReminder> _activeReminders = [
    _ActiveReminder(
      title: 'Declaración mensual',
      dueDate: DateTime(2025, 12, 17),
      notifyDaysBefore: 3,
    ),
    _ActiveReminder(
      title: 'Pago provisional ISR',
      dueDate: DateTime(2025, 12, 17),
      notifyDaysBefore: 3,
    ),
    _ActiveReminder(
      title: 'DIOT - Declaración informativa',
      dueDate: DateTime(2025, 12, 20),
      notifyDaysBefore: 3,
    ),
    _ActiveReminder(
      title: 'Declaración anual',
      dueDate: DateTime(2026, 4, 30),
      notifyDaysBefore: 7,
    ),
  ];

  /// Flag para mostrar que hubo cambios
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      size: 48,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nunca olvides una fecha',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura cómo quieres recibir recordatorios de tus obligaciones fiscales',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Sección: Notificaciones
            _buildSection(
              title: 'Métodos de notificación',
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: AppTheme.primaryMagenta,
                  ),
                  title: const Text('Notificaciones push'),
                  subtitle: const Text(
                    'Recibe alertas en tu dispositivo',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                      _hasChanges = true;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.email,
                    color: AppTheme.primaryMagenta,
                  ),
                  title: const Text('Recordatorios por email'),
                  subtitle: const Text(
                    'Recibe correos de recordatorio',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  value: _emailRemindersEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailRemindersEnabled = value;
                      _hasChanges = true;
                    });
                  },
                ),
              ],
            ),

            // Sección: Anticipación
            _buildSection(
              title: 'Tiempo de anticipación',
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.schedule,
                    color: AppTheme.primaryMagenta,
                  ),
                  title: const Text('Recordar con anticipación'),
                  subtitle: Text(
                    '$_daysInAdvance ${_daysInAdvance == 1 ? "día" : "días"} antes',
                    style: const TextStyle(
                      color: AppTheme.primaryMagenta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showDaysPickerDialog,
                ),
              ],
            ),

            // Sección: Recordatorios activos
            _buildSection(
              title: 'Recordatorios activos (${_activeReminders.length})',
              children: _activeReminders
                  .map((reminder) => _buildReminderTile(reminder))
                  .toList(),
            ),

            // Botón guardar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveSettings : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Guardar configuración'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una sección
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Construye un tile de recordatorio activo
  Widget _buildReminderTile(_ActiveReminder reminder) {
    final daysUntil = reminder.dueDate.difference(DateTime.now()).inDays;
    final notifyDate = reminder.dueDate
        .subtract(Duration(days: reminder.notifyDaysBefore));

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warningOrange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.event,
          color: AppTheme.warningOrange,
          size: 20,
        ),
      ),
      title: Text(reminder.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Vence: ${_formatDate(reminder.dueDate)}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            'Recordar: ${_formatDate(notifyDate)}',
            style: const TextStyle(
              color: AppTheme.primaryMagenta,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: daysUntil < 7
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysUntil < 0
                    ? 'Vencido'
                    : daysUntil == 0
                        ? 'Hoy'
                        : '$daysUntil días',
                style: const TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  /// Muestra el diálogo para elegir días de anticipación
  void _showDaysPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Días de anticipación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDayOption(1),
            _buildDayOption(3),
            _buildDayOption(5),
            _buildDayOption(7),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Construye una opción de día
  Widget _buildDayOption(int days) {
    final isSelected = _daysInAdvance == days;

    return RadioListTile<int>(
      title: Text('$days ${days == 1 ? "día" : "días"} antes'),
      value: days,
      groupValue: _daysInAdvance,
      activeColor: AppTheme.primaryMagenta,
      selected: isSelected,
      onChanged: (value) {
        setState(() {
          _daysInAdvance = value!;
          _hasChanges = true;
        });
        Navigator.pop(context);
      },
    );
  }

  /// Guarda la configuración
  void _saveSettings() {
    // TODO: Guardar en SharedPreferences o Firestore
    setState(() {
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Modelos

/// Modelo para recordatorio activo
class _ActiveReminder {
  final String title;
  final DateTime dueDate;
  final int notifyDaysBefore;

  _ActiveReminder({
    required this.title,
    required this.dueDate,
    required this.notifyDaysBefore,
  });
}
