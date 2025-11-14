import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de política de privacidad
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad de Fiscalito',
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
              'Introducción',
              'En Fiscalito, nos comprometemos a proteger tu privacidad y tus datos personales. '
              'Esta Política de Privacidad describe cómo recopilamos, usamos, almacenamos y protegemos '
              'tu información cuando utilizas nuestra aplicación móvil.',
            ),
            _buildSection(
              context,
              '1. Información que Recopilamos',
              'Recopilamos los siguientes tipos de información:\n\n'
              '• Información de cuenta: Nombre, correo electrónico, RFC, teléfono\n'
              '• Información fiscal: Facturas (CFDI), datos de declaraciones, régimen fiscal\n'
              '• Información de uso: Interacciones con la app, historial de chat con la AI\n'
              '• Información del dispositivo: Tipo de dispositivo, sistema operativo, identificadores únicos\n'
              '• Imágenes: Fotos de tickets que decidas escanear (procesadas con OCR)',
            ),
            _buildSection(
              context,
              '2. Cómo Usamos tu Información',
              'Utilizamos tu información para:\n\n'
              '• Proporcionar los servicios de Fiscalito\n'
              '• Procesar y organizar tus facturas (CFDI)\n'
              '• Enviarte recordatorios de obligaciones fiscales\n'
              '• Responder tus consultas a través del chat con AI\n'
              '• Mejorar la funcionalidad y experiencia de la app\n'
              '• Cumplir con obligaciones legales\n'
              '• Comunicarnos contigo sobre actualizaciones importantes',
            ),
            _buildSection(
              context,
              '3. Compartir Información',
              'No vendemos tu información personal. Solo compartimos tus datos con:\n\n'
              '• Proveedores de servicios: Firebase (Google) para almacenamiento, OpenAI para chat con AI\n'
              '• Autoridades fiscales: Solo cuando sea requerido por ley\n'
              '• Terceros autorizados: Solo con tu consentimiento explícito',
            ),
            _buildSection(
              context,
              '4. Seguridad de Datos',
              'Implementamos medidas de seguridad para proteger tu información:\n\n'
              '• Encriptación de datos en tránsito (TLS/SSL)\n'
              '• Encriptación de datos en reposo\n'
              '• Autenticación segura con Firebase Auth\n'
              '• Acceso restringido a datos personales\n'
              '• Auditorías de seguridad periódicas\n\n'
              'Sin embargo, ningún sistema es 100% seguro. Te recomendamos usar contraseñas fuertes '
              'y no compartir tu información de acceso.',
            ),
            _buildSection(
              context,
              '5. Tus Derechos',
              'Tienes derecho a:\n\n'
              '• Acceder a tu información personal\n'
              '• Rectificar datos incorrectos\n'
              '• Cancelar tu cuenta y eliminar tus datos\n'
              '• Oponerte al procesamiento de tus datos\n'
              '• Limitar el uso de tu información\n'
              '• Portabilidad de datos\n\n'
              'Para ejercer estos derechos, contacta a: privacidad@fiscalito.mx',
            ),
            _buildSection(
              context,
              '6. Retención de Datos',
              'Conservamos tu información mientras:\n\n'
              '• Tu cuenta esté activa\n'
              '• Sea necesario para proporcionar nuestros servicios\n'
              '• Estemos obligados por ley a conservarla\n\n'
              'Cuando elimines tu cuenta, borraremos tu información personal en un plazo de 30 días, '
              'excepto la información que debamos conservar por obligaciones legales.',
            ),
            _buildSection(
              context,
              '7. Cookies y Tecnologías Similares',
              'Fiscalito utiliza:\n\n'
              '• Cookies de sesión: Para mantener tu sesión activa\n'
              '• Analytics: Para entender cómo usas la app (Google Analytics)\n'
              '• Identificadores de dispositivo: Para soporte técnico\n\n'
              'Puedes gestionar las preferencias de cookies en la configuración de tu dispositivo.',
            ),
            _buildSection(
              context,
              '8. Menores de Edad',
              'Fiscalito no está diseñado para menores de 18 años. '
              'No recopilamos intencionalmente información de menores. '
              'Si descubrimos que hemos recopilado datos de un menor, los eliminaremos de inmediato.',
            ),
            _buildSection(
              context,
              '9. Cambios a Esta Política',
              'Podemos actualizar esta Política de Privacidad ocasionalmente. '
              'Te notificaremos sobre cambios significativos por correo electrónico o mediante '
              'una notificación en la app. La fecha de "Última actualización" se modificará '
              'en la parte superior de esta política.',
            ),
            _buildSection(
              context,
              '10. Contacto',
              'Si tienes preguntas sobre esta Política de Privacidad, contáctanos:\n\n'
              '• Email: privacidad@fiscalito.mx\n'
              '• Teléfono: +52 55 1234 5678\n'
              '• Dirección: Ciudad de México, México',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppTheme.successGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu privacidad es nuestra prioridad',
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
