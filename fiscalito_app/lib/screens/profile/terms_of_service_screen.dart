import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de términos y condiciones
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de Servicio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Términos y Condiciones de Uso',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Última actualización: 14 de diciembre, 2025',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Aceptación de Términos',
              'Al descargar, instalar o usar Fiscalito, aceptas estar sujeto a estos Términos de Servicio. '
              'Si no estás de acuerdo con alguno de estos términos, no uses la aplicación.\n\n'
              'Fiscalito es un proyecto capstone universitario desarrollado con fines educativos y de demostración. '
              'Al usar la app, entiendes que es un MVP (Producto Mínimo Viable) en desarrollo.',
            ),
            _buildSection(
              context,
              '2. Descripción del Servicio',
              'Fiscalito es una aplicación móvil que te ayuda a:\n\n'
              '• Organizar y gestionar tus facturas (CFDI)\n'
              '• Recibir recordatorios de obligaciones fiscales\n'
              '• Consultar dudas fiscales mediante un asistente AI\n'
              '• Escanear tickets físicos con OCR\n'
              '• Consultar información sobre el SAT y temas fiscales de México\n\n'
              'Fiscalito NO es:\n'
              '• Un despacho contable\n'
              '• Un sustituto de un contador profesional\n'
              '• Una plataforma oficial del SAT',
            ),
            _buildSection(
              context,
              '3. Requisitos de Uso',
              'Para usar Fiscalito debes:\n\n'
              '• Ser mayor de 18 años\n'
              '• Tener un RFC válido en México\n'
              '• Proporcionar información veraz y actualizada\n'
              '• Mantener la confidencialidad de tu contraseña\n'
              '• No usar la app con fines ilegales o fraudulentos',
            ),
            _buildSection(
              context,
              '4. Cuentas de Usuario',
              'Eres responsable de:\n\n'
              '• Mantener la seguridad de tu cuenta\n'
              '• Todas las actividades realizadas con tu cuenta\n'
              '• Notificarnos inmediatamente sobre cualquier uso no autorizado\n\n'
              'Nos reservamos el derecho de:\n'
              '• Suspender o terminar cuentas que violen estos términos\n'
              '• Rechazar el servicio a cualquier persona\n'
              '• Eliminar contenido inapropiado',
            ),
            _buildSection(
              context,
              '5. Limitaciones de Responsabilidad',
              'Fiscalito se proporciona "tal cual" sin garantías de ningún tipo.\n\n'
              'No somos responsables por:\n'
              '• Errores en cálculos fiscales\n'
              '• Pérdida de datos\n'
              '• Daños directos o indirectos por el uso de la app\n'
              '• Multas del SAT derivadas del uso incorrecto de la información\n'
              '• Interrupciones del servicio\n\n'
              'IMPORTANTE: Fiscalito NO sustituye la asesoría de un contador profesional. '
              'Para declaraciones oficiales y trámites ante el SAT, consulta a un experto.',
            ),
            _buildSection(
              context,
              '6. Uso de la Inteligencia Artificial',
              'El chat con AI de Fiscalito:\n\n'
              '• Utiliza OpenAI GPT-4o-mini para generar respuestas\n'
              '• Proporciona información general educativa\n'
              '• NO constituye asesoría legal, contable o fiscal profesional\n'
              '• Puede contener errores o información desactualizada\n'
              '• No debe ser tu única fuente de información fiscal\n\n'
              'Siempre verifica información crítica con fuentes oficiales (SAT, contador profesional).',
            ),
            _buildSection(
              context,
              '7. Propiedad Intelectual',
              'Fiscalito y todo su contenido (código, diseño, logos, texto) son propiedad del desarrollador.\n\n'
              'No puedes:\n'
              '• Copiar, modificar o distribuir el código de la app\n'
              '• Usar el nombre "Fiscalito" o sus logos sin permiso\n'
              '• Realizar ingeniería inversa de la aplicación\n\n'
              'Tu contenido (facturas, datos personales) sigue siendo tu propiedad. '
              'Solo nos otorgas una licencia para procesarlo y mostrártelo.',
            ),
            _buildSection(
              context,
              '8. Servicios de Terceros',
              'Fiscalito integra servicios de terceros:\n\n'
              '• Firebase (Google): Autenticación, base de datos, hosting\n'
              '• OpenAI: Chat con inteligencia artificial\n'
              '• Google ML Kit / Tesseract: Reconocimiento óptico de caracteres (OCR)\n\n'
              'Estos servicios tienen sus propios términos y políticas de privacidad que también aplican.',
            ),
            _buildSection(
              context,
              '9. Modificaciones del Servicio',
              'Nos reservamos el derecho de:\n\n'
              '• Modificar o discontinuar cualquier parte de Fiscalito\n'
              '• Cambiar estos Términos en cualquier momento\n'
              '• Agregar o remover funcionalidades\n\n'
              'Te notificaremos sobre cambios significativos por email o notificación en la app.',
            ),
            _buildSection(
              context,
              '10. Terminación',
              'Puedes dejar de usar Fiscalito en cualquier momento eliminando tu cuenta.\n\n'
              'Podemos suspender o terminar tu acceso si:\n'
              '• Violas estos Términos\n'
              '• Usas la app de manera fraudulenta\n'
              '• No pagas (si en el futuro implementamos versión de pago)\n'
              '• Por razones operativas o de seguridad',
            ),
            _buildSection(
              context,
              '11. Ley Aplicable',
              'Estos Términos se rigen por las leyes de México. '
              'Cualquier disputa se resolverá en los tribunales de Ciudad de México, México.',
            ),
            _buildSection(
              context,
              '12. Contacto',
              'Para preguntas sobre estos Términos:\n\n'
              '• Email: legal@fiscalito.mx\n'
              '• Teléfono: +52 55 1234 5678\n'
              '• WhatsApp: +52 55 1234 5678',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.infoBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.infoBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Al continuar usando Fiscalito, aceptas estos Términos de Servicio',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
