import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/cfdi_model.dart';
import '../../services/firestore_service.dart';

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
  /// Servicio de Firestore
  final _firestoreService = FirestoreService();

  /// Filtro actual ('Todas', 'Ingresos', 'Egresos')
  String _filtroActual = 'Todas';

  @override
  Widget build(BuildContext context) {
    // Obtener UID del usuario actual
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis Facturas'),
        ),
        body: const Center(
          child: Text('Error: Usuario no autenticado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Sin botón de back porque estamos en bottom nav
        automaticallyImplyLeading: false,
        title: const Text('Mis Facturas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtroActual = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todas',
                child: Text('Todas las facturas'),
              ),
              const PopupMenuItem(
                value: 'Ingresos',
                child: Text('Solo Ingresos'),
              ),
              const PopupMenuItem(
                value: 'Egresos',
                child: Text('Solo Egresos'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<CfdiModel>>(
        stream: _firestoreService.getFacturasStream(user.uid),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryMagenta,
                ),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar facturas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
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

          // Obtener facturas del snapshot
          final todasFacturas = snapshot.data ?? [];

          // Aplicar filtro
          final facturas = _aplicarFiltro(todasFacturas);

          // Empty state
          if (facturas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // El StreamBuilder se refrescará automáticamente
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: _buildEmptyState(),
            );
          }

          // Lista de facturas
          return RefreshIndicator(
            onRefresh: () async {
              // El StreamBuilder se refrescará automáticamente
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facturas actualizadas'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: facturas.length + 1, // +1 para el header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSummaryCard(todasFacturas);
                }
                return _buildFacturaCard(facturas[index - 1]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a subir factura
          AppRoutes.pushNamed(context, AppRoutes.cfdiUpload);
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar CFDI'),
      ),
    );
  }

  /// Aplica el filtro actual a la lista de facturas
  List<CfdiModel> _aplicarFiltro(List<CfdiModel> facturas) {
    switch (_filtroActual) {
      case 'Ingresos':
        return facturas.where((f) => f.tipo == 'Ingreso').toList();
      case 'Egresos':
        return facturas.where((f) => f.tipo == 'Egreso').toList();
      default:
        return facturas;
    }
  }

  /// Construye el card de resumen
  Widget _buildSummaryCard(List<CfdiModel> facturas) {
    final totalIngresos = facturas
        .where((f) => f.tipo == 'Ingreso')
        .fold<double>(0.0, (sum, f) => sum + f.monto);

    final totalEgresos = facturas
        .where((f) => f.tipo == 'Egreso')
        .fold<double>(0.0, (sum, f) => sum + f.monto);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(AppTheme.kPaddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_filtroActual != 'Todas')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMagenta.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryMagenta,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _filtroActual,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryMagenta,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
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
  Widget _buildFacturaCard(CfdiModel factura) {
    return Dismissible(
      key: Key(factura.id ?? factura.uuid),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(factura),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFacturaDetails(factura),
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return ListView(
      // Wrap en ListView para que RefreshIndicator funcione
      padding: const EdgeInsets.all(32),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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
                _filtroActual == 'Todas'
                    ? 'No hay facturas'
                    : 'No hay facturas de $_filtroActual',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _filtroActual == 'Todas'
                    ? 'Agrega tu primera factura para comenzar'
                    : 'Intenta cambiar el filtro',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (_filtroActual == 'Todas') ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navegar a subir factura
                    AppRoutes.pushNamed(context, AppRoutes.cfdiUpload);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar CFDI'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Muestra los detalles de una factura
  void _showFacturaDetails(CfdiModel factura) {
    // Determinar si el emisor es diferente del RFC (tiene nombre real)
    final bool tieneNombreEmisor = factura.emisor.isNotEmpty &&
        factura.emisor != factura.rfcEmisor;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalles de la factura',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow('Folio', factura.folio),
                  _buildDetailRow('UUID', factura.uuid),
                  // Solo mostrar "Emisor" si tiene nombre diferente al RFC
                  if (tieneNombreEmisor)
                    _buildDetailRow('Emisor', factura.emisor),
                  _buildDetailRow('RFC Emisor', factura.rfcEmisor),
                  // Mostrar RFC Receptor si existe
                  if (factura.rfcReceptor.isNotEmpty)
                    _buildDetailRow('RFC Receptor', factura.rfcReceptor),
                  _buildDetailRow(
                    'Monto',
                    '\$${factura.monto.toStringAsFixed(2)} MXN',
                  ),
                  _buildDetailRow('Fecha', _formatDate(factura.fecha)),
                  _buildDetailRow('Tipo', factura.tipo),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final confirmed = await _confirmDelete(factura);
                        if (confirmed == true && factura.id != null) {
                          await _deleteFactura(factura.id!);
                        }
                      },
                      icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                      label: const Text(
                        'Eliminar factura',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorRed),
                      ),
                    ),
                  ),
                  // Espacio extra para scroll
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Construye una fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Confirma la eliminación de una factura
  Future<bool?> _confirmDelete(CfdiModel factura) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: const Text('Eliminar factura'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la factura de ${factura.emisor}?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Elimina una factura de Firestore
  Future<void> _deleteFactura(String facturaId) async {
    try {
      await _firestoreService.deleteFactura(facturaId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Factura eliminada correctamente'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar factura: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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
