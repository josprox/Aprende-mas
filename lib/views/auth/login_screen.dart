import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aprende_mas/viewmodels/auth_viewmodel.dart';
import 'package:aprende_mas/viewmodels/repository_store_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;

  const LoginScreen({super.key, this.onSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;

  // 2FA controllers
  final _twoFactorFormKey = GlobalKey<FormState>();
  final _twoFactorCodeController = TextEditingController();

  // Register controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _regFirstNameController = TextEditingController();
  final _regLastNameController = TextEditingController();
  final _regUsernameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPhoneController = TextEditingController();
  bool _regObscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _twoFactorCodeController.dispose();
    _regFirstNameController.dispose();
    _regLastNameController.dispose();
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final result = await ref.read(authViewModelProvider.notifier).login(
          _loginEmailController.text,
          _loginPasswordController.text,
        );

    if (!mounted) return;

    if (result.requires2FA) {
      _twoFactorCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requiere código de autenticación de dos factores (2FA).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result.success) {
      _handleLoginSuccess();
    } else {
      final authState = ref.read(authViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.errorMessage ?? 'Error al iniciar sesión',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submitVerify2FA() async {
    if (!_twoFactorFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authViewModelProvider.notifier)
        .verify2FA(_twoFactorCodeController.text);

    if (!mounted) return;

    if (success) {
      _handleLoginSuccess();
    } else {
      final authState = ref.read(authViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.errorMessage ?? 'Código de 2FA inválido',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleLoginSuccess() {
    unawaited(
      ref.read(repositoryStoreViewModelProvider.notifier).fetchRepositories(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Sesión iniciada correctamente!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    }
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final success = await ref.read(authViewModelProvider.notifier).register(
          firstName: _regFirstNameController.text,
          lastName: _regLastNameController.text,
          username: _regUsernameController.text,
          email: _regEmailController.text,
          password: _regPasswordController.text,
          phone: _regPhoneController.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Registro completado! Ahora puedes iniciar sesión con tu cuenta.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _tabController.animateTo(0);
      _loginEmailController.text = _regEmailController.text;
    } else {
      final authState = ref.read(authViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authState.errorMessage ?? 'Error al registrar la cuenta',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (authState.requires2FA) {
              ref.read(authViewModelProvider.notifier).cancel2FA();
            } else {
              unawaited(Navigator.of(context).maybePop());
            }
          },
        ),
        title: const Text('Autenticación Joss Red'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // If 2FA is required, render 2FA Verification View
              if (authState.requires2FA) ...[
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondary,
                          colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),

                Text(
                  'Autenticación de 2 factores',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 6),
                Text(
                  'Ingresa el código de 6 dígitos de tu app de autenticación (Joss Auth).',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                Form(
                  key: _twoFactorFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _twoFactorCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Código 2FA (6 dígitos)',
                          prefixIcon: Icon(Icons.security_rounded),
                          counterText: '',
                        ),
                        validator: (val) {
                          final trimmed = val?.trim() ?? '';
                          if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
                            return 'Ingresa un código válido de 6 dígitos';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      FilledButton.icon(
                        onPressed:
                            authState.isLoading ? null : _submitVerify2FA,
                        icon: authState.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_user_rounded),
                        label: Text(
                          authState.isLoading
                              ? 'Verificando...'
                              : 'Verificar y continuar',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          ref.read(authViewModelProvider.notifier).cancel2FA();
                        },
                        child: const Text('Volver al inicio de sesión'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // --- STANDARD LOGIN / REGISTER FLOW ---
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),

                Text(
                  'Bienvenido a Aprende+',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 6),
                Text(
                  'Inicia sesión con tu cuenta de Joss Red para acceder a la tienda de materias',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Tab selector
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.primaryContainer,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: colorScheme.onPrimaryContainer,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: 'Iniciar Sesión'),
                      Tab(text: 'Registrarse'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 440,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // --- TAB 1: LOGIN ---
                      Form(
                        key: _loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _loginEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _loginPasswordController,
                              obscureText: _loginObscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.key_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _loginObscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _loginObscurePassword = !_loginObscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            FilledButton.icon(
                              onPressed: authState.isLoading ? null : _submitLogin,
                              icon: authState.isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                authState.isLoading
                                    ? 'Iniciando sesión...'
                                    : 'Iniciar Sesión',
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- TAB 2: REGISTER ---
                      Form(
                        key: _registerFormKey,
                        child: ListView(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _regFirstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre',
                                      prefixIcon: Icon(Icons.person_outline_rounded),
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty ? 'Requerido' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _regLastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Apellido',
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty ? 'Requerido' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _regUsernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de usuario',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _regEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _regPasswordController,
                              obscureText: _regObscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.key_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _regObscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _regObscurePassword = !_regObscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) => (val == null || val.length < 6)
                                  ? 'Mínimo 6 caracteres'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            FilledButton.icon(
                              onPressed:
                                  authState.isLoading ? null : _submitRegister,
                              icon: authState.isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_rounded),
                              label: Text(
                                authState.isLoading
                                    ? 'Registrando...'
                                    : 'Crear Cuenta',
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
