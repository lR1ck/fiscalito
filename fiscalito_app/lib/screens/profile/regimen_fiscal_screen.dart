import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de información del régimen fiscal
class RegimenFiscalScreen extends StatelessWidget {
  const RegimenFiscalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Régimen Fiscal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card del régimen actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          color: AppTheme.successGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Régimen Actual',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RESICO',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '¿Qué es RESICO?',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'El RESICO (Régimen Simplificado de Confianza) es un esquema fiscal creado en 2022 '
              'para facilitar el cumplimiento de obligaciones fiscales.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),

            const SizedBox(height: 24),

            Text(
              'Beneficios',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            _buildBenefit('Tasas reducidas', '1% a 2.5% sobre ingresos'),
            _buildBenefit('Declaraciones simples', 'Menos requisitos contables'),
            _buildBenefit('Sin contabilidad electrónica', 'Solo registro de ingresos'),
            _buildBenefit('Pagos mensuales menores', 'Sin pagos provisionales'),

            const SizedBox(height: 24),

            Text(
              'Requisitos',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            _buildRequirement('Ingresos menores a \$3.5 millones al año'),
            _buildRequirement('No ser socio o accionista de otra persona moral'),
            _buildRequirement('No realizar actividades por medio de fideicomisos'),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showChangeRegimenDialog(context);
                },
                child: const Text('Cambiar régimen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeRegimenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar régimen fiscal'),
        content: const Text(
          'Para cambiar tu régimen fiscal debes:\n\n'
          '1. Acceder al portal del SAT\n'
          '2. Realizar el trámite de "Actualización de régimen"\n'
          '3. Presentar el aviso dentro de los primeros 30 días de cada año\n\n'
          '¿Quieres más información?',
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
                  content: Text('Consulta a un contador para cambiar de régimen'),
                ),
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
