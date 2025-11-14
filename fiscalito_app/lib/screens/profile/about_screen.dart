import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de "Acerca de" la aplicación
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryMagenta.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppTheme.primaryMagenta,
              ),
            ),

            const SizedBox(height: 24),

            // Nombre de la app
            Text(
              'Fiscalito',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Versión
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: AppTheme.badgeDecoration(color: AppTheme.infoBlue),
              child: Text(
                'v1.0.0 (MVP)',
                style: AppTheme.badgeTextStyle(color: AppTheme.infoBlue),
              ),
            ),

            const SizedBox(height: 32),

            // Descripción
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu asistente fiscal personal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fiscalito te ayuda a gestionar tus obligaciones fiscales en México '
                    'de manera simple y eficiente. Organiza facturas, recibe recordatorios '
                    'y resuelve dudas sobre el SAT con nuestro asistente AI.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Features
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funcionalidades',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeature(Icons.chat, 'Chat con AI para dudas fiscales'),
                  _buildFeature(Icons.receipt_long, 'Gestión de facturas (CFDI)'),
                  _buildFeature(Icons.calendar_today, 'Calendario de obligaciones'),
                  _buildFeature(Icons.qr_code_scanner, 'Escaneo OCR de tickets'),
                  _buildFeature(
                      Icons.notifications, 'Recordatorios automáticos'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Información del proyecto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Proyecto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfo('Tipo', 'Proyecto Capstone Universitario'),
                  _buildInfo('Desarrollador', '[Tu nombre completo]'),
                  _buildInfo('Universidad', '[Tu universidad]'),
                  _buildInfo('Año', '2025'),
                  _buildInfo('Tecnologías', 'Flutter, Firebase, OpenAI'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botones de acción
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showTechStackDialog(context);
                },
                icon: const Icon(Icons.code),
                label: const Text('Ver stack tecnológico'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo sitio web (simulado)'),
                    ),
                  );
                },
                icon: const Icon(Icons.language),
                label: const Text('Visitar sitio web'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showReportBugDialog(context);
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Reportar un error'),
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            const Text(
              '© 2025 Fiscalito\nProyecto Capstone Universitario',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'Hecho con ❤️ en México',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryMagenta, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTechStackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stack Tecnológico'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTechItem('Frontend', 'Flutter (Dart)'),
              _buildTechItem('Backend', 'Firebase Cloud Functions'),
              _buildTechItem('Base de datos', 'Cloud Firestore'),
              _buildTechItem('Autenticación', 'Firebase Auth'),
              _buildTechItem('AI / Chat', 'OpenAI GPT-4o-mini'),
              _buildTechItem('OCR', 'Google ML Kit / Tesseract'),
              _buildTechItem('Design System', 'Material Design 3'),
              _buildTechItem('State Management', 'Provider'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar error'),
        content: const Text(
          '¿Encontraste un bug?\n\n'
          'Por favor envía un correo a:\nbug-reports@fiscalito.mx\n\n'
          'Incluye:\n'
          '• Descripción del error\n'
          '• Pasos para reproducirlo\n'
          '• Screenshots si es posible',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abriendo cliente de email (simulado)'),
                ),
              );
            },
            child: const Text('Enviar email'),
          ),
        ],
      ),
    );
  }
}
