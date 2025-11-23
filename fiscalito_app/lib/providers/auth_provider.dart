import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// Provider de autenticación
///
/// Maneja el estado global de autenticación en la app usando Provider.
/// Combina FirebaseAuthService y FirestoreService para gestionar
/// tanto la sesión de Firebase Auth como los datos del usuario en Firestore.
///
/// Uso en main.dart:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => AuthProvider(),
///   child: MyApp(),
/// )
/// ```
///
/// Uso en widgets:
/// ```dart
/// final authProvider = Provider.of<AuthProvider>(context);
/// if (authProvider.isAuthenticated) {
///   print('Usuario: ${authProvider.currentUserModel?.name}');
/// }
/// ```
class AuthProvider with ChangeNotifier {
  /// Servicio de autenticación de Firebase
  final FirebaseAuthService _authService = FirebaseAuthService();

  /// Servicio de Firestore para datos de usuario
  final FirestoreService _firestoreService = FirestoreService();

  /// Usuario actual de Firebase Auth (contiene uid, email, etc.)
  firebase_auth.User? _firebaseUser;

  /// Modelo completo del usuario (contiene nombre, RFC, etc.)
  UserModel? _currentUserModel;

  /// Indica si se está cargando información
  bool _isLoading = false;

  /// Indica si hay una operación en progreso (login, registro, etc.)
  bool _isProcessing = false;

