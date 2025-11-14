import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/obligations/obligations_screen.dart';
import '../screens/cfdi/cfdi_upload_screen.dart';

/// Configuración de rutas de navegación de la aplicación
///
/// Define todas las rutas nombradas (named routes) para facilitar
/// la navegación entre pantallas de forma organizada y mantenible.
///
/// Flujo principal:
/// Splash → Login → (Register si es nuevo) → Dashboard
class AppRoutes {
  // =========================================================================
  // NOMBRES DE RUTAS
  // =========================================================================

  /// Ruta inicial - Splash Screen
  static const String splash = '/';

  /// Ruta de login
  static const String login = '/login';

  /// Ruta de registro
  static const String register = '/register';

  /// Ruta del dashboard (home)
  static const String dashboard = '/dashboard';

  /// Ruta del chat con AI
  static const String chat = '/chat';

  /// Ruta de obligaciones fiscales
  static const String obligations = '/obligations';

  /// Ruta de lista de CFDI (facturas)
  static const String cfdiList = '/cfdi-list';

  /// Ruta para subir CFDI
  static const String cfdiUpload = '/cfdi-upload';

  // =========================================================================
  // MAPA DE RUTAS
  // =========================================================================

  /// Retorna el mapa de rutas de la aplicación
  ///
  /// Este mapa se usa en MaterialApp.routes para definir todas
  /// las pantallas disponibles en la app.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const MainScreen(),
      obligations: (context) => const ObligationsScreen(),
      cfdiUpload: (context) => const CfdiUploadScreen(),
    };
  }

  // =========================================================================
  // MÉTODOS HELPER DE NAVEGACIÓN
  // =========================================================================

  /// Navega a una ruta reemplazando la actual (no permite volver atrás)
  ///
  /// Útil para navegación después de login o splash.
  static Future<dynamic> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navega a una ruta y elimina todas las rutas anteriores
  ///
  /// Útil para logout o cuando se quiere resetear el stack de navegación.
  static Future<dynamic> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navega a una ruta normalmente (permite volver atrás)
  static Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Vuelve a la pantalla anterior
  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
}
