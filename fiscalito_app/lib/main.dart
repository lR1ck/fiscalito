import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart' as AppAuth;

/// Punto de entrada principal de la aplicación Fiscalito
///
/// Inicializa:
/// 1. Flutter bindings
/// 2. Variables de entorno (.env)
/// 3. Firebase (Auth y Firestore)
/// 4. Provider para estado global
Future<void> main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await Firebase.initializeApp();

  runApp(const FiscalitoApp());
}

/// Widget principal de la aplicación
///
/// Configura:
/// 1. Provider para estado de autenticación global
/// 2. MaterialApp con theme dark personalizado
/// 3. Sistema de rutas nombradas
///
/// Flujo de navegación:
/// Splash → Login → (Register si es nuevo) → Dashboard
class FiscalitoApp extends StatelessWidget {
  const FiscalitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppAuth.AuthProvider(),
      child: MaterialApp(
        title: 'Fiscalito',
        debugShowCheckedModeBanner: false,

        // Aplicar dark theme Material Design 3 personalizado
        theme: AppTheme.darkTheme,

        // Ruta inicial (SplashScreen)
        initialRoute: AppRoutes.splash,

        // Rutas nombradas de la aplicación
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
