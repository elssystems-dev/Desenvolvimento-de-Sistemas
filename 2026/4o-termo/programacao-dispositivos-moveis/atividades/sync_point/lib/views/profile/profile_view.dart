import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';

class ProfileView extends StatelessWidget {
  final AuthController authController;
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.authController,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;
    if (user == null) {
      return const Center(child: Text('Nenhum usuário autenticado'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil do Colaborador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Avatar & Title Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.role} • ${user.department}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'NIF: ${user.nif}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Employee Information Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações Contratuais',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildProfileRow('E-mail Corporativo', user.email),
                  _buildProfileRow('Departamento', user.department),
                  _buildProfileRow('Cargo Registrado', user.role),
                  _buildProfileRow('Data de Cadastro', Formatters.formatDate(user.createdAt)),
                  _buildProfileRow(
                    'Status Servidor REST',
                    ApiService.isServerOnline ? 'Conectado (json-server)' : 'Local / Offline Cache',
                    badgeColor: ApiService.isServerOnline ? AppColors.success : AppColors.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Biometric Preferences Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Segurança & Biometria',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reconhecimento Facial / Biometria',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Solicitar confirmação biométrica ao bater ponto',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ListenableBuilder(
                        listenable: authController,
                        builder: (context, _) {
                          return Switch(
                            value: authController.isBiometricEnrolledInApp,
                            activeThumbColor: AppColors.primaryLight,
                            onChanged: (val) {
                              authController.toggleBiometric(val);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            CustomButton(
              text: 'Encerrar Sessão',
              icon: Icons.logout_rounded,
              backgroundColor: AppColors.danger.withValues(alpha: 0.15),
              textColor: AppColors.danger,
              onPressed: onLogout,
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion} • SA Flutter',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, {Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (badgeColor != null)
            Flexible(
              child: StatusBadge(label: value, color: badgeColor),
            )
          else
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}
