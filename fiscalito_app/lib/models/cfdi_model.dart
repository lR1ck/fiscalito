import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para facturas CFDI (Comprobante Fiscal Digital por Internet)
///
/// Representa una factura electrónica mexicana con todos sus datos clave.
/// Se usa para persistir facturas en Firestore y mostrarlas en la UI.
///
/// Estructura en Firestore:
/// ```
/// facturas/
///   {documentId}/
///     userId: String
///     folio: String
///     uuid: String (Folio Fiscal)
///     emisor: String
///     rfcEmisor: String
///     monto: double
///     fecha: Timestamp
///     tipo: String ("Ingreso" o "Egreso")
///     createdAt: Timestamp
/// ```
class CfdiModel {
  /// ID del documento en Firestore (auto-generado)
  final String? id;

  /// UID del usuario dueño de esta factura
  final String userId;

  /// Número de folio de la factura (ej: "A1234567")
  final String folio;

  /// UUID del CFDI / Folio Fiscal (36 caracteres con guiones)
  /// Formato: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  final String uuid;

  /// Nombre del emisor / Razón Social (quien emite la factura)
  final String emisor;

  /// RFC del emisor (12-13 caracteres alfanuméricos)
  final String rfcEmisor;

  /// RFC del receptor (12-13 caracteres alfanuméricos)
  final String rfcReceptor;

  /// Monto total de la factura en MXN
  final double monto;

  /// Fecha de emisión de la factura
  final DateTime fecha;

  /// Tipo de factura: "Ingreso" (dinero que entra) o "Egreso" (dinero que sale)
  final String tipo;

  /// Timestamp de cuándo se subió la factura a la app
  final DateTime createdAt;

  /// Constructor principal
  CfdiModel({
    this.id,
    required this.userId,
    required this.folio,
    required this.uuid,
    required this.emisor,
    required this.rfcEmisor,
    this.rfcReceptor = '',
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.createdAt,
  });

  /// Crea un CfdiModel desde un documento de Firestore
  ///
  /// Convierte los Timestamps de Firestore a DateTime de Dart.
  /// El ID del documento se obtiene del DocumentSnapshot.
  ///
  /// Ejemplo:
  /// ```dart
  /// final doc = await firestore.collection('facturas').doc('abc123').get();
  /// final cfdi = CfdiModel.fromFirestore(doc);
  /// ```
  factory CfdiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CfdiModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      folio: data['folio'] ?? '',
      uuid: data['uuid'] ?? '',
      emisor: data['emisor'] ?? '',
      rfcEmisor: data['rfcEmisor'] ?? '',
      rfcReceptor: data['rfcReceptor'] ?? '',
      monto: (data['monto'] ?? 0.0).toDouble(),
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tipo: data['tipo'] ?? 'Ingreso',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte el modelo a un Map para guardar en Firestore
  ///
  /// Los DateTime se convierten a Timestamp de Firestore.
  /// El campo 'id' NO se incluye (Firestore lo maneja automáticamente).
  ///
  /// Ejemplo:
  /// ```dart
  /// final cfdi = CfdiModel(...);
  /// await firestore.collection('facturas').add(cfdi.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'folio': folio,
      'uuid': uuid,
      'emisor': emisor,
      'rfcEmisor': rfcEmisor,
      'rfcReceptor': rfcReceptor,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      'tipo': tipo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Crea una copia del modelo con algunos campos modificados
  ///
  /// Útil para inmutabilidad. Solo actualiza los campos especificados.
  ///
  /// Ejemplo:
  /// ```dart
  /// final updatedCfdi = originalCfdi.copyWith(
  ///   monto: 500.0,
  ///   tipo: 'Egreso',
  /// );
  /// ```
  CfdiModel copyWith({
    String? id,
    String? userId,
    String? folio,
    String? uuid,
    String? emisor,
    String? rfcEmisor,
    String? rfcReceptor,
    double? monto,
    DateTime? fecha,
    String? tipo,
    DateTime? createdAt,
  }) {
    return CfdiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      folio: folio ?? this.folio,
      uuid: uuid ?? this.uuid,
      emisor: emisor ?? this.emisor,
      rfcEmisor: rfcEmisor ?? this.rfcEmisor,
      rfcReceptor: rfcReceptor ?? this.rfcReceptor,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Retorna true si es una factura de ingreso
  bool get isIngreso => tipo == 'Ingreso';

  /// Retorna true si es una factura de egreso
  bool get isEgreso => tipo == 'Egreso';

  @override
  String toString() {
    return 'CfdiModel(id: $id, folio: $folio, emisor: $emisor, monto: $monto, tipo: $tipo)';
  }
}