  /// Constructor
  ///
  /// Inicializa el provider y escucha cambios de autenticación.
  /// Llama a _onAuthStateChanged cuando el estado de autenticación cambia.
  AuthProvider() {
    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // ==================== GETTERS ====================

  /// Retorna true si hay un usuario autenticado
  bool get isAuthenticated => _firebaseUser != null;

  /// Retorna el usuario de Firebase Auth actual
  firebase_auth.User? get firebaseUser => _firebaseUser;

  /// Retorna el modelo completo del usuario actual
  UserModel? get currentUserModel => _currentUserModel;

  /// Retorna true si se está cargando información
  bool get isLoading => _isLoading;

  /// Retorna true si hay una operación en progreso
  bool get isProcessing => _isProcessing;

  /// Retorna el UID del usuario actual, o null si no está autenticado
  String? get uid => _firebaseUser?.uid;

  /// Retorna el email del usuario actual, o null si no está autenticado
  String? get email => _firebaseUser?.email;

  // ==================== MÉTODOS PRIVADOS ====================

  /// Se ejecuta cuando cambia el estado de autenticación
  ///
  /// Si hay un usuario autenticado, carga sus datos de Firestore.
  /// Si no hay usuario, limpia el estado.
  Future<void> _onAuthStateChanged(firebase_auth.User? user) async {
    _firebaseUser = user;

    if (user != null) {
      // Usuario logueado: cargar datos de Firestore
      await _loadUserData(user.uid);
    } else {
      // Usuario deslogueado: limpiar datos
      _currentUserModel = null;
    }

    notifyListeners();
  }

  /// Carga los datos del usuario desde Firestore
  ///
  /// Parámetro:
  /// - uid: ID del usuario a cargar
  Future<void> _loadUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUserModel = await _firestoreService.getUser(uid);
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
      _currentUserModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== MÉTODOS PÚBLICOS ====================

  /// Inicia sesión con email y contraseña
  ///
  /// Parámetros:
  /// - email: Correo electrónico
  /// - password: Contraseña
  ///
  /// Lanza excepciones en español si hay errores.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   await authProvider.signIn('user@example.com', 'password123');
  ///   // Navegar al dashboard
  /// } catch (e) {
  ///   // Mostrar error al usuario
  ///   print(e);
  /// }
  /// ```
  Future<void> signIn(String email, String password) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // _onAuthStateChanged se encargará de cargar los datos
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo usuario
  ///
  /// Parámetros:
  /// - email: Correo electrónico
  /// - password: Contraseña
  /// - name: Nombre completo
  /// - rfc: RFC del usuario
  /// - regimenFiscalCodigo: Código del régimen fiscal (ej: "626")
  /// - regimenFiscalNombre: Nombre del régimen fiscal (ej: "RESICO")
  ///
  /// Crea el usuario en Firebase Auth Y guarda sus datos en Firestore.
  ///
  /// Lanza excepciones en español si hay errores.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   await authProvider.signUp(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///     name: 'Juan Pérez',
  ///     rfc: 'XAXX010101000',
  ///     regimenFiscalCodigo: '626',
  ///     regimenFiscalNombre: 'RESICO',
  ///   );
  ///   // Navegar al dashboard
  /// } catch (e) {
  ///   // Mostrar error al usuario
  ///   print(e);
  /// }
  /// ```
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String rfc,
    required String regimenFiscalCodigo,
    required String regimenFiscalNombre,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Crear usuario en Firebase Auth
      final firebaseUser = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Crear modelo de usuario con régimen fiscal
      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        rfc: rfc.trim().toUpperCase(),
        regimenFiscalCodigo: regimenFiscalCodigo,
        regimenFiscalNombre: regimenFiscalNombre,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Guardar datos adicionales en Firestore
      await _firestoreService.createUser(userModel);

      // 4. Actualizar estado local
      _currentUserModel = userModel;
    } catch (e) {
      // Si hubo error al guardar en Firestore pero el usuario se creó en Auth,
      // intentar eliminar el usuario de Auth para mantener consistencia
      if (_authService.currentUser != null) {
        try {
          await _authService.deleteUser();
        } catch (deleteError) {
          debugPrint('Error al eliminar usuario de Auth: $deleteError');
        }
      }
      rethrow; // Re-lanzar el error original
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Cierra la sesión del usuario actual
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await authProvider.signOut();
  /// // Navegar a login
  /// ```
  Future<void> signOut() async {
    _isProcessing = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUserModel = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Actualiza el perfil del usuario
  ///
  /// Parámetro:
  /// - data: Map con los campos a actualizar
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await authProvider.updateProfile({
  ///   'name': 'Nuevo Nombre',
  ///   'rfc': 'NUEVO123456789',
  /// });
  /// ```
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated || uid == null) {
      throw 'No hay usuario autenticado';
    }

    _isProcessing = true;
    notifyListeners();

    try {
      await _firestoreService.updateUser(uid!, data);
      // Recargar datos del usuario
      await _loadUserData(uid!);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Envía email de recuperación de contraseña
  ///
  /// Parámetro:
  /// - email: Correo electrónico
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// try {
  ///   await authProvider.sendPasswordReset('user@example.com');
  ///   // Mostrar mensaje de éxito
  /// } catch (e) {
  ///   // Mostrar error
  /// }
  /// ```
  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// Elimina la cuenta del usuario actual
  ///
  /// PELIGROSO: Elimina tanto el usuario de Auth como sus datos de Firestore.
  /// Esta acción es irreversible.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// // Confirmar con el usuario primero
  /// if (userConfirmed) {
  ///   await authProvider.deleteAccount();
  ///   // Navegar a login
  /// }
  /// ```
  Future<void> deleteAccount() async {
    if (!isAuthenticated || uid == null) {
      throw 'No hay usuario autenticado';
    }

    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Eliminar datos de Firestore
      await _firestoreService.deleteUser(uid!);

      // 2. Eliminar usuario de Auth
      await _authService.deleteUser();

      // 3. Limpiar estado
      _currentUserModel = null;
      _firebaseUser = null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Recarga los datos del usuario desde Firestore
  ///
  /// Útil después de actualizar datos manualmente o para sincronizar.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// await authProvider.reloadUserData();
  /// ```
  Future<void> reloadUserData() async {
    if (uid != null) {
      await _loadUserData(uid!);
    }
  }
}
