import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Pantalla de perfil del usuario
///
/// Muestra información del usuario, configuración de la cuenta
/// y opciones de la aplicación.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Mock data del usuario
  final String _userName = 'Juan Pérez García';
  final String _userEmail = 'juan.perez@example.com';
  final String _userRFC = 'XAXX010101000';

  /// Configuraciones
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

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
            onPressed: () {
              // Navegar a editar perfil
              AppRoutes.pushNamed(context, AppRoutes.editProfile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  value: _userRFC,
                  onTap: () {
                    AppRoutes.pushNamed(context, AppRoutes.rfcDetails);
                  },
                ),
                _buildInfoTile(
                  icon: Icons.business_outlined,
                  label: 'Régimen Fiscal',
                  value: 'RESICO',
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
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  label: 'Biometría',
                  subtitle: 'Desbloquear con huella/Face ID',
                  value: _biometricsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricsEnabled = value;
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
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryMagenta,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _userName.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nombre
          Text(
            _userName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            _userEmail,
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar logout real con Firebase
              // await FirebaseAuth.instance.signOut();
              AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.login);
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
