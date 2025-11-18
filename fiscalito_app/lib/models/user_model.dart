import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos del usuario
///
/// Representa la información fiscal del usuario en Fiscalito.
/// Se sincroniza con Firebase Auth (uid) y Firestore (datos adicionales).
///
/// Campos principales:
/// - uid: ID único de Firebase Auth
/// - name: Nombre completo del usuario
/// - email: Correo electrónico
/// - rfc: Registro Federal de Contribuyentes (13 caracteres)
/// - createdAt: Fecha de registro en la app
/// - updatedAt: Última actualización de datos
class UserModel {
  /// ID único del usuario (Firebase Auth UID)
  final String uid;

  /// Nombre completo del usuario
  final String name;

  /// Correo electrónico
  final String email;

  /// RFC (Registro Federal de Contribuyentes)
  /// Formato: 13 caracteres alfanuméricos
  /// Ejemplo: XAXX010101000
  final String rfc;

  /// Fecha de creación del usuario
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  /// Constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.rfc,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un UserModel desde un Map (usado al leer de Firestore)
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  /// final user = UserModel.fromMap(doc.data()!, uid);
  /// ```
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      rfc: map['rfc'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Crea un UserModel desde un DocumentSnapshot de Firestore
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  /// final user = UserModel.fromFirestore(doc);
  /// ```
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  /// Convierte el UserModel a un Map (usado al escribir en Firestore)
  ///
  /// No incluye el uid porque se usa como ID del documento.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await FirebaseFirestore.instance
  ///     .collection('users')
  ///     .doc(user.uid)
  ///     .set(user.toMap());
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'rfc': rfc,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crea una copia del UserModel con campos actualizados
  ///
  /// Útil para actualizar parcialmente el modelo sin crear uno nuevo.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final updatedUser = currentUser.copyWith(name: 'Nuevo Nombre');
  /// ```
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? rfc,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      rfc: rfc ?? this.rfc,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el UserModel a String para debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, rfc: $rfc)';
  }

  /// Compara dos UserModel por igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.rfc == rfc;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        rfc.hashCode;
  }
}
