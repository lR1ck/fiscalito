import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../models/cfdi_model.dart';
import '../../services/firestore_service.dart';

/// Pantalla para agregar facturas (CFDI) mediante formulario manual
///
/// Permite al usuario ingresar los datos de una factura:
/// - Folio
/// - UUID (Folio Fiscal)
/// - Emisor (Razón Social)
/// - RFC del Emisor
/// - Monto
/// - Fecha
/// - Tipo (Ingreso/Egreso)
class CfdiUploadScreen extends StatefulWidget {
  const CfdiUploadScreen({super.key});

  @override
  State<CfdiUploadScreen> createState() => _CfdiUploadScreenState();
}

class _CfdiUploadScreenState extends State<CfdiUploadScreen> {
  /// Clave del formulario para validación
  final _formKey = GlobalKey<FormState>();

  /// Servicio de Firestore
  final _firestoreService = FirestoreService();

  /// Controladores de texto para cada campo
  final _folioController = TextEditingController();
  final _uuidController = TextEditingController();
  final _emisorController = TextEditingController();
  final _rfcEmisorController = TextEditingController();
  final _montoController = TextEditingController();

  /// Fecha seleccionada
  DateTime _selectedDate = DateTime.now();

  /// Tipo de factura seleccionado
  String _selectedTipo = 'Ingreso';

  /// Estado de carga
  bool _isSaving = false;

  @override
  void dispose() {
    // Limpiar controladores
    _folioController.dispose();
    _uuidController.dispose();
    _emisorController.dispose();
    _rfcEmisorController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Factura'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header con ícono
              const Icon(
                Icons.receipt_long,
                size: 80,
                color: AppTheme.primaryMagenta,
              ),
              const SizedBox(height: 16),
              Text(
                'Datos de la factura',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa la información de tu CFDI',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Campo: Folio
              _buildTextField(
                controller: _folioController,
                label: 'Folio',
                hint: 'Ej: A1234567',
                icon: Icons.tag,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El folio es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: UUID (Folio Fiscal)
              _buildTextField(
                controller: _uuidController,
                label: 'UUID / Folio Fiscal',
                hint: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
                icon: Icons.fingerprint,
                maxLength: 36,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El UUID es obligatorio';
                  }
                  if (value.length != 36) {
                    return 'El UUID debe tener 36 caracteres';
                  }
                  // Validar formato UUID básico
                  final uuidRegex = RegExp(
                    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
                  );
                  if (!uuidRegex.hasMatch(value)) {
                    return 'Formato de UUID inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: Emisor
              _buildTextField(
                controller: _emisorController,
                label: 'Emisor / Razón Social',
                hint: 'Nombre de la empresa',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El emisor es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: RFC Emisor
              _buildTextField(
                controller: _rfcEmisorController,
                label: 'RFC del Emisor',
                hint: 'ABC123456789',
                icon: Icons.badge,
                maxLength: 13,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El RFC es obligatorio';
                  }
                  final length = value.length;
                  if (length != 12 && length != 13) {
                    return 'El RFC debe tener 12 o 13 caracteres';
                  }
                  // Validar formato RFC básico (alfanumérico)
                  final rfcRegex = RegExp(r'^[A-Z0-9]{12,13}$');
                  if (!rfcRegex.hasMatch(value.toUpperCase())) {
                    return 'Formato de RFC inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: Monto
              _buildTextField(
                controller: _montoController,
                label: 'Monto Total',
                hint: '0.00',
                icon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El monto es obligatorio';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null) {
                    return 'Ingresa un monto válido';
                  }
                  if (monto <= 0) {
                    return 'El monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo: Fecha (DatePicker)
              _buildDateField(),

              const SizedBox(height: 16),

              // Campo: Tipo (Dropdown)
              _buildTipoDropdown(),

              const SizedBox(height: 32),

              // Botón Guardar
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSaveFactura,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Guardar Factura'),
              ),

              const SizedBox(height: 16),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.kBorderRadiusCard),
                  border: Border.all(
                    color: AppTheme.infoBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.infoBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '¿Dónde encuentro estos datos?',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.infoBlue,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toda esta información se encuentra en tu factura (CFDI) en formato XML o PDF. '
                      'El UUID es el Folio Fiscal único de 36 caracteres.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un campo de texto estándar
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryMagenta),
        filled: true,
        fillColor: AppTheme.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
          borderSide: BorderSide(
            color: AppTheme.textSecondary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
          borderSide: const BorderSide(
            color: AppTheme.primaryMagenta,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
          borderSide: const BorderSide(
            color: AppTheme.errorRed,
          ),
        ),
        counterText: '', // Ocultar contador de caracteres
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
    );
  }

  /// Construye el campo de fecha con DatePicker
  Widget _buildDateField() {
    return InkWell(
      onTap: _showDatePicker,
      borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
          border: Border.all(
            color: AppTheme.textSecondary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppTheme.primaryMagenta,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de emisión',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el dropdown de tipo de factura
  Widget _buildTipoDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusButton),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedTipo == 'Ingreso'
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: _selectedTipo == 'Ingreso'
                ? AppTheme.successGreen
                : AppTheme.errorRed,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTipo,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceCard,
                items: const [
                  DropdownMenuItem(
                    value: 'Ingreso',
                    child: Text('Ingreso (dinero que entra)'),
                  ),
                  DropdownMenuItem(
                    value: 'Egreso',
                    child: Text('Egreso (dinero que sale)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTipo = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el DatePicker
  Future<void> _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryMagenta,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Formatea la fecha
  String _formatDate(DateTime date) {
    final months = [
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

  /// Guarda la factura en Firestore
  Future<void> _handleSaveFactura() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Obtener UID del usuario actual
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Crear modelo de factura
      final factura = CfdiModel(
        userId: user.uid,
        folio: _folioController.text.trim(),
        uuid: _uuidController.text.trim(),
        emisor: _emisorController.text.trim(),
        rfcEmisor: _rfcEmisorController.text.trim().toUpperCase(),
        monto: double.parse(_montoController.text.trim()),
        fecha: _selectedDate,
        tipo: _selectedTipo,
        createdAt: DateTime.now(),
      );

      // Guardar en Firestore
      await _firestoreService.saveFactura(factura);

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Factura guardada correctamente'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Volver a la lista
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar factura: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
