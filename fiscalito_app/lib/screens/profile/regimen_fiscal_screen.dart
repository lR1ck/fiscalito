import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/regimenes_fiscales.dart';
import '../../providers/auth_provider.dart' as AppAuth;
import '../../models/user_model.dart';

/// Pantalla de información del régimen fiscal
///
/// Muestra el régimen fiscal del usuario y permite editarlo.
class RegimenFiscalScreen extends StatefulWidget {
  const RegimenFiscalScreen({super.key});

  @override
  State<RegimenFiscalScreen> createState() => _RegimenFiscalScreenState();
}

class _RegimenFiscalScreenState extends State<RegimenFiscalScreen> {
  /// Datos del usuario
  UserModel? _userData;

  /// Estado de carga
  bool _isLoading = true;

  /// Estado de guardado
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<AppAuth.AuthProvider>(context, listen: false);
      _userData = authProvider.currentUserModel;

      if (_userData == null) {
        await authProvider.reloadUserData();
        _userData = authProvider.currentUserModel;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Obtiene el régimen actual del usuario
  RegimenFiscal? get _regimenActual {
    if (_userData?.tieneRegimenFiscal != true) return null;
    return findRegimenByCodigo(_userData!.regimenFiscalCodigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Régimen Fiscal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isLoading || _isSaving ? null : _showEditDialog,
            tooltip: 'Cambiar régimen',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryMagenta),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card del régimen actual
                  _buildRegimenCard(),

                  const SizedBox(height: 24),

                  // Información del régimen seleccionado
                  if (_regimenActual != null) ...[
                    Text(
                      '¿Qué es ${_regimenActual!.nombre}?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _regimenActual!.descripcion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildBenefitsSection(),
                  ] else ...[
                    _buildNoRegimenCard(),
                  ],

                  const SizedBox(height: 24),

                  // Información general
                  _buildInfoSection(),

                  const SizedBox(height: 32),

                  // Botón para cambiar régimen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _showEditDialog,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.textPrimary),
                              ),
                            )
                          : Text(_userData?.tieneRegimenFiscal == true
                              ? 'Cambiar régimen'
                              : 'Configurar régimen'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRegimenCard() {
    final tieneRegimen = _userData?.tieneRegimenFiscal == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (tieneRegimen
                          ? AppTheme.successGreen
                          : AppTheme.warningOrange)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_center,
                  color: tieneRegimen
                      ? AppTheme.successGreen
                      : AppTheme.warningOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Régimen Actual',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tieneRegimen
                          ? _userData!.regimenFiscalNombre
                          : 'No configurado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: tieneRegimen
                                ? AppTheme.successGreen
                                : AppTheme.warningOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              if (tieneRegimen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMagenta.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryMagenta.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _userData!.regimenFiscalCodigo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryMagenta,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoRegimenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningOrange.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppTheme.warningOrange,
          ),
          const SizedBox(height: 16),
          Text(
            'Régimen no configurado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.warningOrange,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configura tu régimen fiscal para recibir información personalizada '
            'sobre tus obligaciones fiscales.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    // Beneficios genéricos basados en el régimen
    final regimen = _regimenActual;
    if (regimen == null) return const SizedBox.shrink();

    // Beneficios específicos por régimen
    final Map<String, List<Map<String, String>>> beneficiosPorRegimen = {
      '626': [
        {
          'title': 'Tasas reducidas',
          'desc': '1% a 2.5% sobre ingresos'
        },
        {
          'title': 'Declaraciones simples',
          'desc': 'Menos requisitos contables'
        },
        {
          'title': 'Sin contabilidad electrónica',
          'desc': 'Solo registro de ingresos'
        },
        {
          'title': 'Pagos mensuales menores',
          'desc': 'Sin pagos provisionales'
        },
      ],
      '605': [
        {
          'title': 'Sin declaraciones mensuales',
          'desc': 'Tu patrón retiene impuestos'
        },
        {
          'title': 'Declaración anual automática',
          'desc': 'El SAT precarga tu información'
        },
        {
          'title': 'Deducciones personales',
          'desc': 'Gastos médicos, colegiaturas, etc.'
        },
      ],
      '606': [
        {
          'title': 'Deducción ciega del 35%',
          'desc': 'Sin necesidad de comprobantes'
        },
        {
          'title': 'Pagos provisionales',
          'desc': 'Mensuales o trimestrales'
        },
      ],
      '612': [
        {
          'title': 'Deducciones completas',
          'desc': 'Todos los gastos del negocio'
        },
        {
          'title': 'Acreditamiento de IVA',
          'desc': 'Recupera el IVA pagado'
        },
        {
          'title': 'Flexibilidad',
          'desc': 'Para profesionistas y negocios'
        },
      ],
    };

    final beneficios = beneficiosPorRegimen[regimen.codigo] ??
        [
          {
            'title': 'Cumplimiento fiscal',
            'desc': 'Declara según tu actividad'
          },
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beneficios',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...beneficios.map((b) => _buildBenefit(b['title']!, b['desc']!)),
      ],
    );
  }

  Widget _buildBenefit(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.infoBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Para cambiar oficialmente tu régimen ante el SAT, '
              'debes realizar el trámite en su portal oficial.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para editar el régimen fiscal
  void _showEditDialog() {
    RegimenFiscal? selectedRegimen = _regimenActual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cambiar régimen fiscal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona tu régimen fiscal actual:',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ...regimenesFiscales.map((regimen) {
                  final isSelected = selectedRegimen?.codigo == regimen.codigo;
                  return InkWell(
                    onTap: () {
                      setDialogState(() {
                        selectedRegimen = regimen;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryMagenta.withOpacity(0.1)
                            : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryMagenta
                              : AppTheme.textSecondary.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryMagenta
                                  : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                regimen.codigo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  regimen.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryMagenta
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  regimen.descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryMagenta,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedRegimen == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _updateRegimen(selectedRegimen!);
                    },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Actualiza el régimen fiscal del usuario
  Future<void> _updateRegimen(RegimenFiscal regimen) async {
    setState(() => _isSaving = true);

    try {
      final authProvider =
          Provider.of<AppAuth.AuthProvider>(context, listen: false);

      await authProvider.updateProfile({
        'regimenFiscalCodigo': regimen.codigo,
        'regimenFiscalNombre': regimen.nombre,
      });

      // Recargar datos
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Régimen actualizado a ${regimen.nombre}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
