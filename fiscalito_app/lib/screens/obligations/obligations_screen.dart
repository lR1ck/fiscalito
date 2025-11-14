import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de obligaciones fiscales
///
/// Muestra el calendario fiscal con todas las fechas importantes
/// del SAT: declaraciones mensuales, anuales, pagos provisionales, etc.
///
/// Ayuda al usuario a no perder ninguna fecha límite y evitar multas.
class ObligationsScreen extends StatefulWidget {
  const ObligationsScreen({super.key});

  @override
  State<ObligationsScreen> createState() => _ObligationsScreenState();
}

class _ObligationsScreenState extends State<ObligationsScreen> {
  /// Mes seleccionado para mostrar obligaciones
  DateTime _selectedMonth = DateTime.now();

  /// Lista de obligaciones fiscales mock
  final List<_TaxObligation> _obligations = [
    // Diciembre 2025
    _TaxObligation(
      title: 'Declaración mensual',
      description: 'Declaración de impuestos del mes anterior',
      dueDate: DateTime(2025, 12, 17),
      type: ObligationType.monthly,
      status: ObligationStatus.pending,
      amount: null,
    ),
    _TaxObligation(
      title: 'Pago provisional ISR',
      description: 'Pago provisional del Impuesto Sobre la Renta',
      dueDate: DateTime(2025, 12, 17),
      type: ObligationType.payment,
      status: ObligationStatus.pending,
      amount: 2500.00,
    ),
    _TaxObligation(
      title: 'Declaración informativa',
      description: 'DIOT - Declaración de operaciones con terceros',
      dueDate: DateTime(2025, 12, 20),
      type: ObligationType.informative,
      status: ObligationStatus.pending,
      amount: null,
    ),

    // Enero 2026
    _TaxObligation(
      title: 'Declaración mensual',
      description: 'Declaración de impuestos de diciembre',
      dueDate: DateTime(2026, 1, 17),
      type: ObligationType.monthly,
      status: ObligationStatus.upcoming,
      amount: null,
    ),
    _TaxObligation(
      title: 'Constancia de retenciones',
      description: 'Entrega de constancias a trabajadores',
      dueDate: DateTime(2026, 1, 31),
      type: ObligationType.informative,
      status: ObligationStatus.upcoming,
      amount: null,
    ),

    // Abril 2026 (Declaración anual)
    _TaxObligation(
      title: 'Declaración anual',
      description: 'Declaración anual de personas físicas 2025',
      dueDate: DateTime(2026, 4, 30),
      type: ObligationType.annual,
      status: ObligationStatus.upcoming,
      amount: null,
    ),

    // Obligaciones completadas (ejemplo)
    _TaxObligation(
      title: 'Declaración mensual',
      description: 'Declaración de impuestos de octubre',
      dueDate: DateTime(2025, 11, 17),
      type: ObligationType.monthly,
      status: ObligationStatus.completed,
      amount: null,
    ),
    _TaxObligation(
      title: 'Pago provisional ISR',
      description: 'Pago provisional del Impuesto Sobre la Renta',
      dueDate: DateTime(2025, 11, 17),
      type: ObligationType.payment,
      status: ObligationStatus.completed,
      amount: 2100.00,
    ),
  ];

