import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/punch_clock_controller.dart';
import '../../controllers/workplace_controller.dart';
import '../../models/time_record_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../widgets/biometric_prompt_sheet.dart';
import '../widgets/live_clock_card.dart';
import '../widgets/location_radar_card.dart';
import '../widgets/record_detail_dialog.dart';
import '../widgets/status_badge.dart';

class PunchClockView extends StatefulWidget {
  final AuthController authController;
  final PunchClockController punchClockController;
  final LocationController locationController;
  final WorkplaceController workplaceController;
  final HistoryController historyController;
  final VoidCallback onNavigateToWorkplaceSettings;

  const PunchClockView({
    super.key,
    required this.authController,
    required this.punchClockController,
    required this.locationController,
    required this.workplaceController,
    required this.historyController,
    required this.onNavigateToWorkplaceSettings,
  });

  @override
  State<PunchClockView> createState() => _PunchClockViewState();
}

class _PunchClockViewState extends State<PunchClockView> {
  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    final wp = widget.workplaceController.activeWorkplace;
    widget.locationController.checkLocation(wp);
    if (widget.authController.currentUser != null) {
      widget.historyController.loadRecords(widget.authController.currentUser!.id);
    }
  }

  Future<void> _handlePunchAction() async {
    final user = widget.authController.currentUser;
    if (user == null) return;

    final workplace = widget.workplaceController.activeWorkplace;
    final locStatus = widget.locationController.status;

    // Check geofence before proceeding
    if (!locStatus.isWithinAllowedRadius) {
      final distance = locStatus.distanceToWorkplaceMeters ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registro bloqueado: você está a ${Formatters.formatDistance(distance)} do local de trabalho.\n'
            'O limite máximo permitido por regra corporativa é de 100 metros.',
          ),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Biometric prompt if enabled
    if (user.isBiometricEnabled) {
      final bool? proceed = await BiometricPromptSheet.show(
        context,
        title: 'Confirmação Biométrica / Facial',
        subtitle: 'Validando reconhecimento facial para registro de ${widget.punchClockController.selectedType.label}',
      );

      if (proceed != true) {
        return; // User canceled
      }
    }

    // Execute punch registration
    final result = await widget.punchClockController.registerPunch(
      user: user,
      workplace: workplace,
      locationStatus: locStatus,
      requireBiometrics: user.isBiometricEnabled,
    );

    if (result.success && result.record != null && mounted) {
      widget.historyController.loadRecords(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Ver Comprovante',
            textColor: Colors.white,
            onPressed: () {
              RecordDetailDialog.show(context, result.record!);
            },
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    if (user == null) {
      return const Center(child: Text('Nenhum usuário logado'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registro de Ponto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar Dados',
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAll(),
        color: AppColors.primaryLight,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Digital Clock & Date Card
              LiveClockCard(
                userName: user.name,
                userNif: user.nif,
              ),
              const SizedBox(height: 16),

              // 2. Geofence Location & Distance Radar Card
              ListenableBuilder(
                listenable: Listenable.merge([
                  widget.locationController,
                  widget.workplaceController,
                ]),
                builder: (context, _) {
                  return LocationRadarCard(
                    workplace: widget.workplaceController.activeWorkplace,
                    locationStatus: widget.locationController.status,
                    onRefresh: () {
                      widget.locationController.checkLocation(
                        widget.workplaceController.activeWorkplace,
                      );
                    },
                    onConfigureWorkplace: widget.onNavigateToWorkplaceSettings,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Punch Action Type Selector
              ListenableBuilder(
                listenable: widget.punchClockController,
                builder: (context, _) {
                  return _buildPunchTypeSelector();
                },
              ),
              const SizedBox(height: 24),

              // 4. Large Interactive Punch Button
              ListenableBuilder(
                listenable: Listenable.merge([
                  widget.punchClockController,
                  widget.locationController,
                ]),
                builder: (context, _) {
                  return _buildMainPunchButton();
                },
              ),
              const SizedBox(height: 28),

              // 5. Today's Punch History Timeline
              ListenableBuilder(
                listenable: widget.historyController,
                builder: (context, _) {
                  return _buildTodaySummaryCard();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPunchTypeSelector() {
    final selected = widget.punchClockController.selectedType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o Tipo de Registro',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: PunchType.values.map((type) {
            final isSelected = selected == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () {
                    widget.punchClockController.setSelectedType(type);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? type.color : AppColors.cardBorder,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.icon,
                          size: 20,
                          color: isSelected ? type.color : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? type.color : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMainPunchButton() {
    final isProcessing = widget.punchClockController.isProcessing;
    final isWithin = widget.locationController.isWithinAllowedRadius;
    final selectedType = widget.punchClockController.selectedType;

    final Color buttonColor = isWithin ? selectedType.color : AppColors.cardBorder;

    return Center(
      child: GestureDetector(
        onTap: isProcessing ? null : _handlePunchAction,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isWithin
                  ? [
                      buttonColor,
                      buttonColor.withValues(alpha: 0.8),
                    ]
                  : [
                      AppColors.surfaceElevated,
                      AppColors.surface,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isWithin
                ? [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
            border: Border.all(
              color: isWithin ? Colors.white.withValues(alpha: 0.3) : AppColors.cardBorder,
              width: 3,
            ),
          ),
          child: Center(
            child: isProcessing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isWithin ? Icons.fingerprint_rounded : Icons.location_off_rounded,
                        size: 54,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isWithin ? 'REGISTRAR\n${selectedType.label.toUpperCase()}' : 'FORA DO RAIO\n(> 100m)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    final todayRecords = widget.historyController.todayRecords;
    final workedHours = widget.historyController.calculateTodayWorkedHours();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.history_toggle_off_rounded, color: AppColors.secondary, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Registros de Hoje',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: StatusBadge(
                  label: 'Jornada: $workedHours',
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (todayRecords.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Nenhum ponto registrado hoje.\nSelecione o tipo e pressione o botão acima.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayRecords.length,
              separatorBuilder: (context, index) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final record = todayRecords[index];
                return InkWell(
                  onTap: () => RecordDetailDialog.show(context, record),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: record.type.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(record.type.icon, color: record.type.color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.type.fullDescription,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${Formatters.formatDistance(record.distanceMeters)} do local • ${record.authMethod.label}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.formatTimeShort(record.timestamp),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
