import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

/// Pantalla de detalles del RFC
///
/// Muestra información completa del RFC del usuario
class RFCDetailsScreen extends StatelessWidget {
  const RFCDetailsScreen({super.key});

  // Datos mock
  static const String _rfc = 'XAXX010101000';
  static const String _nombreFiscal = 'JUAN PÉREZ GARCÍA';
  static const String _regimen = 'RESICO - Régimen Simplificado de Confianza';
  static const String _estatus = 'Activo';
  static const String _domicilio = 'Calle Falsa 123, Col. Centro\nCiudad de México, CDMX\nCP: 06000';
  static const String _fechaInicio = '01 de enero, 2020';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
        child: Column(
          children: [
            // Card principal del RFC
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryMagenta, Color(0xFFD6004C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.badge,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'RFC',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _rfc,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      IconButton(
                        onPressed: () => _copyRFC(context),
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                        tooltip: 'Copiar RFC',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nombreFiscal,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Información detallada
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.account_balance,
                    label: 'Régimen Fiscal',
                    value: _regimen,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    context,
                    icon: Icons.verified,
                    label: 'Estatus',
                    value: _estatus,
                    valueColor: AppTheme.successGreen,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Fecha de inicio',
                    value: _fechaInicio,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    context,
                    icon: Icons.location_on,
                    label: 'Domicilio Fiscal',
                    value: _domicilio,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón descargar constancia
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadConstancia(context),
                icon: const Icon(Icons.download),
                label: const Text('Descargar Constancia de Situación Fiscal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón verificar en SAT
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _verifyInSAT(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Verificar en portal del SAT'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryMagenta),
          const SizedBox(width: 16),
          Expanded(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyRFC(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _rfc));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('RFC copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadConstancia(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de descarga próximamente'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _verifyInSAT(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo portal del SAT (simulado)'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué es el RFC?'),
        content: const SingleChildScrollView(
          child: Text(
            'El RFC (Registro Federal de Contribuyentes) es tu identificador fiscal único en México.\n\n'
            'Contiene:\n'
            '• 4 letras de tu nombre\n'
            '• 6 dígitos de tu fecha de nacimiento\n'
            '• 3 caracteres de homoclave\n\n'
            'Es necesario para cualquier actividad fiscal ante el SAT.',
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
}