  /// Filtra obligaciones por mes seleccionado
  List<_TaxObligation> get _filteredObligations {
    return _obligations.where((obligation) {
      return obligation.dueDate.year == _selectedMonth.year &&
          obligation.dueDate.month == _selectedMonth.month;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obligaciones Fiscales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de mes
          _buildMonthSelector(),

          // Resumen del mes
          _buildMonthlySummary(),

          // Lista de obligaciones
          Expanded(
            child: _filteredObligations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredObligations.length,
                    itemBuilder: (context, index) {
                      return _buildObligationCard(_filteredObligations[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleSetReminder,
        icon: const Icon(Icons.notifications_active),
        label: const Text('Recordatorios'),
      ),
    );
  }

  /// Construye el selector de mes
  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          Expanded(
            child: Text(
              _formatMonthYear(_selectedMonth),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  /// Construye el resumen del mes
  Widget _buildMonthlySummary() {
    final pendingCount = _filteredObligations
        .where((o) => o.status == ObligationStatus.pending)
        .length;
    final completedCount = _filteredObligations
        .where((o) => o.status == ObligationStatus.completed)
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Pendientes',
              pendingCount.toString(),
              AppTheme.warningOrange,
              Icons.pending_actions,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textDisabled,
          ),
          Expanded(
            child: _buildSummaryItem(
              'Completadas',
              completedCount.toString(),
              AppTheme.successGreen,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item del resumen
  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Construye una card de obligación
  Widget _buildObligationCard(_TaxObligation obligation) {
    final isOverdue = obligation.status == ObligationStatus.pending &&
        obligation.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showObligationDetails(obligation),
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono según tipo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTypeColor(obligation.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTypeIcon(obligation.type),
                        color: _getTypeColor(obligation.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            obligation.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Badge de estado
                    _buildStatusBadge(obligation.status, isOverdue),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Fecha y monto
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isOverdue
                              ? AppTheme.errorRed
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(obligation.dueDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isOverdue
                                        ? AppTheme.errorRed
                                        : AppTheme.textSecondary,
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ],
                    ),
                    if (obligation.amount != null)
                      Text(
                        '\$${obligation.amount!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryMagenta,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el badge de estado
  Widget _buildStatusBadge(ObligationStatus status, bool isOverdue) {
    final Color color;
    final String label;
    final IconData icon;

    if (isOverdue) {
      color = AppTheme.errorRed;
      label = 'Vencida';
      icon = Icons.error;
    } else {
      switch (status) {
        case ObligationStatus.completed:
          color = AppTheme.successGreen;
          label = 'Completada';
          icon = Icons.check_circle;
          break;
        case ObligationStatus.pending:
          color = AppTheme.warningOrange;
          label = 'Pendiente';
          icon = Icons.pending;
          break;
        case ObligationStatus.upcoming:
          color = AppTheme.infoBlue;
          label = 'Próxima';
          icon = Icons.schedule;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: AppTheme.badgeDecoration(color: color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.badgeTextStyle(color: color).copyWith(
              fontSize: 11,
            ),
          ),
        ],
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
              Icons.event_available,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin obligaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay obligaciones fiscales para este mes',
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

  /// Muestra los detalles de una obligación
  void _showObligationDetails(_TaxObligation obligation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    obligation.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              obligation.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Fecha límite', _formatDate(obligation.dueDate)),
            if (obligation.amount != null)
              _buildDetailRow(
                  'Monto', '\$${obligation.amount!.toStringAsFixed(2)}'),
            _buildDetailRow('Tipo', _getTypeLabel(obligation.type)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recordatorio configurado'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Configurar recordatorio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de información
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendario Fiscal'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Qué son las obligaciones fiscales?'),
              SizedBox(height: 8),
              Text(
                'Son los deberes que tienes como contribuyente ante el SAT. '
                'Incluyen declaraciones, pagos y reportes que debes presentar '
                'en fechas específicas.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              SizedBox(height: 16),
              Text('Tipos de obligaciones:'),
              SizedBox(height: 8),
              Text(
                '• Mensuales: Declaraciones cada mes\n'
                '• Anuales: Declaración anual (abril)\n'
                '• Pagos: Impuestos provisionales\n'
                '• Informativas: Reportes al SAT',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Maneja la configuración de recordatorios
  void _handleSetReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de recordatorios próximamente'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  // Helpers

  Color _getTypeColor(ObligationType type) {
    switch (type) {
      case ObligationType.monthly:
        return AppTheme.primaryMagenta;
      case ObligationType.annual:
        return AppTheme.warningOrange;
      case ObligationType.payment:
        return AppTheme.successGreen;
      case ObligationType.informative:
        return AppTheme.infoBlue;
    }
  }

  IconData _getTypeIcon(ObligationType type) {
    switch (type) {
      case ObligationType.monthly:
        return Icons.calendar_month;
      case ObligationType.annual:
        return Icons.date_range;
      case ObligationType.payment:
        return Icons.payments;
      case ObligationType.informative:
        return Icons.info;
    }
  }

  String _getTypeLabel(ObligationType type) {
    switch (type) {
      case ObligationType.monthly:
        return 'Declaración mensual';
      case ObligationType.annual:
        return 'Declaración anual';
      case ObligationType.payment:
        return 'Pago';
      case ObligationType.informative:
        return 'Informativa';
    }
  }

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

  String _formatMonthYear(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Modelos

/// Modelo para obligaciones fiscales
class _TaxObligation {
  final String title;
  final String description;
  final DateTime dueDate;
  final ObligationType type;
  final ObligationStatus status;
  final double? amount;

  _TaxObligation({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.status,
    this.amount,
  });
}

/// Tipos de obligaciones fiscales
enum ObligationType {
  monthly, // Declaración mensual
  annual, // Declaración anual
  payment, // Pago provisional
  informative, // Declaración informativa
}

/// Estados de obligaciones
enum ObligationStatus {
  completed, // Completada
  pending, // Pendiente
  upcoming, // Próxima
}
