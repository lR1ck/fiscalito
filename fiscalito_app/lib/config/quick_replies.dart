/// Helper para sugerencias rápidas (quick replies) en el chat
///
/// Proporciona preguntas predeterminadas contextualizadas según el
/// régimen fiscal del usuario para mejorar la experiencia del chat.
class QuickRepliesHelper {
  /// Obtiene las quick replies según el régimen fiscal del usuario
  ///
  /// [regimenFiscalCodigo] Código del régimen fiscal (ej: "626", "605", "601")
  ///
  /// Retorna una lista de 3-4 strings con preguntas relevantes.
  /// Si el código no se reconoce o está vacío, retorna preguntas generales.
  static List<String> getQuickReplies(String regimenFiscalCodigo) {
    switch (regimenFiscalCodigo) {
      // RESICO - Régimen Simplificado de Confianza
      case '626':
        return [
          '¿Cómo calculo mi ISR bimestral?',
          '¿Qué gastos puedo deducir?',
          '¿Cuándo declaro?',
          '¿Cómo funciona RESICO?',
        ];

      // Sueldos y Salarios
      case '605':
        return [
          '¿Qué deducciones personales aplican?',
          '¿Cómo hacer declaración anual?',
          '¿Qué es la precarga?',
          '¿Cómo calcular mi ISR?',
        ];

      // Régimen General de Ley Personas Morales
      case '601':
        return [
          '¿Cómo calcular IVA?',
          '¿Qué es cuenta de IVA?',
          'Diferencia con RESICO',
          '¿Deducciones autorizadas?',
        ];

      // Actividades Empresariales y Profesionales
      case '612':
        return [
          '¿Cómo declarar mis ingresos?',
          '¿Qué deducciones aplican?',
          '¿Diferencia con RESICO?',
          '¿Cómo calcular mi ISR?',
        ];

      // Arrendamiento
      case '606':
        return [
          '¿Cómo declarar rentas?',
          '¿Qué gastos puedo deducir?',
          '¿Cuál es la tasa de ISR?',
          '¿Cómo emitir recibos de arrendamiento?',
        ];

      // Incorporación Fiscal (aunque este régimen ya no existe, algunos usuarios pueden tenerlo)
      case '621':
        return [
          '¿Este régimen sigue vigente?',
          '¿Debo cambiarme a RESICO?',
          '¿Cómo migrar de régimen?',
          '¿Qué es RESICO?',
        ];

      // Sin régimen configurado o régimen no reconocido
      default:
        return [
          '¿Qué régimen fiscal me conviene?',
          '¿Cómo elegir régimen?',
          '¿Qué es el RFC?',
          '¿Qué es RESICO?',
        ];
    }
  }

  /// Obtiene quick replies genéricas (para cuando no hay régimen fiscal)
  ///
  /// Útil cuando el usuario no tiene régimen configurado o cuando
  /// se quiere mostrar preguntas básicas.
  static List<String> getGenericQuickReplies() {
    return getQuickReplies(''); // Retorna las del default case
  }

  /// Verifica si un código de régimen fiscal es válido/reconocido
  ///
  /// [regimenFiscalCodigo] Código del régimen fiscal a verificar
  ///
  /// Retorna true si el código tiene quick replies específicas, false si no.
  static bool hasSpecificQuickReplies(String regimenFiscalCodigo) {
    const supportedRegimens = ['626', '605', '601', '612', '606', '621'];
    return supportedRegimens.contains(regimenFiscalCodigo);
  }
}
