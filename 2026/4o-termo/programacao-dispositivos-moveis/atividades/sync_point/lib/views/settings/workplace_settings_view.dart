import 'package:flutter/material.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/workplace_controller.dart';
import '../../models/workplace_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class WorkplaceSettingsView extends StatefulWidget {
  final WorkplaceController workplaceController;
  final LocationController locationController;

  const WorkplaceSettingsView({
    super.key,
    required this.workplaceController,
    required this.locationController,
  });

  @override
  State<WorkplaceSettingsView> createState() => _WorkplaceSettingsViewState();
}

class _WorkplaceSettingsViewState extends State<WorkplaceSettingsView> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final wp = widget.workplaceController.activeWorkplace;
    _nameController.text = wp.name;
    _addressController.text = wp.address;
    _latController.text = wp.latitude.toString();
    _lngController.text = wp.longitude.toString();
    _radiusController.text = wp.allowedRadiusMeters.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _setWorkplaceToCurrentGps() async {
    final locStatus = widget.locationController.status;
    if (locStatus.currentLatitude == null || locStatus.currentLongitude == null) {
      await widget.locationController.checkLocation(widget.workplaceController.activeWorkplace);
    }

    final updatedStatus = widget.locationController.status;
    if (updatedStatus.currentLatitude != null && updatedStatus.currentLongitude != null) {
      final customWorkplace = WorkplaceModel(
        id: 'local-gps-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Minha Localização Atual (Teste Avaliativo)',
        address: 'Coordenadas GPS Atuais do Dispositivo',
        latitude: updatedStatus.currentLatitude!,
        longitude: updatedStatus.currentLongitude!,
        allowedRadiusMeters: AppConstants.maxAllowedDistanceMeters,
      );

      await widget.workplaceController.updateWorkplace(customWorkplace);
      await widget.locationController.checkLocation(customWorkplace);
      _loadCurrentValues();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sede corporativa definida para suas coordenadas GPS atuais!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedStatus.errorMessage ?? 'Não foi possível obter coordenadas GPS.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    await widget.workplaceController.resetToDefault();
    await widget.locationController.checkLocation(widget.workplaceController.activeWorkplace);
    _loadCurrentValues();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sede restaurada para o padrão (Av. Paulista - SP).'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _saveCustomSettings() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    final radius = double.tryParse(_radiusController.text) ?? AppConstants.maxAllowedDistanceMeters;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe coordenadas de latitude e longitude válidas.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final custom = WorkplaceModel(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Local de Trabalho',
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : 'Endereço Corporativo',
      latitude: lat,
      longitude: lng,
      allowedRadiusMeters: radius,
    );

    await widget.workplaceController.updateWorkplace(custom);
    await widget.locationController.checkLocation(custom);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações de geofencing atualizadas com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = widget.workplaceController.activeWorkplace;
    final loc = widget.locationController.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perímetro & Local de Trabalho'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Active Geofence Card
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
                  const Row(
                    children: [
                      Icon(Icons.radar_rounded, color: AppColors.secondary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Perímetro de Geofencing Ativo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    wp.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    wp.address,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Raio: ${Formatters.formatDistance(wp.allowedRadiusMeters)}',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (loc.distanceToWorkplaceMeters != null)
                        Flexible(
                          child: Text(
                            'Distância: ${Formatters.formatDistance(loc.distanceToWorkplaceMeters!)}',
                            style: TextStyle(
                              color: loc.isWithinAllowedRadius ? AppColors.success : AppColors.danger,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Evaluation Actions
            const Text(
              'Ações Rápidas de Teste (Avaliador)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            CustomButton(
              text: 'Definir GPS Atual Como Sede',
              icon: Icons.my_location_rounded,
              onPressed: _setWorkplaceToCurrentGps,
              backgroundColor: AppColors.secondary,
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Restaurar Sede Padrão (SP)',
              icon: Icons.restore_rounded,
              isOutlined: true,
              textColor: AppColors.textPrimary,
              onPressed: _resetToDefault,
            ),
            const SizedBox(height: 24),

            // Manual Geofence Configuration
            const Text(
              'Edição Manual de Coordenadas',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _nameController,
              label: 'Nome da Sede / Filial',
              hint: 'Ex: Campus Tecnológico',
              prefixIcon: Icons.apartment_rounded,
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _addressController,
              label: 'Endereço Completo',
              hint: 'Rua, Número, Bairro, Cidade',
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _latController,
                    label: 'Latitude',
                    hint: '-23.561684',
                    prefixIcon: Icons.explore_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _lngController,
                    label: 'Longitude',
                    hint: '-46.655981',
                    prefixIcon: Icons.explore_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _radiusController,
              label: 'Raio de Tolerância (Metros - Requisito: 100m)',
              hint: '100',
              prefixIcon: Icons.radar_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Salvar Configurações',
              icon: Icons.save_rounded,
              onPressed: _saveCustomSettings,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
