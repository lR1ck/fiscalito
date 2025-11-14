import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de centro de ayuda con FAQs
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // FAQs
  static final List<_FAQ> _faqs = [
    _FAQ(
      question: '¿Qué es el RFC y cómo obtenerlo?',
      answer:
          'El RFC (Registro Federal de Contribuyentes) es tu identificador fiscal único en México. '
          'Para obtenerlo:\n\n'
          '1. Ingresa al portal del SAT (sat.gob.mx)\n'
          '2. Selecciona "Trámites del RFC"\n'
          '3. Elige "Inscripción al RFC"\n'
          '4. Completa el formulario con tus datos\n'
          '5. Sube tu identificación oficial\n'
          '6. Recibe tu Cédula de Identificación Fiscal\n\n'
          'El trámite es gratuito y tarda aproximadamente 1-3 días hábiles.',
    ),
    _FAQ(
      question: '¿Cuándo debo presentar mi declaración?',
      answer:
          'Las fechas de declaración dependen de tu régimen fiscal:\n\n'
          'Declaración mensual:\n'
          '• Día 17 de cada mes (para el mes anterior)\n'
          '• La fecha exacta puede variar según el 6to dígito de tu RFC\n\n'
          'Declaración anual:\n'
          '• Personas físicas: Abril (del 1 al 30)\n'
          '• Personas morales: Marzo (del 1 al 31)\n\n'
          'Te recomendamos activar recordatorios en Fiscalito para no olvidar ninguna fecha.',
    ),
    _FAQ(
      question: '¿Qué es un CFDI?',
      answer:
          'El CFDI (Comprobante Fiscal Digital por Internet) es una factura electrónica obligatoria en México.\n\n'
          'Características:\n'
          '• Es un archivo XML con firma digital\n'
          '• Contiene todos los datos de la transacción\n'
          '• Es válido ante el SAT\n'
          '• Se puede verificar su autenticidad en línea\n\n'
          'Partes de un CFDI:\n'
          '• Folio Fiscal (UUID): Identificador único\n'
          '• Datos del emisor y receptor\n'
          '• Conceptos facturados\n'
          '• Impuestos aplicados\n'
          '• Sello digital del SAT\n\n'
          'En Fiscalito puedes subir y organizar todos tus CFDIs.',
    ),
    _FAQ(
      question: '¿Cómo cambio mi régimen fiscal?',
      answer:
          'Para cambiar de régimen fiscal:\n\n'
          '1. Verifica que cumples con los requisitos del nuevo régimen\n'
          '2. Ingresa al portal del SAT con tu e.firma\n'
          '3. Busca "Actualización de régimen fiscal"\n'
          '4. Selecciona el nuevo régimen\n'
          '5. Presenta el aviso dentro de los primeros 30 días del año\n\n'
          'Importante:\n'
          '• Consulta con un contador antes de cambiar\n'
          '• El cambio es solo una vez al año\n'
          '• Algunos regímenes tienen requisitos específicos\n\n'
          'Te recomendamos usar el chat de Fiscalito para resolver dudas específicas.',
    ),
    _FAQ(
      question: '¿Qué pasa si no declaro a tiempo?',
      answer:
          'No presentar tu declaración a tiempo tiene consecuencias:\n\n'
          'Multas:\n'
          '• De \$1,810 a \$22,400 pesos\n'
          '• Aumentan mientras más tiempo pase\n'
          '• Se calculan en UMAs (Unidad de Medida y Actualización)\n\n'
          'Otras consecuencias:\n'
          '• Opinión de cumplimiento negativa\n'
          '• Imposibilidad de obtener créditos\n'
          '• Problemas para trámites oficiales\n'
          '• Posibles auditorías del SAT\n\n'
          'Recomendaciones:\n'
          '• Activa recordatorios en Fiscalito\n'
          '• Si olvidaste declarar, hazlo lo antes posible\n'
          '• Las multas son menores si declaras voluntariamente',
    ),
    _FAQ(
      question: '¿Qué es el RESICO?',
      answer:
          'El RESICO (Régimen Simplificado de Confianza) es un esquema fiscal creado en 2022.\n\n'
          'Ventajas:\n'
          '• Tasas reducidas (1% a 2.5%)\n'
          '• Declaraciones más simples\n'
          '• Menos requisitos contables\n'
          '• Sin pagos provisionales complejos\n\n'
          'Requisitos:\n'
          '• Ingresos menores a \$3.5 millones anuales\n'
          '• No ser socio de otra persona moral\n'
          '• No operar a través de fideicomisos\n\n'
          'Puedes consultar más detalles en tu perfil > Régimen Fiscal.',
    ),
    _FAQ(
      question: '¿Cómo puedo contactar al SAT?',
      answer:
          'Canales de contacto del SAT:\n\n'
          'Teléfono:\n'
          '• Marcatel: 55 627 22 728\n'
          '• Desde el interior: 01 800 46 36 728\n'
          '• Horario: Lunes a viernes 8:00 - 18:00 hrs\n\n'
          'En línea:\n'
          '• Portal: sat.gob.mx\n'
          '• Chat en línea (portal del SAT)\n'
          '• Twitter: @SATMX\n\n'
          'Presencial:\n'
          '• Acude a una oficina del SAT con cita\n'
          '• Agenda en: citas.sat.gob.mx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 48,
                    color: AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Preguntas Frecuentes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Encuentra respuestas a las dudas más comunes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FAQs expandibles
          ...List.generate(_faqs.length, (index) {
            return _FAQTile(faq: _faqs[index]);
          }),

          const SizedBox(height: 32),

          // Botón de contacto
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryMagenta.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryMagenta.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '¿No encontraste respuesta?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _showContactOptions(context);
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contactar soporte'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Contactar soporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryMagenta),
              title: const Text('Email'),
              subtitle: const Text('soporte@fiscalito.mx'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Abriendo cliente de email (simulado)'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.successGreen),
              title: const Text('WhatsApp'),
              subtitle: const Text('+52 55 1234 5678'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Abriendo WhatsApp (simulado)'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget para FAQ expandible
class _FAQTile extends StatelessWidget {
  final _FAQ faq;

  const _FAQTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(
            Icons.help_outline,
            color: AppTheme.primaryMagenta,
          ),
          title: Text(
            faq.question,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [
            Text(
              faq.answer,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo para FAQ
class _FAQ {
  final String question;
  final String answer;

  _FAQ({required this.question, required this.answer});
}
