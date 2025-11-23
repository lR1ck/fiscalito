import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart' as AppAuth;
import '../../models/user_model.dart';

/// Pantalla de detalles del RFC
///
/// Muestra información completa del RFC del usuario,
/// cargando datos dinámicamente desde Firestore.
class RFCDetailsScreen extends StatefulWidget {
  const RFCDetailsScreen({super.key});

  @override
  State<RFCDetailsScreen> createState() => _RFCDetailsScreenState();
}

class _RFCDetailsScreenState extends State<RFCDetailsScreen> {
  /// Datos del usuario
  UserModel? _userData;

  /// Estado de carga
  bool _isLoading = true;

  /// Mensaje de error
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario desde el provider
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider =
          Provider.of<AppAuth.AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated) {
        throw 'No hay usuario autenticado';
      }

      _userData = authProvider.currentUserModel;

      if (_userData == null) {
        await authProvider.reloadUserData();
        _userData = authProvider.currentUserModel;
      }

      if (_userData == null) {
        throw 'No se pudieron cargar los datos del usuario';
      }
    } catch (e) {
      _errorMessage = 'Error al cargar datos: $e';
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
        title: const Text('RFC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Estado de carga
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMagenta),
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Contenido principal
    final rfc = _userData?.rfc ?? 'No disponible';
    final nombreFiscal = _userData?.name.toUpperCase() ?? 'No disponible';
    final regimen = _userData?.tieneRegimenFiscal == true
        ? _userData!.regimenFiscalFormateado
        : 'No configurado';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
      child: Column(
        children: [
          // Card principal del RFC
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryMagenta, Color(0xFFD6004C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.badge,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'RFC',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rfc,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyRFC(context, rfc),
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                      ),
                      tooltip: 'Copiar RFC',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nombreFiscal,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Banner si no tiene régimen fiscal configurado
          if (_userData?.tieneRegimenFiscal != true) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningOrange),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningOrange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Régimen fiscal no configurado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningOrange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configura tu régimen fiscal para una mejor experiencia.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.warningOrange.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Información detallada
          Container(
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.account_balance,
                  label: 'Régimen Fiscal',
                  value: regimen,
                  showBadge: _userData?.tieneRegimenFiscal == true,
                  badgeText: _userData?.regimenFiscalCodigo,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.verified,
                  label: 'Estatus',
                  value: 'Activo',
                  valueColor: AppTheme.successGreen,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Fecha de registro en Fiscalito',
                  value: _formatDate(_userData?.createdAt),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón descargar constancia
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadConstancia(context),
              icon: const Icon(Icons.download),
              label: const Text('Descargar Constancia de Situación Fiscal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón verificar en SAT
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _verifyInSAT(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Verificar en portal del SAT'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showBadge = false,
    String? badgeText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryMagenta),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: valueColor,
                            ),
                      ),
                    ),
                    if (showBadge && badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMagenta.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryMagenta.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryMagenta,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea una fecha a texto legible
  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  void _copyRFC(BuildContext context, String rfc) {
    Clipboard.setData(ClipboardData(text: rfc));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('RFC copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadConstancia(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de descarga próximamente'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _verifyInSAT(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo portal del SAT (simulado)'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué es el RFC?'),
        content: const SingleChildScrollView(
          child: Text(
            'El RFC (Registro Federal de Contribuyentes) es tu identificador fiscal único en México.\n\n'
            'Contiene:\n'
            '• 4 letras de tu nombre\n'
            '• 6 dígitos de tu fecha de nacimiento\n'
            '• 3 caracteres de homoclave\n\n'
            'Es necesario para cualquier actividad fiscal ante el SAT.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
