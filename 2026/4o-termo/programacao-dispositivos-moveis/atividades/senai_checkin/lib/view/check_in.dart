import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:senai_checkin/components/senai_app_bar.dart';
import 'package:senai_checkin/controller/logs_controller.dart';
import 'package:senai_checkin/model/user_logs.dart';
import 'package:senai_checkin/service/api_helper.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingGps = false;
  bool _isSaving = false;
  String? _gpsErrorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndGetLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Solicita permissões de GPS e Câmera e obtém a posição atual
  Future<void> _requestPermissionsAndGetLocation() async {
    setState(() {
      _isLoadingGps = true;
      _gpsErrorMessage = null;
    });

    try {
      // 1. Verifica se os serviços de GPS do dispositivo estão ativados
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsErrorMessage = "O serviço de GPS está desativado no aparelho.";
          _isLoadingGps = false;
        });
        _showLocationSettingsDialog();
        return;
      }

      // 2. Solicita permissão de localização com permission_handler
      var locationStatus = await Permission.location.status;
      if (locationStatus.isDenied) {
        locationStatus = await Permission.location.request();
      }

      if (locationStatus.isPermanentlyDenied) {
        setState(() {
          _gpsErrorMessage = "Permissão de localização permanentemente negada.";
          _isLoadingGps = false;
        });
        _showPermissionSettingsDialog("Localização");
        return;
      }

      if (!locationStatus.isGranted && !locationStatus.isLimited) {
        setState(() {
          _gpsErrorMessage = "Permissão de acesso à localização negada.";
          _isLoadingGps = false;
        });
        return;
      }

      // 3. Obtém a posição atual com precisão elevada
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingGps = false;
        _gpsErrorMessage = null;
      });

      // 4. Busca o endereço correspondente via Nominatim (ApiHelper)
      final address = await ApiHelper.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted && address != null) {
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gpsErrorMessage = "Erro ao obter localização: $e";
          _isLoadingGps = false;
        });
      }
    }
  }

  /// Seleção e captura da foto via câmera ou galeria
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.status;
        if (cameraStatus.isDenied) {
          cameraStatus = await Permission.camera.request();
        }
        if (cameraStatus.isPermanentlyDenied) {
          _showPermissionSettingsDialog("Câmera");
          return;
        }
        if (!cameraStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Permissão da câmera negada.")),
            );
          }
          return;
        }
      }

      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file != null) {
        setState(() {
          _imagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao capturar foto: $e")),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Capturar Foto do Registro",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD9241D),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text("Câmera Nativa"),
                  subtitle: const Text("Tirar foto em tempo real"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text("Galeria"),
                  subtitle: const Text("Selecionar foto já capturada"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLocationSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("GPS Desativado"),
        content: const Text(
          "Para registrar o ponto, o serviço de GPS precisa estar ativado. Deseja abrir as configurações?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9241D),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Geolocator.openLocationSettings();
              _requestPermissionsAndGetLocation();
            },
            child: const Text("Abrir Configurações"),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog(String resourceName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Permissão de $resourceName"),
        content: Text(
          "O acesso a $resourceName é fundamental para o registro de campo. Por favor, conceda a permissão nas configurações do sistema.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9241D),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text("Configurações"),
          ),
        ],
      ),
    );
  }

  /// Salva o registro no banco SQLite com feedback visual e sonoro
  Future<void> _saveCheckIn() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Atenção: É obrigatório capturar uma foto para o registro."),
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Atenção: É necessário obter a localização GPS antes de salvar."),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final log = UserLogs(
        createdAt: DateTime.now(),
        mediaPath: _imagePath!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await LogsController().postLogs(log);

      // Feedback sonoro e tátil do sistema
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Check-in registrado com sucesso!"),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Erro ao salvar o registro no banco: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const senaiRed = Color(0xFFD9241D);

    return Scaffold(
      appBar: senaiAppBar(title: "Novo Check-In"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Seção da Foto
                const Text(
                  "1. Registro Fotográfico",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImageSourceModal,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _imagePath == null ? Colors.grey.shade400 : senaiRed,
                        width: _imagePath == null ? 1.5 : 2,
                      ),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          "Trocar Foto",
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: senaiRed.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 32,
                                  color: senaiRed,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Toque para fotografar a visita/atividade",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444444),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Câmera nativa com georreferenciamento",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Seção do GPS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "2. Coordenadas GPS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: senaiRed),
                      tooltip: "Recalcular Localização",
                      onPressed: _isLoadingGps ? null : _requestPermissionsAndGetLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isLoadingGps
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: senaiRed,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  "Obtendo sinal dos satélites GPS...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          )
                        : _gpsErrorMessage != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _gpsErrorMessage!,
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _requestPermissionsAndGetLocation,
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text("Tentar Novamente"),
                                    ),
                                  ),
                                ],
                              )
                            : _currentPosition != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, color: senaiRed),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)} | Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.gps_fixed, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Precisão: ±${_currentPosition!.accuracy.toStringAsFixed(1)} m",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_currentAddress != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.map, size: 16, color: Colors.grey.shade600),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _currentAddress!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  )
                                : const Text("Localização não obtida"),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Seção de Observações
                const Text(
                  "3. Diário de Campo / Observações",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Ex.: Visita técnica, inspeção de laboratório, manutenção preventiva...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: senaiRed, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão de Confirmação
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: senaiRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Registrar Ponto e Salvar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}