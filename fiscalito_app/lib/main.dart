import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

/// Punto de entrada principal de la aplicación Fiscalito
void main() {
  runApp(const FiscalitoApp());
}

/// Widget principal de la aplicación
///
/// Configura MaterialApp con el theme dark personalizado,
/// sistema de rutas nombradas y navegación.
///
/// Flujo de navegación:
/// Splash → Login → (Register si es nuevo) → Dashboard
class FiscalitoApp extends StatelessWidget {
  const FiscalitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiscalito',
      debugShowCheckedModeBanner: false,

      // Aplicar dark theme Material Design 3 personalizado
      theme: AppTheme.darkTheme,

      // Ruta inicial (SplashScreen)
      initialRoute: AppRoutes.splash,

      // Rutas nombradas de la aplicación
      routes: AppRoutes.getRoutes(),
    );
  }
}
