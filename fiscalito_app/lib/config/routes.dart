import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/obligations/obligations_screen.dart';
import '../screens/obligations/reminder_settings_screen.dart';
import '../screens/cfdi/cfdi_upload_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/rfc_details_screen.dart';
import '../screens/profile/regimen_fiscal_screen.dart';
import '../screens/profile/domicilio_fiscal_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/help_center_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/terms_of_service_screen.dart';
import '../screens/profile/about_screen.dart';

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

  /// Ruta de notificaciones
  static const String notifications = '/notifications';

  /// Ruta de escaneo OCR
  static const String scan = '/scan';

  /// Ruta de configuración de recordatorios
  static const String reminderSettings = '/reminder-settings';

  /// Rutas de Profile
  static const String editProfile = '/edit-profile';
  static const String rfcDetails = '/rfc-details';
  static const String regimenFiscal = '/regimen-fiscal';
  static const String domicilioFiscal = '/domicilio-fiscal';
  static const String changePassword = '/change-password';
  static const String helpCenter = '/help-center';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String about = '/about';

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
      notifications: (context) => const NotificationsScreen(),
      scan: (context) => const ScanScreen(),
      reminderSettings: (context) => const ReminderSettingsScreen(),
      editProfile: (context) => const EditProfileScreen(),
      rfcDetails: (context) => const RFCDetailsScreen(),
      regimenFiscal: (context) => const RegimenFiscalScreen(),
      domicilioFiscal: (context) => const DomicilioFiscalScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      helpCenter: (context) => const HelpCenterScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
      termsOfService: (context) => const TermsOfServiceScreen(),
      about: (context) => const AboutScreen(),
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
