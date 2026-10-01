import 'package:flutter/material.dart';
import '../../models/location_status_model.dart';
import '../../models/workplace_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import 'status_badge.dart';

class LocationRadarCard extends StatelessWidget {
  final WorkplaceModel workplace;
  final LocationStatusModel locationStatus;
  final VoidCallback onRefresh;
  final VoidCallback? onConfigureWorkplace;

  const LocationRadarCard({
    super.key,
    required this.workplace,
    required this.locationStatus,
    required this.onRefresh,
    this.onConfigureWorkplace,
  });

  @override
  Widget build(BuildContext context) {
    final distance = locationStatus.distanceToWorkplaceMeters;
    final isWithin = locationStatus.isWithinAllowedRadius;
    final isLoading = locationStatus.isLoading;
    final hasError = locationStatus.errorMessage != null;

    final Color statusColor = isLoading
        ? AppColors.warning
        : (isWithin ? AppColors.success : AppColors.danger);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Workplace Name and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          size: 15,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            workplace.name,
                            style: const TextStyle(
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
                    const SizedBox(height: 2),
                    Text(
                      workplace.address,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: isLoading
                    ? const StatusBadge(
                        label: 'Localizando...',
                        color: AppColors.warning,
                        isPulsing: true,
                      )
                    : hasError
                        ? const StatusBadge(
                            label: 'GPS Indisponível',
                            color: AppColors.danger,
                            icon: Icons.error_outline_rounded,
                          )
                        : isWithin
                            ? StatusBadge(
                                label: 'Liberado (${Formatters.formatDistance(distance ?? 0)})',
                                color: AppColors.success,
                                icon: Icons.check_circle_rounded,
                              )
                            : StatusBadge(
                                label: 'Bloqueado (${Formatters.formatDistance(distance ?? 0)})',
                                color: AppColors.danger,
                                icon: Icons.cancel_rounded,
                              ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Radar Graphic / Visual Geofence Distance Indicator
          Row(
            children: [
              // Radar Pulse Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Center(
                  child: Icon(
                    isWithin ? Icons.location_on_rounded : Icons.location_off_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Distance info & criteria
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (distance != null) ...[
                      RichText(
                        text: TextSpan(
                          text: 'Distância do Local: ',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                          children: [
                            TextSpan(
                              text: Formatters.formatDistance(distance),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isWithin
                            ? '✅ Você está dentro do raio permitido (≤ 100m).'
                            : '❌ Aproxime-se a menos de 100m para liberar o ponto.',
                        style: TextStyle(
                          color: isWithin ? AppColors.success : AppColors.danger,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (hasError) ...[
                      Text(
                        locationStatus.errorMessage ?? 'Erro ao obter localização GPS.',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 11.5,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Calculando distância com precisão...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Coordinates & Action Buttons
          Row(
            children: [
              Expanded(
                child: Text(
                  (locationStatus.currentLatitude != null &&
                          locationStatus.currentLongitude != null)
                      ? 'GPS: ${locationStatus.currentLatitude!.toStringAsFixed(4)}, ${locationStatus.currentLongitude!.toStringAsFixed(4)}'
                      : 'Aguardando GPS...',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              if (onConfigureWorkplace != null)
                IconButton(
                  icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                  tooltip: 'Simular / Alterar Sede',
                  color: AppColors.secondary,
                  onPressed: onConfigureWorkplace,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
              InkWell(
                onTap: isLoading ? null : onRefresh,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 15,
                        color: isLoading ? AppColors.textMuted : AppColors.primaryLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'GPS',
                        style: TextStyle(
                          color: isLoading ? AppColors.textMuted : AppColors.primaryLight,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
