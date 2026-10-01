import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/time_record_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import 'custom_button.dart';
import 'status_badge.dart';

class RecordDetailDialog extends StatelessWidget {
  final TimeRecordModel record;

  const RecordDetailDialog({
    super.key,
    required this.record,
  });

  static Future<void> show(BuildContext context, TimeRecordModel record) {
    return showDialog(
      context: context,
      builder: (context) => RecordDetailDialog(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receipt Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: record.type.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(record.type.icon, color: record.type.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.type.fullDescription,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            Formatters.formatDateTime(record.timestamp),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 14),

              // Details List
              _buildRow('Colaborador', record.userName),
              _buildRow('NIF do Funcionário', record.userNif),
              _buildRow('Data do Registro', Formatters.formatDate(record.timestamp)),
              _buildRow('Horário Exato', Formatters.formatTime(record.timestamp)),
              _buildRow('Local Corporativo', record.workplaceName),
              _buildRow('Distância Registrada', Formatters.formatDistance(record.distanceMeters)),
              _buildRow('Coordenadas GPS', Formatters.formatCoordinates(record.latitude, record.longitude)),
              _buildRow(
                'Método de Autenticação',
                record.authMethod.label,
                icon: record.authMethod.icon,
              ),
              _buildRow(
                'Status do Perímetro',
                record.isWithinRadius ? 'Aprovado (≤ 100m)' : 'Excedeu Raio',
                badgeColor: record.isWithinRadius ? AppColors.success : AppColors.danger,
              ),
              _buildRow(
                'Sincronização',
                record.syncedWithServer ? 'Nuvem Firebase' : 'Armazenamento Local',
                badgeColor: record.syncedWithServer ? AppColors.secondary : AppColors.warning,
              ),

              const SizedBox(height: 12),

              // SHA-256 Security Digital Stamp
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.success, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Assinatura Digital (SHA-256)',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: record.hashSignature));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Assinatura copiada para a área de transferência.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text(
                            'Copiar',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.hashSignature,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              CustomButton(
                text: 'Fechar Comprovante',
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: AppColors.surfaceElevated,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {IconData? icon, Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
