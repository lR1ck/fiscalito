import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';

/// Pantalla de splash inicial de Fiscalito
///
/// Muestra el logo completo de la aplicación con una animación fade-in
/// mientras se inicializan recursos. Después de 2.5 segundos, navega
/// automáticamente al LoginScreen.
///
/// Features:
/// - Animación fade-in del logo (opacity 0 → 1)
/// - Background con color primary de la app
/// - Navegación automática después del delay
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Controller para la animación de fade-in
  late AnimationController _animationController;

  /// Animación de opacity (0.0 → 1.0)
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _navigateToLogin();
  }

  /// Inicializa el controller y la animación de fade-in
  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Iniciar la animación
    _animationController.forward();
  }

  /// Navega al LoginScreen después de 2.5 segundos
  ///
  /// En una app real, aquí se verificaría:
  /// - Si hay sesión activa (navegar a Dashboard)
  /// - Si es primera vez (navegar a Onboarding)
  /// - Inicialización de Firebase, etc.
  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    // Verificar que el widget sigue montado antes de navegar
    if (!mounted) return;

    // Navegar reemplazando la ruta actual (no permite volver atrás)
    AppRoutes.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.kPaddingScreen * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo completo de Fiscalito
                Image.asset(
                  'assets/images/logo_full.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),

                const SizedBox(height: 20),

                // Texto de carga
                Text(
                  'Cargando...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
