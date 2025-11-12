import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Pantalla de registro de nuevo usuario
///
/// Permite crear una cuenta nueva con validación completa.
/// Incluye campos específicos para usuarios fiscales mexicanos (RFC).
///
/// Features:
/// - Formulario completo con validación
/// - Validación de RFC mexicano (13 caracteres)
/// - Confirmación de contraseña
/// - Términos y condiciones
/// - Navegación de regreso a login
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Key del formulario para validación
  final _formKey = GlobalKey<FormState>();

  /// Controllers para los campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rfcController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Estado de loading durante registro
  bool _isLoading = false;

  /// Controla la visibilidad de las contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Aceptación de términos y condiciones
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rfcController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida el nombre completo
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }

    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    return null;
  }

  /// Valida el formato del email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un correo válido';
    }

    return null;
  }

  /// Valida el RFC mexicano
  ///
  /// Formato: 13 caracteres alfanuméricos
  /// Ejemplo: XAXX010101000
  String? _validateRFC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu RFC';
    }

    // Remover espacios y convertir a mayúsculas
    final rfc = value.replaceAll(' ', '').toUpperCase();

    if (rfc.length != 13) {
      return 'El RFC debe tener 13 caracteres';
    }

    // Validar formato básico (4 letras + 6 números + 3 alfanuméricos)
    final rfcRegex = RegExp(r'^[A-Z]{4}[0-9]{6}[A-Z0-9]{3}$');

    if (!rfcRegex.hasMatch(rfc)) {
      return 'Formato de RFC inválido';
    }

    return null;
  }

  /// Valida la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    // Validar que tenga al menos una letra y un número
    if (!RegExp(r'[a-zA-Z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener letras y números';
    }

    return null;
  }

  /// Valida que las contraseñas coincidan
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Maneja el registro del usuario
  ///
  /// En producción, aquí se llamaría a Firebase Auth y Firestore.
  /// Por ahora, simula un delay y navega al Dashboard.
  Future<void> _handleRegister() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar términos y condiciones
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar registro real con Firebase
      // 1. Crear usuario en Firebase Auth
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text,
      // );
      //
      // 2. Guardar datos adicionales en Firestore
      // await FirebaseFirestore.instance.collection('users').doc(uid).set({
      //   'name': _nameController.text.trim(),
      //   'email': _emailController.text.trim(),
      //   'rfc': _rfcController.text.trim().toUpperCase(),
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      // Simular delay de red
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Navegar al dashboard eliminando todas las rutas anteriores
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.dashboard);
    } catch (e) {
      // Manejo de errores
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear cuenta: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_icon.png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.kPaddingScreen),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Título
                Text(
                  'Crear cuenta',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Completa tu información para comenzar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Campo de nombre completo
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: _validateName,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Juan Pérez García',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Campo de RFC
                TextFormField(
                  controller: _rfcController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isLoading,
                  validator: _validateRFC,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9]'),
                    ),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'RFC',
                    hintText: 'XAXX010101000',
                    prefixIcon: Icon(Icons.badge_outlined),
                    helperText: '13 caracteres alfanuméricos',
                  ),
                ),

                const SizedBox(height: 16),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    helperText: 'Debe contener letras y números',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Campo de confirmación de contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    hintText: 'Repite tu contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Checkbox de términos y condiciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _acceptedTerms = !_acceptedTerms;
                                  });
                                },
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall,
                              children: [
                                const TextSpan(
                                  text: 'Acepto los ',
                                ),
                                TextSpan(
                                  text: 'Términos de Servicio',
                                  style: const TextStyle(
                                    color: AppTheme.primaryMagenta,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' y la ',
                                ),
                                TextSpan(
                                  text: 'Política de Privacidad',
                                  style: const TextStyle(
                                    color: AppTheme.primaryMagenta,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botón de registro
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
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
                        : const Text('Crear cuenta'),
                  ),
                ),

                const SizedBox(height: 24),

                // Link para volver a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              AppRoutes.pop(context);
                            },
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
