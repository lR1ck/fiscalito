import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Pantalla de domicilio fiscal
class DomicilioFiscalScreen extends StatefulWidget {
  const DomicilioFiscalScreen({super.key});

  @override
  State<DomicilioFiscalScreen> createState() => _DomicilioFiscalScreenState();
}

class _DomicilioFiscalScreenState extends State<DomicilioFiscalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController(text: 'Calle Falsa');
  final _numeroController = TextEditingController(text: '123');
  final _coloniaController = TextEditingController(text: 'Centro');
  final _cpController = TextEditingController(text: '06000');
  final _ciudadController = TextEditingController(text: 'Ciudad de México');
  final _estadoController = TextEditingController(text: 'CDMX');

  bool _hasChanges = false;

  @override
  void dispose() {
    _calleController.dispose();
    _numeroController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _coloniaController,
                      decoration: const InputDecoration(
                        labelText: 'Colonia',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Obligatorio' : null,
                    ),
                  ),
                ],
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
                  onPressed: _hasChanges ? _saveChanges : null,
                  child: const Text('Actualizar domicilio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recordatorio'),
        content: const Text(
          'Recuerda que debes actualizar tu domicilio fiscal también en el portal del SAT '
          'para que sea oficial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );

    setState(() => _hasChanges = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Domicilio guardado (local)'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
