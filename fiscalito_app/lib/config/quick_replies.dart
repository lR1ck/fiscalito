/// Helper para sugerencias rápidas (quick replies) en el chat
///
/// Proporciona preguntas predeterminadas contextualizadas según el
/// régimen fiscal del usuario para mejorar la experiencia del chat.
///
/// Cubre TODOS los regímenes fiscales vigentes del SAT México.
class QuickRepliesHelper {
  /// Obtiene las quick replies según el régimen fiscal del usuario
  ///
  /// [regimenFiscalCodigo] Código del régimen fiscal (ej: "626", "605", "601")
  ///
  /// Retorna una lista de 3-4 strings con preguntas relevantes.
  /// Si el código no se reconoce o está vacío, retorna preguntas generales.
  static List<String> getQuickReplies(String regimenFiscalCodigo) {
    switch (regimenFiscalCodigo) {
      // 601 - Régimen General de Ley Personas Morales
      case '601':
        return [
          '¿Cómo calcular IVA?',
          '¿Qué es cuenta de IVA?',
          'Diferencia con RESICO',
          '¿Deducciones autorizadas?',
        ];

      // 605 - Sueldos y Salarios
      case '605':
        return [
          '¿Qué deducciones personales aplican?',
          '¿Cómo hacer declaración anual?',
          '¿Qué es la precarga?',
          '¿Cómo calcular mi ISR?',
        ];

      // 606 - Arrendamiento
      case '606':
        return [
          '¿Cómo declarar rentas?',
          '¿Qué gastos puedo deducir?',
          '¿Cuál es la tasa de ISR?',
          '¿Cómo emitir recibos de arrendamiento?',
        ];

      // 607 - Régimen de Enajenación o Adquisición de Bienes
      case '607':
        return [
          '¿Cómo declarar venta de inmuebles?',
          '¿Qué es la ganancia por enajenación?',
          '¿Cuándo debo declarar?',
          '¿Qué documentos necesito?',
        ];

      // 608 - Demás Ingresos
      case '608':
        return [
          '¿Qué tipo de ingresos incluye este régimen?',
          '¿Cómo calcular mis impuestos?',
          '¿Cuándo hacer declaración?',
          '¿Ejemplos de "demás ingresos"?',
        ];

      // 610 - Residentes en el Extranjero sin Establecimiento Permanente en México
      case '610':
        return [
          '¿Cómo declarar si vivo fuera de México?',
          '¿Qué obligaciones tengo desde el extranjero?',
          '¿Necesito representante legal en México?',
          '¿Cómo pagar impuestos desde fuera?',
        ];

      // 611 - Ingresos por Dividendos (socios y accionistas)
      case '611':
        return [
          '¿Cómo se gravan los dividendos?',
          '¿Qué es el ISR sobre dividendos?',
          '¿Cuándo debo declarar?',
          '¿La empresa ya retuvo impuestos?',
        ];

      // 612 - Actividades Empresariales y Profesionales
      case '612':
        return [
          '¿Cómo declarar mis ingresos?',
          '¿Qué deducciones aplican?',
          '¿Diferencia con RESICO?',
          '¿Cómo calcular mi ISR?',
        ];

      // 614 - Ingresos por Intereses
      case '614':
        return [
          '¿Cómo declarar ingresos por intereses?',
          '¿Qué es la retención bancaria?',
          '¿Debo presentar declaración anual?',
          '¿Los intereses de CETES se declaran?',
        ];

      // 615 - Régimen de los Ingresos por Obtención de Premios
      case '615':
        return [
          '¿Cómo declarar premios de lotería?',
          '¿Qué porcentaje se retiene?',
          '¿Debo pagar ISR adicional?',
          '¿Los premios de sorteos se declaran?',
        ];

      // 616 - Sin Obligaciones Fiscales
      case '616':
        return [
          '¿Por qué no tengo obligaciones?',
          '¿Puedo emitir facturas?',
          '¿Cómo cambiar de régimen?',
          '¿Necesito declarar algo?',
        ];

      // 621 - Incorporación Fiscal (RIF - RÉGIMEN ELIMINADO EN 2022)
      // NOTA: Este régimen ya NO existe, fue reemplazado por RESICO (626)
      // Se mantiene para usuarios legacy que aún lo tienen registrado
      case '621':
        return [
          '¿Por qué ya no existe el RIF?',
          '¿Cómo migrar a RESICO?',
          '¿Qué régimen me conviene ahora?',
          '¿Cuáles son las ventajas de RESICO?',
        ];

      // 622 - Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras
      // (Variación del 625, puede tener diferencias según caso)
      case '622':
        return [
          '¿Diferencia entre 625 y 622?',
          '¿Cómo declarar mis ingresos?',
          '¿Qué gastos puedo deducir?',
          '¿Cuándo hacer mi declaración?',
        ];

      // 625 - Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras
      // (Actividades Primarias)
      case '625':
        return [
          '¿Cómo declarar ingresos agrícolas?',
          '¿Qué deducciones aplican en actividades primarias?',
          '¿Cuándo hacer mi declaración?',
          '¿Qué es el régimen de actividades primarias?',
        ];

      // 626 - RESICO (Régimen Simplificado de Confianza)
      // NOTA: Este es el régimen más común desde 2022, reemplazó al RIF
      case '626':
        return [
          '¿Cómo calculo mi ISR bimestral?',
          '¿Qué gastos puedo deducir?',
          '¿Cuándo declaro?',
          '¿Cómo funciona RESICO?',
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
    const supportedRegimens = [
      '601', // Régimen General de Ley Personas Morales
      '605', // Sueldos y Salarios
      '606', // Arrendamiento
      '607', // Enajenación o Adquisición de Bienes
      '608', // Demás Ingresos
      '610', // Residentes en el Extranjero
      '611', // Ingresos por Dividendos
      '612', // Actividades Empresariales y Profesionales
      '614', // Ingresos por Intereses
      '615', // Ingresos por Obtención de Premios
      '616', // Sin Obligaciones Fiscales
      '621', // Incorporación Fiscal (RIF - Eliminado, legacy)
      '622', // Actividades Agrícolas (variación)
      '625', // Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras
      '626', // RESICO (Régimen Simplificado de Confianza)
    ];
    return supportedRegimens.contains(regimenFiscalCodigo);
  }

  /// Obtiene el nombre completo del régimen fiscal por su código
  ///
  /// [regimenFiscalCodigo] Código del régimen fiscal (ej: "626")
  ///
  /// Retorna el nombre descriptivo del régimen o "Régimen desconocido".
  /// Útil para mostrar información adicional al usuario.
  static String getRegimenName(String regimenFiscalCodigo) {
    switch (regimenFiscalCodigo) {
      case '601':
        return 'Régimen General de Ley Personas Morales';
      case '605':
        return 'Sueldos y Salarios';
      case '606':
        return 'Arrendamiento';
      case '607':
        return 'Enajenación o Adquisición de Bienes';
      case '608':
        return 'Demás Ingresos';
      case '610':
        return 'Residentes en el Extranjero';
      case '611':
        return 'Ingresos por Dividendos';
      case '612':
        return 'Actividades Empresariales y Profesionales';
      case '614':
        return 'Ingresos por Intereses';
      case '615':
        return 'Ingresos por Obtención de Premios';
      case '616':
        return 'Sin Obligaciones Fiscales';
      case '621':
        return 'Incorporación Fiscal (RIF - Eliminado)';
      case '622':
        return 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras';
      case '625':
        return 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras';
      case '626':
        return 'RESICO (Régimen Simplificado de Confianza)';
      default:
        return 'Régimen desconocido';
    }
  }
}
