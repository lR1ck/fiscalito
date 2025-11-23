import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart' as AppAuth;
import '../../models/user_model.dart';

/// Pantalla de perfil del usuario
///
/// Muestra información del usuario desde Firebase Auth y Firestore,
/// configuración de la cuenta y opciones de la aplicación.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Datos del usuario actual (cargados desde Firebase)
  UserModel? _userData;

  /// Estado de loading
  bool _isLoading = true;

  /// Mensaje de error
  String? _errorMessage;

  /// Configuraciones
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario desde Firebase
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener el provider de autenticación
      final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);

      // Verificar que hay un usuario autenticado
      if (!authProvider.isAuthenticated) {
        throw 'No hay usuario autenticado';
      }

      // Obtener datos del usuario desde el provider
      _userData = authProvider.currentUserModel;

      // Si no hay datos, recargar desde Firestore
      if (_userData == null) {
        await authProvider.reloadUserData();
        _userData = authProvider.currentUserModel;
      }

      // Si aún no hay datos, mostrar error
      if (_userData == null) {
        throw 'No se pudieron cargar los datos del usuario';
      }
    } catch (e) {
      _errorMessage = 'Error al cargar datos: $e';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_errorMessage'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sin botón de back porque estamos en bottom nav
        automaticallyImplyLeading: false,
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isLoading
                ? null
                : () {
                    // Navegar a editar perfil
                    AppRoutes.pushNamed(context, AppRoutes.editProfile);
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMagenta),
              ),
            )
          : SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar y datos principales
            _buildProfileHeader(),

            const SizedBox(height: 8),

            // Sección de información fiscal
            _buildSection(
              title: 'Información Fiscal',
              children: [
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'RFC',
                  value: _userData?.rfc ?? 'No disponible',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.rfcDetails);
                  },
                ),
                _buildInfoTile(
                  icon: Icons.business_outlined,
                  label: 'Régimen Fiscal',
                  value: _userData?.tieneRegimenFiscal == true
                      ? _userData!.regimenFiscalNombre
                      : 'No configurado',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.regimenFiscal);
                  },
                ),
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Domicilio Fiscal',
                  value: 'Ciudad de México',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.domicilioFiscal);
                  },
                ),
              ],
            ),

            // Sección de configuración
            _buildSection(
              title: 'Configuración',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  subtitle: 'Recordatorios de obligaciones',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildActionTile(
                  icon: Icons.lock_outlined,
                  label: 'Cambiar contraseña',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.changePassword);
                  },
                ),
              ],
            ),

            // Sección de ayuda
            _buildSection(
              title: 'Ayuda y Soporte',
              children: [
                _buildActionTile(
                  icon: Icons.help_outline,
                  label: 'Centro de ayuda',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.helpCenter);
                  },
                ),
                _buildActionTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política de privacidad',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.privacyPolicy);
                  },
                ),
                _buildActionTile(
                  icon: Icons.description_outlined,
                  label: 'Términos de servicio',
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.termsOfService);
                  },
                ),
                _buildActionTile(
                  icon: Icons.info_outline,
                  label: 'Acerca de',
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.about);
                  },
                ),
              ],
            ),

            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Construye el header del perfil
  Widget _buildProfileHeader() {
    // Obtener datos reales del usuario
    final userName = _userData?.name ?? 'Usuario';
    final userEmail = _userData?.email ?? 'No disponible';

    // Generar iniciales del nombre
    String initials = 'U';
    try {
      final nameParts = userName.split(' ').where((part) => part.isNotEmpty);
      if (nameParts.isNotEmpty) {
        initials = nameParts.map((n) => n[0].toUpperCase()).take(2).join();
      }
    } catch (e) {
      initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar con iniciales reales
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppTheme.primaryMagenta,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nombre real del usuario
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email real del usuario
          Text(
            userEmail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Badge de estado
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: AppTheme.badgeDecoration(
              color: AppTheme.successGreen,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cuenta verificada',
                  style: AppTheme.badgeTextStyle(
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una sección con título
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Construye un tile de información
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryMagenta),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          : null,
      onTap: onTap,
    );
  }

  /// Construye un tile con switch
  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryMagenta),
      title: Text(label),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  /// Construye un tile de acción
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryMagenta),
      title: Text(label),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  /// Muestra el diálogo "Acerca de"
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_icon.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text('Fiscalito'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Tu asistente fiscal personal para México',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 Fiscalito\nProyecto Capstone Universitario',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Maneja el cierre de sesión
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Cerrar sesión con Firebase
                final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);
                await authProvider.signOut();

                if (!mounted) return;

                // Navegar al login eliminando todas las rutas
                AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.login);
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cerrar sesión: $e'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
