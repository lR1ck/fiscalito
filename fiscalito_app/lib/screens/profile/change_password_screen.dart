import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

// Nota: No importamos AuthProvider aquí porque no lo necesitamos
// Solo usamos FirebaseAuth.instance directamente

/// Pantalla para cambiar contraseña
///
/// Permite al usuario cambiar su contraseña de Firebase Auth.
/// Requiere re-autenticación con la contraseña actual por seguridad.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChanging = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.infoBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu contraseña debe tener al menos 6 caracteres',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Contraseña actual
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureCurrentPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña actual';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Nueva contraseña
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'Debe tener al menos 6 caracteres';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'La nueva contraseña debe ser diferente';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu nueva contraseña';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botón cambiar contraseña
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChanging ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isChanging
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Cambiar contraseña'),
                ),
              ),

              const SizedBox(height: 16),

              // Botón olvidé mi contraseña
              Center(
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cambia la contraseña del usuario en Firebase Auth
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isChanging = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw 'No hay usuario autenticado';
      }

      // 1. Re-autenticar al usuario con la contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw 'La contraseña actual es incorrecta';
        }
        throw 'Error al verificar contraseña: ${e.message}';
      }

      // 2. Actualizar a la nueva contraseña
      try {
        await user.updatePassword(_newPasswordController.text);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          throw 'La contraseña nueva es muy débil. Usa al menos 6 caracteres';
        }
        throw 'Error al cambiar contraseña: ${e.message}';
      }

      if (!mounted) return;

      // 3. Mostrar diálogo de éxito y cerrar sesión automáticamente
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successGreen),
              SizedBox(width: 12),
              Text('Contraseña actualizada'),
            ],
          ),
          content: const Text(
            'Tu contraseña ha sido cambiada exitosamente.\n\n'
            'Por seguridad, vamos a cerrar tu sesión. '
            'Vuelve a iniciar sesión con tu nueva contraseña.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Cierra diálogo

                // Cerrar sesión
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                // Navegar al login
                AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.login);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChanging = false);
      }
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: const Text(
          'Se enviará un correo de recuperación a tu email registrado.\n\n'
          'juan.perez@example.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Correo de recuperación enviado'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
