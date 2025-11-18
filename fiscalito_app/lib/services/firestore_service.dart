import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Servicio para interactuar con Firestore
///
/// Maneja todas las operaciones de base de datos en Firestore:
/// - Guardar datos de usuario
/// - Obtener datos de usuario
/// - Actualizar perfil
/// - Eliminar datos
///
/// Estructura de Firestore:
/// ```
/// users/
///   {uid}/
///     name: String
///     email: String
///     rfc: String
///     createdAt: Timestamp
///     updatedAt: Timestamp
/// ```
///
/// Uso:
/// ```dart
/// final firestoreService = FirestoreService();
/// await firestoreService.createUser(userModel);
/// ```
class FirestoreService {
  /// Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nombre de la colección de usuarios en Firestore
  static const String _usersCollection = 'users';

  /// Crea un nuevo documento de usuario en Firestore
  ///
  /// Parámetro:
  /// - user: UserModel con los datos a guardar
  ///
  /// Guarda todos los datos del usuario (excepto uid, que se usa como ID del documento).
  /// Si el documento ya existe, será sobrescrito.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final user = UserModel(
  ///   uid: firebaseUser.uid,
  ///   name: 'Juan Pérez',
  ///   email: 'juan@example.com',
  ///   rfc: 'XAXX010101000',
  ///   createdAt: DateTime.now(),
  ///   updatedAt: DateTime.now(),
  /// );
  /// await firestoreService.createUser(user);
  /// ```
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw 'Error al crear usuario en Firestore: $e';
    }
  }

  /// Obtiene los datos de un usuario por su UID
  ///
  /// Parámetro:
  /// - uid: ID único del usuario (Firebase Auth UID)
  ///
  /// Retorna un UserModel si el usuario existe, o null si no existe.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final user = await firestoreService.getUser('abc123uid');
  /// if (user != null) {
  ///   print('Usuario encontrado: ${user.name}');
  /// } else {
  ///   print('Usuario no encontrado');
  /// }
  /// ```
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener usuario de Firestore: $e';
    }
  }

  /// Stream que escucha cambios en tiempo real del usuario
  ///
  /// Parámetro:
  /// - uid: ID único del usuario
  ///
  /// Retorna un Stream que emite un UserModel cada vez que el documento cambia.
  /// Útil para mantener la UI sincronizada con Firestore.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// firestoreService.getUserStream('abc123uid').listen((user) {
  ///   if (user != null) {
  ///     print('Datos actualizados: ${user.name}');
  ///   }
  /// });
  /// ```
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    });
  }

  /// Actualiza los datos de un usuario existente
  ///
  /// Parámetros:
  /// - uid: ID único del usuario
  /// - data: Map con los campos a actualizar
  ///
  /// Solo actualiza los campos especificados en el Map, sin tocar los demás.
  /// Automáticamente actualiza el campo 'updatedAt' con el timestamp actual.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await firestoreService.updateUser('abc123uid', {
  ///   'name': 'Nuevo Nombre',
  ///   'rfc': 'NUEVO1234567890',
  /// });
  /// ```
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      // Agregar timestamp de actualización
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw 'Error al actualizar usuario en Firestore: $e';
    }
  }

  /// Actualiza el perfil completo del usuario
  ///
  /// Parámetro:
  /// - user: UserModel con los datos actualizados
  ///
  /// Sobrescribe todos los datos del usuario con los del UserModel.
  /// Usa update() en lugar de set() para preservar campos que no están en el modelo.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final updatedUser = currentUser.copyWith(
  ///   name: 'Nombre Actualizado',
  ///   updatedAt: DateTime.now(),
  /// );
  /// await firestoreService.updateUserProfile(updatedUser);
  /// ```
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw 'Error al actualizar perfil en Firestore: $e';
    }
  }

  /// Elimina el documento de usuario de Firestore
  ///
  /// Parámetro:
  /// - uid: ID único del usuario a eliminar
  ///
  /// PELIGROSO: Esta acción es irreversible.
  /// Asegúrate de que el usuario realmente quiere eliminar su cuenta.
  ///
  /// IMPORTANTE: Esto solo elimina el documento de Firestore.
  /// Debes usar FirebaseAuthService.deleteUser() para eliminar
  /// la cuenta de Firebase Auth también.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// // Confirmar con el usuario primero
  /// if (userConfirmed) {
  ///   await firestoreService.deleteUser('abc123uid');
  ///   await authService.deleteUser();
  /// }
  /// ```
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw 'Error al eliminar usuario de Firestore: $e';
    }
  }

  /// Verifica si existe un usuario con el RFC especificado
  ///
  /// Parámetro:
  /// - rfc: RFC a buscar (se normaliza a mayúsculas sin espacios)
  ///
  /// Retorna true si existe un usuario con ese RFC, false si no.
  ///
  /// Útil para validar que el RFC no esté duplicado durante el registro.
  ///
  /// NOTA: Requiere un índice compuesto en Firestore.
  /// Firebase te mostrará un link para crearlo en los logs si no existe.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final exists = await firestoreService.rfcExists('XAXX010101000');
  /// if (exists) {
  ///   print('Este RFC ya está registrado');
  /// }
  /// ```
  Future<bool> rfcExists(String rfc) async {
    try {
      // Normalizar RFC (mayúsculas, sin espacios)
      final normalizedRfc = rfc.replaceAll(' ', '').toUpperCase();

      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('rfc', isEqualTo: normalizedRfc)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Error al verificar RFC en Firestore: $e';
    }
  }

  /// Busca usuarios por email
  ///
  /// Parámetro:
  /// - email: Email a buscar
  ///
  /// Retorna una lista de UserModel que coinciden con el email.
  /// Normalmente debería retornar 0 o 1 usuarios (emails únicos).
  ///
  /// NOTA: Requiere un índice en el campo 'email' en Firestore.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final users = await firestoreService.findUsersByEmail('juan@example.com');
  /// if (users.isNotEmpty) {
  ///   print('Usuario encontrado: ${users.first.name}');
  /// }
  /// ```
  Future<List<UserModel>> findUsersByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error al buscar usuarios por email: $e';
    }
  }

  /// Verifica si Firestore está accesible (health check)
  ///
  /// Retorna true si la conexión con Firestore es exitosa, false si hay error.
  ///
  /// Útil para verificar conectividad antes de operaciones críticas.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final isOnline = await firestoreService.checkConnection();
  /// if (!isOnline) {
  ///   print('Sin conexión a Firestore');
  /// }
  /// ```
  Future<bool> checkConnection() async {
    try {
      // Intentar leer un documento (aunque no exista)
      await _firestore
          .collection(_usersCollection)
          .doc('connection_test')
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
