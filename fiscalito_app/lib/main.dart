import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';
import 'config/routes.dart';

/// Punto de entrada principal de la aplicación Fiscalito
///
/// Carga el archivo .env antes de iniciar la app para
/// tener acceso a las API keys (OpenAI, etc.)
Future<void> main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");

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
