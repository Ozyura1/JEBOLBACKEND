import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/routing/route_paths.dart';
import '../../core/routing/route_config.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/validators/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(username, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = authProvider.errorMessage;
    });

    // Navigate directly to the default route for the user's role to avoid
    // relying on router redirect (which may be a no-op when already on
    // the login page).

    // if (!success) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('Login gagal')));
    // }

    if (success) {
      final user = authProvider.user;
      if (user != null) {
        final route = RouteConfig.defaultRouteForRole(user.role);
        context.go(route);
      } else {
        // Fallback: go to login route which may trigger redirect
        context.go(RoutePaths.login);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login JEBOL')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandingHeader(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    _ErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: AuthValidators.username,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: AuthValidators.password,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Login',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur lupa password belum tersedia.',
                                      ),
                                    ),
                                  );
                                },
                          child: const Text('Lupa Password'),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go(
                                  RoutePaths.publicMarriageRegistration,
                                ),
                          child: const Text('Pendaftaran Perkawinan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LogoImage(
          assetPath: 'assets/images/logo_pemerintah_kota_tegal.jpg',
          height: 80,
          label: 'Logo Pemerintah Kota Tegal',
        ),
        const SizedBox(height: 12),
        _LogoImage(
          assetPath: 'assets/images/logo_jemput_bola.jpg',
          height: 64,
          label: 'Logo JEBOL',
        ),
      ],
    );
  }
}

class _LogoImage extends StatelessWidget {
  final String assetPath;
  final double height;
  final String label;

  const _LogoImage({
    required this.assetPath,
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
