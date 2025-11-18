import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart' as AppAuth;

/// Pantalla para editar el perfil del usuario
///
/// Permite modificar: nombre, email y RFC del usuario.
/// Los cambios se guardan en Firebase Auth y Firestore.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rfcController = TextEditingController();

  bool _hasChanges = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos actuales del usuario
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);
      final userData = authProvider.currentUserModel;

      if (userData != null) {
        _nameController.text = userData.name;
        _emailController.text = userData.email;
        _rfcController.text = userData.rfc;
        _originalEmail = userData.email;
      }
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryMagenta),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
              child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _hasChanges = true;
            });
          },
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryMagenta,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'JP',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryMagenta,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: _changePhoto,
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppTheme.primaryMagenta,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: _changePhoto,
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar foto'),
              ),

              const SizedBox(height: 32),

              // Nombre completo
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es obligatorio';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // RFC
              TextFormField(
                controller: _rfcController,
                decoration: const InputDecoration(
                  labelText: 'RFC',
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'XAXX010101000',
                  helperText: '13 caracteres alfanuméricos',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 13,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El RFC es obligatorio';
                  }
                  final rfc = value.trim().toUpperCase();
                  if (rfc.length != 13) {
                    return 'El RFC debe tener 13 caracteres';
                  }
                  // Validar formato: 4 letras + 6 números + 3 alfanuméricos
                  final rfcRegex = RegExp(r'^[A-Z]{4}[0-9]{6}[A-Z0-9]{3}$');
                  if (!rfcRegex.hasMatch(rfc)) {
                    return 'Formato de RFC inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_hasChanges && !_isSaving) ? _saveChanges : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cambia la foto de perfil
  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de cámara próximamente'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de galería próximamente'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorRed),
              title: const Text(
                'Eliminar foto',
                style: TextStyle(color: AppTheme.errorRed),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto eliminada (simulado)'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Guarda los cambios en Firebase Auth y Firestore
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);
      final newEmail = _emailController.text.trim();
      final emailChanged = newEmail != _originalEmail;

      // 1. Si el email cambió, actualizar en Firebase Auth
      if (emailChanged) {
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            await currentUser.updateEmail(newEmail);
          }
        } on FirebaseAuthException catch (e) {
          // Si requiere re-autenticación reciente
          if (e.code == 'requires-recent-login') {
            throw 'Por seguridad, cierra sesión y vuelve a entrar para cambiar tu email';
          }
          // Si el email ya está en uso
          if (e.code == 'email-already-in-use') {
            throw 'Este email ya está registrado por otra cuenta';
          }
          // Error genérico de email
          throw 'Error al actualizar email: ${e.message}';
        }
      }

      // 2. Actualizar datos en Firestore
      await authProvider.updateProfile({
        'name': _nameController.text.trim(),
        'email': newEmail,
        'rfc': _rfcController.text.trim().toUpperCase(),
      });

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );

      // Esperar un momento antes de cerrar
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Volver a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });
      }
    }
  }
}
