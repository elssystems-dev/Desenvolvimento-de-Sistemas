import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;

  const LoginView({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.authController.rememberedLogin != null) {
      _loginController.text = widget.authController.rememberedLogin!;
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authController.login(
      emailOrNif: _loginController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      widget.onLoginSuccess();
    } else if (mounted && widget.authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authController.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success = await widget.authController.loginWithBiometrics();
    if (success && mounted) {
      widget.onLoginSuccess();
    } else if (mounted && widget.authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.authController.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo & Hero Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Login Input Fields
                  CustomTextField(
                    controller: _loginController,
                    label: 'NIF ou E-mail Corporativo',
                    hint: 'Ex: 123456 ou colaborador@empresa.com',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu NIF ou E-mail para acessar';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha de Acesso',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe sua senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Standard Login Button
                  ListenableBuilder(
                    listenable: widget.authController,
                    builder: (context, _) {
                      return CustomButton(
                        text: 'Entrar',
                        onPressed: _handlePasswordLogin,
                        isLoading: widget.authController.isLoading,
                        icon: Icons.login_rounded,
                      );
                    },
                  ),

                  // Biometric / Facial Login Option (if hardware available)
                  if (widget.authController.isBiometricHardwareAvailable) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OU USE RECONHECIMENTO',
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: widget.authController,
                      builder: (context, _) {
                        return CustomButton(
                          text: 'Entrar com Biometria / Face ID',
                          onPressed: _handleBiometricLogin,
                          isOutlined: true,
                          backgroundColor: AppColors.secondary,
                          textColor: AppColors.secondary,
                          icon: Icons.face_rounded,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Register Redirection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Novo colaborador? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RegisterView(
                                authController: widget.authController,
                                onRegisterSuccess: widget.onLoginSuccess,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Cadastrar NIF',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
