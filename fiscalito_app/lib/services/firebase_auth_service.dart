import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación con Firebase
///
/// Maneja todas las operaciones de autenticación de usuarios:
/// - Login con email/password
/// - Registro de nuevos usuarios
/// - Logout
/// - Gestión del estado de autenticación
/// - Manejo de errores en español
///
/// Uso:
/// ```dart
/// final authService = FirebaseAuthService();
/// final user = await authService.signInWithEmailAndPassword(email, password);
/// ```
class FirebaseAuthService {
  /// Instancia de Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream del usuario autenticado
  ///
  /// Emite un User cuando hay sesión activa, o null cuando no la hay.
  /// Útil para escuchar cambios de autenticación en tiempo real.
  ///
  /// Ejemplo:
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     // Usuario logueado
  ///   } else {
  ///     // Usuario no logueado
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtiene el usuario autenticado actual
  ///
  /// Retorna el User si hay sesión activa, o null si no la hay.
  /// No es reactivo, solo obtiene el valor actual.
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con email y contraseña
  ///
  /// Parámetros:
  /// - email: Correo electrónico del usuario
  /// - password: Contraseña del usuario
  ///
  /// Retorna el User autenticado si tiene éxito.
  ///
  /// Lanza excepciones en español para los siguientes casos:
  /// - Email o contraseña inválidos
  /// - Usuario no encontrado
  /// - Contraseña incorrecta
  /// - Demasiados intentos fallidos
  /// - Errores de red
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   final user = await authService.signInWithEmailAndPassword(
  ///     'usuario@example.com',
  ///     'miPassword123',
  ///   );
  ///   print('Login exitoso: ${user.email}');
  /// } catch (e) {
  ///   print('Error en login: $e');
  /// }
  /// ```
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw 'No se pudo iniciar sesión. Intenta de nuevo.';
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      // Traducir errores de Firebase a español
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado al iniciar sesión: $e';
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  ///
  /// Parámetros:
  /// - email: Correo electrónico del nuevo usuario
  /// - password: Contraseña (debe cumplir requisitos de Firebase)
  ///
  /// Retorna el User creado si tiene éxito.
  ///
  /// Lanza excepciones en español para los siguientes casos:
  /// - Email ya en uso
  /// - Email inválido
  /// - Contraseña muy débil
  /// - Errores de red
  ///
  /// IMPORTANTE: Este método solo crea el usuario en Firebase Auth.
  /// Debes usar FirestoreService para guardar datos adicionales
  /// (nombre, RFC, etc.) en Firestore.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   final user = await authService.createUserWithEmailAndPassword(
  ///     'nuevo@example.com',
  ///     'password123',
  ///   );
  ///   print('Registro exitoso: ${user.uid}');
  /// } catch (e) {
  ///   print('Error en registro: $e');
  /// }
  /// ```
  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw 'No se pudo crear la cuenta. Intenta de nuevo.';
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      // Traducir errores de Firebase a español
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      throw 'Error inesperado al crear cuenta: $e';
    }
  }

  /// Cierra la sesión del usuario actual
  ///
  /// Elimina la sesión de Firebase Auth en el dispositivo.
  /// El authStateChanges stream emitirá null después de esto.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await authService.signOut();
  /// // Navegar a pantalla de login
  /// ```
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  /// Envía un email de recuperación de contraseña
  ///
  /// Parámetro:
  /// - email: Correo electrónico del usuario
  ///
  /// Firebase enviará un email con un link para resetear la contraseña.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   await authService.sendPasswordResetEmail('usuario@example.com');
  ///   print('Email de recuperación enviado');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      throw 'Error al enviar email de recuperación: $e';
    }
  }

  /// Recarga la información del usuario actual
  ///
  /// Útil para actualizar datos como emailVerified después de
  /// que el usuario verifica su email.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Elimina la cuenta del usuario actual
  ///
  /// PELIGROSO: Esta acción es irreversible.
  /// También deberías eliminar los datos del usuario en Firestore.
  ///
  /// Requiere que el usuario se haya autenticado recientemente.
  /// Si no, lanzará un error requiriendo re-autenticación.
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _getSpanishErrorMessage(e.code);
    } catch (e) {
      throw 'Error al eliminar cuenta: $e';
    }
  }

  /// Traduce códigos de error de Firebase a mensajes en español
  ///
  /// Maneja los errores más comunes de Firebase Auth y los convierte
  /// en mensajes amigables para el usuario mexicano.
  String _getSpanishErrorMessage(String errorCode) {
    switch (errorCode) {
      // Errores de login
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Verifica e intenta de nuevo.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta a soporte.';

      // Errores de registro
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Inicia sesión o usa otro correo.';
      case 'invalid-email':
        return 'El formato del correo electrónico es inválido.';
      case 'operation-not-allowed':
        return 'El registro con email/contraseña no está habilitado.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';

      // Errores de validación
      case 'invalid-verification-code':
        return 'El código de verificación es inválido.';
      case 'invalid-verification-id':
        return 'El ID de verificación es inválido.';

      // Errores de red
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';

      // Errores de sesión
      case 'requires-recent-login':
        return 'Esta operación requiere que inicies sesión de nuevo.';

      // Error genérico
      default:
        return 'Error de autenticación: $errorCode. Contacta a soporte si persiste.';
    }
  }
}
