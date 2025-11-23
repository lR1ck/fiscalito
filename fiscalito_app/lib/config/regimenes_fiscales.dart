/// Catálogo de regímenes fiscales del SAT
///
/// Contiene la lista oficial de regímenes fiscales para personas físicas
/// en México, con sus códigos y descripciones.
///
/// Fuente: Catálogo c_RegimenFiscal del SAT
/// https://www.sat.gob.mx/consulta/35025/formato-de-factura-electronica-(anexo-20)

/// Modelo para representar un régimen fiscal
class RegimenFiscal {
  /// Código oficial del SAT (ej: "605", "626")
  final String codigo;

  /// Nombre corto del régimen (ej: "RESICO")
  final String nombre;

  /// Descripción completa del régimen
  final String descripcion;

  const RegimenFiscal({
    required this.codigo,
    required this.nombre,
    required this.descripcion,
  });

  /// Retorna el régimen formateado como "CÓDIGO - Nombre"
  String get formateado => '$codigo - $nombre';

  @override
  String toString() => formateado;
}

/// Lista de regímenes fiscales disponibles para personas físicas
///
/// Ordenados por frecuencia de uso común.
/// Esta lista puede ser usada en dropdowns, selectores, etc.
const List<RegimenFiscal> regimenesFiscales = [
  RegimenFiscal(
    codigo: '605',
    nombre: 'Sueldos y Salarios',
    descripcion:
        'Para personas que reciben ingresos por trabajar como empleados. '
        'El patrón retiene y paga los impuestos.',
  ),
  RegimenFiscal(
    codigo: '606',
    nombre: 'Arrendamiento',
    descripcion:
        'Para personas que rentan bienes inmuebles (casas, locales, terrenos). '
        'Permite deducciones del 35% sin comprobantes.',
  ),
  RegimenFiscal(
    codigo: '612',
    nombre: 'Actividad Empresarial y Profesional',
    descripcion:
        'Para freelancers, profesionistas independientes y negocios pequeños. '
        'Permite deducir gastos relacionados con la actividad.',
  ),
  RegimenFiscal(
    codigo: '626',
    nombre: 'RESICO',
    descripcion:
        'Régimen Simplificado de Confianza. Tasas reducidas del 1% al 2.5% '
        'sobre ingresos. Para quienes ganan menos de \$3.5 millones al año.',
  ),
  RegimenFiscal(
    codigo: '607',
    nombre: 'Enajenación o Adquisición de Bienes',
    descripcion:
        'Para personas que venden bienes inmuebles o adquieren bienes '
        'por donación, herencia o prescripción.',
  ),
  RegimenFiscal(
    codigo: '608',
    nombre: 'Demás Ingresos',
    descripcion:
        'Para ingresos esporádicos que no encajan en otros regímenes: '
        'premios, herencias, intereses, dividendos, etc.',
  ),
  RegimenFiscal(
    codigo: '611',
    nombre: 'Ingresos por Dividendos',
    descripcion:
        'Para personas que reciben dividendos o utilidades de empresas '
        'en las que son socios o accionistas.',
  ),
  RegimenFiscal(
    codigo: '614',
    nombre: 'Ingresos por Intereses',
    descripcion:
        'Para personas que obtienen ingresos por intereses bancarios, '
        'inversiones o préstamos realizados.',
  ),
  RegimenFiscal(
    codigo: '616',
    nombre: 'Sin Obligaciones Fiscales',
    descripcion:
        'Para personas que no realizan actividades económicas o están '
        'exentas de obligaciones fiscales.',
  ),
  RegimenFiscal(
    codigo: '625',
    nombre: 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras',
    descripcion:
        'Para personas dedicadas al sector primario: agricultura, ganadería, '
        'pesca, silvicultura. Tiene exenciones especiales.',
  ),
];

/// Busca un régimen fiscal por su código
///
/// Retorna null si no se encuentra.
/// Ejemplo: findRegimenByCodigo('626') retorna RESICO
RegimenFiscal? findRegimenByCodigo(String codigo) {
  try {
    return regimenesFiscales.firstWhere((r) => r.codigo == codigo);
  } catch (e) {
    return null;
  }
}

/// Busca un régimen fiscal por su nombre (búsqueda parcial, case-insensitive)
///
/// Retorna null si no se encuentra.
/// Ejemplo: findRegimenByNombre('resico') retorna RESICO
RegimenFiscal? findRegimenByNombre(String nombre) {
  try {
    final nombreLower = nombre.toLowerCase();
    return regimenesFiscales.firstWhere(
      (r) => r.nombre.toLowerCase().contains(nombreLower),
    );
  } catch (e) {
    return null;
  }
}

/// Retorna la lista de regímenes como Maps (útil para dropdowns simples)
List<Map<String, String>> get regimenesFiscalesComoMaps {
  return regimenesFiscales
      .map((r) => {'codigo': r.codigo, 'nombre': r.nombre})
      .toList();
}
