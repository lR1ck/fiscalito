import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/navigation_provider.dart';

/// Pantalla principal del dashboard fiscal
///
/// Muestra:
/// - Resumen del estado fiscal del usuario
/// - Próximas obligaciones
/// - Acceso rápido a features principales
///
/// Los datos mostrados son mock por ahora. En producción,
/// se cargarán desde Firestore y APIs del SAT.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Estado de loading al cargar datos
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Carga los datos del dashboard desde Firestore
  ///
  /// En producción, aquí se llamaría a Firestore y APIs del SAT.
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementar carga real de datos
      // final userData = await FirestoreService.getUserData();
      // final taxStatus = await SATService.getTaxStatus();

      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Maneja el logout del usuario
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
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_icon.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navegar a notificaciones
              AppRoutes.pushNamed(context, AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo
              _buildWelcomeHeader(),

              const SizedBox(height: 24),

              // Card de estado fiscal principal
              _buildTaxStatusCard(),

              const SizedBox(height: 16),

              // Card de próxima obligación
              _buildNextObligationCard(),

              const SizedBox(height: 24),

              // Título de accesos rápidos
              Text(
                'Accesos rápidos',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              // Grid de accesos rápidos
              _buildQuickAccessGrid(),

              const SizedBox(height: 24),

              // Sección de estadísticas
              Text(
                'Estadísticas',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              // Cards de estadísticas
              _buildStatisticsCards(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con saludo personalizado
  Widget _buildWelcomeHeader() {
    // TODO: Obtener nombre real del usuario desde Firestore
    const userName = 'Juan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $userName',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Aquí está tu estado fiscal',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  /// Card principal de estado fiscal
  Widget _buildTaxStatusCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(AppTheme.kPaddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: AppTheme.primaryMagenta,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Fiscal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Última actualización: Hoy',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
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
                const SizedBox(width: 8),
                Text(
                  'Al corriente con el SAT',
                  style: AppTheme.badgeTextStyle(
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // RFC del usuario
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'RFC: ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                'XAXX010101000',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card de próxima obligación fiscal
  Widget _buildNextObligationCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppRoutes.pushNamed(context, AppRoutes.obligations);
        },
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
            border: Border.all(
              color: AppTheme.warningOrange,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppTheme.kPaddingCard),
          child: Row(
            children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_outlined,
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próxima declaración',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '17 de diciembre, 2025',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faltan 5 días',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.warningOrange,
          ),
        ],
      ),
    ),
      ),
    );
  }

  /// Grid de accesos rápidos
  Widget _buildQuickAccessGrid() {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    final quickActions = [
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Chat con AI',
        color: AppTheme.primaryMagenta,
        onTap: () {
          // Navegar a Chat (índice 1)
          navigationProvider.goToChat();
        },
      ),
      _QuickAction(
        icon: Icons.upload_file_outlined,
        label: 'Subir factura',
        color: AppTheme.infoBlue,
        onTap: () {
          // Navegar directamente a subir factura
          AppRoutes.pushNamed(context, AppRoutes.cfdiUpload);
        },
      ),
      _QuickAction(
        icon: Icons.qr_code_scanner_outlined,
        label: 'Escanear',
        color: AppTheme.successGreen,
        onTap: () {
          // Navegar a scanner OCR
          AppRoutes.pushNamed(context, AppRoutes.scan);
        },
      ),
      _QuickAction(
        icon: Icons.calendar_today_outlined,
        label: 'Obligaciones',
        color: AppTheme.warningOrange,
        onTap: () {
          // Navegar a obligaciones
          AppRoutes.pushNamed(context, AppRoutes.obligations);
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return _buildQuickActionCard(action);
      },
    );
  }

  /// Card individual de acción rápida
  Widget _buildQuickActionCard(_QuickAction action) {
    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: action.color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cards de estadísticas
  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Facturas',
            value: '24',
            subtitle: 'Este mes',
            icon: Icons.receipt_long,
            color: AppTheme.infoBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total',
            value: '\$12,450',
            subtitle: 'MXN',
            icon: Icons.attach_money,
            color: AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  /// Card individual de estadística
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Icon(
                icon,
                color: color,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Modelo para acciones rápidas
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
