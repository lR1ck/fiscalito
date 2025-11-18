import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de escaneo OCR
///
/// Muestra mensaje informativo de que la función de escaneo OCR
/// estará disponible en la versión premium de Fiscalito.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Ticket'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono grande
              Icon(
                Icons.qr_code_scanner,
                size: 120,
                color: AppTheme.textSecondary.withOpacity(0.3),
              ),

              const SizedBox(height: 32),

              // Título
              const Text(
                'Función Premium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Descripción
              const Text(
                'El escaneo de tickets con OCR estará disponible en la versión premium de Fiscalito.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Badge "Próximamente"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMagenta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryMagenta,
                    width: 1,
                  ),
                ),
                child: const Text(
                  '🚀 Próximamente',
                  style: TextStyle(
                    color: AppTheme.primaryMagenta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
                  border: Border.all(
                    color: AppTheme.infoBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.infoBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Características Premium',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.infoBlue,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      'Escaneo OCR de tickets físicos',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      'Extracción automática de datos',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      'Reconocimiento de RFC y montos',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      'Historial ilimitado de escaneos',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón para regresar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un item de característica premium
  Widget _buildFeatureItem(BuildContext context, String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: AppTheme.successGreen,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
