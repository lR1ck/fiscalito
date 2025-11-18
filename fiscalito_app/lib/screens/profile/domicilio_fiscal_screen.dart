import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';

/// Pantalla de domicilio fiscal
///
/// Permite editar y guardar el domicilio fiscal del usuario.
/// Los datos se guardan en Firestore dentro del documento del usuario.
class DomicilioFiscalScreen extends StatefulWidget {
  const DomicilioFiscalScreen({super.key});

  @override
  State<DomicilioFiscalScreen> createState() => _DomicilioFiscalScreenState();
}

class _DomicilioFiscalScreenState extends State<DomicilioFiscalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _numeroExteriorController = TextEditingController();
  final _numeroInteriorController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _cpController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _estadoController = TextEditingController();

  bool _hasChanges = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDomicilio();
  }

  /// Carga el domicilio fiscal desde Firestore
  Future<void> _loadDomicilio() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No hay usuario autenticado';
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw 'No se encontraron datos del usuario';
      }

      final domicilio = doc.data()?['domicilioFiscal'] as Map<String, dynamic>?;

      if (domicilio != null) {
        _calleController.text = domicilio['calle'] ?? '';
        _numeroExteriorController.text = domicilio['numeroExterior'] ?? '';
        _numeroInteriorController.text = domicilio['numeroInterior'] ?? '';
        _coloniaController.text = domicilio['colonia'] ?? '';
        _cpController.text = domicilio['codigoPostal'] ?? '';
        _ciudadController.text = domicilio['ciudad'] ?? '';
        _estadoController.text = domicilio['estado'] ?? '';
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar domicilio: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _calleController.dispose();
    _numeroExteriorController.dispose();
    _numeroInteriorController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga los datos
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Domicilio Fiscal'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMagenta),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domicilio Fiscal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasChanges = true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppTheme.warningOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los cambios de domicilio fiscal requieren trámite en el SAT',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _calleController,
                decoration: const InputDecoration(
                  labelText: 'Calle',
                  prefixIcon: Icon(Icons.signpost),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroExteriorController,
                      decoration: const InputDecoration(
                        labelText: 'Núm. Exterior',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroInteriorController,
                      decoration: const InputDecoration(
                        labelText: 'Núm. Interior',
                        prefixIcon: Icon(Icons.numbers),
                        hintText: 'Opcional',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _coloniaController,
                decoration: const InputDecoration(
                  labelText: 'Colonia',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _cpController,
                decoration: const InputDecoration(
                  labelText: 'Código Postal',
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Obligatorio';
                  if (v!.length != 5) return 'Debe tener 5 dígitos';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad/Municipio',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_hasChanges && !_isSaving) ? _saveChanges : null,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.textPrimary,
                            ),
                          ),
                        )
                      : const Text('Actualizar domicilio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Guarda los cambios del domicilio en Firestore
  Future<void> _saveChanges() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No hay usuario autenticado';
      }

      // Crear el mapa con los datos del domicilio
      final domicilioData = {
        'calle': _calleController.text.trim(),
        'numeroExterior': _numeroExteriorController.text.trim(),
        'numeroInterior': _numeroInteriorController.text.trim(),
        'colonia': _coloniaController.text.trim(),
        'codigoPostal': _cpController.text.trim(),
        'ciudad': _ciudadController.text.trim(),
        'estado': _estadoController.text.trim(),
      };

      // Actualizar en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'domicilioFiscal': domicilioData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Domicilio actualizado correctamente'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );

      // Mostrar recordatorio sobre actualizar en SAT
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recordatorio importante'),
          content: const Text(
            'Recuerda que debes actualizar tu domicilio fiscal también en el portal del SAT '
            'para que sea oficial. Este cambio solo se guarda en la app.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
