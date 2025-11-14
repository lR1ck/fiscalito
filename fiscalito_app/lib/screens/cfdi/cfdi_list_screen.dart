import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Pantalla de lista de facturas (CFDI)
///
/// Muestra todas las facturas/CFDI del usuario organizadas
/// por fecha. Permite ver detalles, filtrar y subir nuevas.
///
/// CFDI = Comprobante Fiscal Digital por Internet (factura electrónica XML)
class CfdiListScreen extends StatefulWidget {
  const CfdiListScreen({super.key});

  @override
  State<CfdiListScreen> createState() => _CfdiListScreenState();
}

class _CfdiListScreenState extends State<CfdiListScreen> {
  /// Lista de facturas mock (10 ejemplos variados)
  final List<_CfdiItem> _facturas = [
    _CfdiItem(
      folio: 'A1234567',
      emisor: 'Tienda Electrónica SA de CV',
      monto: 1250.00,
      fecha: DateTime.now().subtract(const Duration(days: 2)),
      tipo: 'Ingreso',
      uuid: '12345678-1234-1234-1234-123456789012',
    ),
    _CfdiItem(
      folio: 'B9876543',
      emisor: 'Servicios Profesionales XYZ',
      monto: 3500.00,
      fecha: DateTime.now().subtract(const Duration(days: 5)),
      tipo: 'Ingreso',
      uuid: '23456789-2345-2345-2345-234567890123',
    ),
    _CfdiItem(
      folio: 'C5555555',
      emisor: 'Papelería y Suministros del Centro',
      monto: 450.50,
      fecha: DateTime.now().subtract(const Duration(days: 7)),
      tipo: 'Egreso',
      uuid: '34567890-3456-3456-3456-345678901234',
    ),
    _CfdiItem(
      folio: 'D1111111',
      emisor: 'Restaurante El Buen Sabor',
      monto: 280.00,
      fecha: DateTime.now().subtract(const Duration(days: 10)),
      tipo: 'Egreso',
      uuid: '45678901-4567-4567-4567-456789012345',
    ),
    _CfdiItem(
      folio: 'E7777777',
      emisor: 'Desarrollo de Software Innovador SA',
      monto: 8500.00,
      fecha: DateTime.now().subtract(const Duration(days: 12)),
      tipo: 'Ingreso',
      uuid: '56789012-5678-5678-5678-567890123456',
    ),
    _CfdiItem(
      folio: 'F3333333',
      emisor: 'Gasolinera La Estrella',
      monto: 750.00,
      fecha: DateTime.now().subtract(const Duration(days: 15)),
      tipo: 'Egreso',
      uuid: '67890123-6789-6789-6789-678901234567',
    ),
    _CfdiItem(
      folio: 'G9999999',
      emisor: 'Consultoría Empresarial Premium',
      monto: 12000.00,
      fecha: DateTime.now().subtract(const Duration(days: 18)),
      tipo: 'Ingreso',
      uuid: '78901234-7890-7890-7890-789012345678',
    ),
    _CfdiItem(
      folio: 'H4444444',
      emisor: 'Supermercado La Economía',
      monto: 1850.75,
      fecha: DateTime.now().subtract(const Duration(days: 20)),
      tipo: 'Egreso',
      uuid: '89012345-8901-8901-8901-890123456789',
    ),
    _CfdiItem(
      folio: 'I2222222',
      emisor: 'Diseño Gráfico Creativo SC',
      monto: 4200.00,
      fecha: DateTime.now().subtract(const Duration(days: 22)),
      tipo: 'Ingreso',
      uuid: '90123456-9012-9012-9012-901234567890',
    ),
    _CfdiItem(
      folio: 'J8888888',
      emisor: 'Ferretería y Materiales del Norte',
      monto: 3250.50,
      fecha: DateTime.now().subtract(const Duration(days: 25)),
      tipo: 'Egreso',
      uuid: '01234567-0123-0123-0123-012345678901',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sin botón de back porque estamos en bottom nav
        automaticallyImplyLeading: false,
        title: const Text('Mis Facturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtros próximamente'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Búsqueda próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Recargar facturas desde Firestore
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Facturas actualizadas'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: _facturas.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _facturas.length + 1, // +1 para el header
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildSummaryCard();
                  }
                  return _buildFacturaCard(_facturas[index - 1]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a subir factura
          AppRoutes.pushNamed(context, AppRoutes.cfdiUpload);
        },
        icon: const Icon(Icons.add),
        label: const Text('Subir CFDI'),
      ),
    );
  }

  /// Construye el card de resumen
  Widget _buildSummaryCard() {
    final totalIngresos = _facturas
        .where((f) => f.tipo == 'Ingreso')
        .fold(0.0, (sum, f) => sum + f.monto);

    final totalEgresos = _facturas
        .where((f) => f.tipo == 'Egreso')
        .fold(0.0, (sum, f) => sum + f.monto);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(AppTheme.kPaddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del mes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Ingresos',
                  totalIngresos,
                  AppTheme.successGreen,
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Egresos',
                  totalEgresos,
                  AppTheme.errorRed,
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un item del resumen
  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Construye una card de factura
  Widget _buildFacturaCard(_CfdiItem factura) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navegar a detalles de la factura
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ver detalles de ${factura.folio}'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono según tipo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (factura.tipo == 'Ingreso'
                            ? AppTheme.successGreen
                            : AppTheme.errorRed)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    factura.tipo == 'Ingreso'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: factura.tipo == 'Ingreso'
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información de la factura
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factura.emisor,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Folio: ${factura.folio}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(factura.fecha),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Monto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${factura.monto.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: factura.tipo == 'Ingreso'
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MXN',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ],
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
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay facturas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sube tu primera factura para comenzar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar a subir factura
                AppRoutes.pushNamed(context, AppRoutes.cfdiUpload);
              },
              icon: const Icon(Icons.add),
              label: const Text('Subir CFDI'),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea la fecha
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

/// Modelo simple para facturas CFDI
class _CfdiItem {
  final String folio;
  final String emisor;
  final double monto;
  final DateTime fecha;
  final String tipo; // 'Ingreso' o 'Egreso'
  final String uuid; // UUID del CFDI (Folio Fiscal)

  _CfdiItem({
    required this.folio,
    required this.emisor,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.uuid,
  });
}
