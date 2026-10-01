import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/history_controller.dart';
import '../../models/time_record_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../widgets/record_detail_dialog.dart';
import '../widgets/status_badge.dart';

class HistoryView extends StatefulWidget {
  final AuthController authController;
  final HistoryController historyController;

  const HistoryView({
    super.key,
    required this.authController,
    required this.historyController,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = widget.authController.currentUser;
    if (user != null) {
      widget.historyController.loadRecords(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Histórico de Registros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar Histórico',
            onPressed: _loadData,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.historyController,
        builder: (context, _) {
          final records = widget.historyController.records;
          final isLoading = widget.historyController.isLoading;
          final todayHours = widget.historyController.calculateTodayWorkedHours();

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primaryLight,
            backgroundColor: AppColors.surface,
            child: Column(
              children: [
                // Filter Tabs (Hoje, Semana, Mês, Todos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: HistoryFilter.values.map((filter) {
                      final isSelected = widget.historyController.currentFilter == filter;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(filter.label),
                            selected: isSelected,
                            onSelected: (_) => widget.historyController.setFilter(filter),
                            selectedColor: AppColors.primaryLight,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryLight : AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Metrics Highlights
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Filtrado', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                '${records.length} registros',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jornada Hoje', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                todayHours,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // List of Records
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : records.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy_rounded,
                                    size: 56,
                                    color: AppColors.textMuted.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Nenhum registro encontrado neste período.',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: records.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = records[index];
                                return _buildRecordCard(item);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(TimeRecordModel item) {
    return InkWell(
      onTap: () => RecordDetailDialog.show(context, item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            // Action Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.type.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.type.icon, color: item.type.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.type.fullDescription,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        Formatters.formatTime(item.timestamp),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          Formatters.formatDate(item.timestamp),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.authMethod.icon, size: 12, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.authMethod.label,
                                style: const TextStyle(color: AppColors.secondary, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.workplaceName} (${Formatters.formatDistance(item.distanceMeters)})',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: StatusBadge(
                          label: item.syncedWithServer ? 'Firebase' : 'Local',
                          color: item.syncedWithServer ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
