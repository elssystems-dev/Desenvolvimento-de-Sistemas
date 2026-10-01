import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onRegisterSuccess;

  const RegisterView({
    super.key,
    required this.authController,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nifController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController(text: 'Desenvolvedor Mobile');
  final _departmentController = TextEditingController(text: 'Tecnologia da Informação');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _enableBiometrics = true;

  @override
  void dispose() {
    _nameController.dispose();
    _nifController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.authController.register(
      name: _nameController.text.trim(),
      nif: _nifController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      department: _departmentController.text.trim(),
      role: _roleController.text.trim(),
      enableBiometrics: _enableBiometrics,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onRegisterSuccess();
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
      appBar: AppBar(
        title: const Text('Cadastro de Colaborador'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Credenciamento Corporativo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Informe seus dados para habilitar o registro de ponto seguro',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  hint: 'Ex: Carlos Eduardo Silva',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: CustomTextField(
                        controller: _nifController,
                        label: 'NIF (Identificação)',
                        hint: 'Ex: 94821',
                        prefixIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o NIF';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: CustomTextField(
                        controller: _emailController,
                        label: 'E-mail Corporativo',
                        hint: 'carlos@empresa.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _roleController,
                        label: 'Cargo / Função',
                        hint: 'Ex: Analista de Sistemas',
                        prefixIcon: Icons.work_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _departmentController,
                        label: 'Departamento',
                        hint: 'Ex: Tecnologia',
                        prefixIcon: Icons.domain_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha de Acesso',
                  hint: 'Mínimo de 6 dígitos',
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
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Senha',
                  hint: 'Repita a senha',
                  prefixIcon: Icons.lock_clock_outlined,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas digitadas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Biometrics Activation Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.face_retouching_natural_rounded, color: AppColors.secondary),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reconhecimento Facial',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Habilitar biometria para bater ponto',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _enableBiometrics,
                        activeThumbColor: AppColors.primaryLight,
                        onChanged: (val) {
                          setState(() {
                            _enableBiometrics = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                ListenableBuilder(
                  listenable: widget.authController,
                  builder: (context, _) {
                    return CustomButton(
                      text: 'Finalizar Cadastro',
                      onPressed: _handleRegister,
                      isLoading: widget.authController.isLoading,
                      icon: Icons.how_to_reg_rounded,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
