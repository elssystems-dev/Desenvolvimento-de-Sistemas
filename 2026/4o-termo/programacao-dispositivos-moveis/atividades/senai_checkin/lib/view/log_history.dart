import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:senai_checkin/components/senai_app_bar.dart';
import 'package:senai_checkin/controller/logs_controller.dart';
import 'package:senai_checkin/model/user_logs.dart';
import 'package:senai_checkin/service/api_helper.dart';
import 'package:senai_checkin/view/check_in.dart';

class LogHistory extends StatefulWidget {
  const LogHistory({super.key});

  @override
  State<LogHistory> createState() => _LogHistoryState();
}

class _LogHistoryState extends State<LogHistory> {
  final LogsController _controller = LogsController();
  List<UserLogs> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _controller.getLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar registros: $e")),
        );
      }
    }
  }

  Future<void> _navigateToCheckIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckIn()),
    );

    if (result == true) {
      _loadLogs();
    }
  }

  Future<void> _deleteLog(UserLogs log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Registro"),
        content: const Text(
          "Tem certeza de que deseja excluir este registro de ponto?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9241D),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm == true && log.id != null) {
      await _controller.deleteLog(log.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro excluído com sucesso.")),
        );
        _loadLogs();
      }
    }
  }

  void _showImageDetails(UserLogs log) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(
                File(log.mediaPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFFD9241D)),
                      const SizedBox(width: 6),
                      Text(
                        log.formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Lat: ${log.latitude.toStringAsFixed(6)} | Lng: ${log.longitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Observações:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.notes!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Fechar"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapModal(UserLogs log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _OsmMapViewModal(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    const senaiRed = Color(0xFFD9241D);

    return Scaffold(
      appBar: senaiAppBar(
        title: "Senai Check-in",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Atualizar lista",
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: senaiRed),
            )
          : _logs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: senaiRed.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 48,
                            color: senaiRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Nenhum registro encontrado",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Toque no botão abaixo para fazer o primeiro registro de ponto com foto e GPS.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: senaiRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _navigateToCheckIn,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text("Registrar Check-in"),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: senaiRed,
                  onRefresh: _loadLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showImageDetails(log),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Miniatura da foto
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: Image.file(
                                      File(log.mediaPath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(
                                        child: Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Informações do registro
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_filled,
                                            size: 15,
                                            color: senaiRed,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              log.formattedDate,
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
                                          const Icon(
                                            Icons.location_on,
                                            size: 15,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${log.latitude.toStringAsFixed(4)}, ${log.longitude.toStringAsFixed(4)}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          log.notes!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: senaiRed,
                                              side: const BorderSide(color: senaiRed),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              visualDensity: VisualDensity.compact,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () => _showMapModal(log),
                                            icon: const Icon(Icons.map, size: 16),
                                            label: const Text(
                                              "Ver no Mapa",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            tooltip: "Excluir Registro",
                                            onPressed: () => _deleteLog(log),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: senaiRed,
        foregroundColor: Colors.white,
        onPressed: _navigateToCheckIn,
        icon: const Icon(Icons.add_a_photo),
        label: const Text(
          "Novo Check-in",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Modal com mapa interativo OSM para exibição do ponto georreferenciado
class _OsmMapViewModal extends StatefulWidget {
  final UserLogs log;
  const _OsmMapViewModal({required this.log});

  @override
  State<_OsmMapViewModal> createState() => _OsmMapViewModalState();
}

class _OsmMapViewModalState extends State<_OsmMapViewModal> {
  late final MapController _mapController;
  String? _address;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController.withPosition(
      initPosition: GeoPoint(
        latitude: widget.log.latitude,
        longitude: widget.log.longitude,
      ),
    );
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final address = await ApiHelper.getAddressFromCoordinates(
      widget.log.latitude,
      widget.log.longitude,
    );
    if (mounted) {
      setState(() {
        _address = address;
        _isLoadingAddress = false;
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const senaiRed = Color(0xFFD9241D);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra superior com título e fechar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: senaiRed,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Localização do Ponto",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Informações do ponto
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: senaiRed),
                    const SizedBox(width: 6),
                    Text(
                      widget.log.formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Coordenadas: ${widget.log.latitude.toStringAsFixed(6)}, ${widget.log.longitude.toStringAsFixed(6)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
                if (_isLoadingAddress)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Identificando endereço aproximado...",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  )
                else if (_address != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _address!,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Mapa OSM com marcador
          Expanded(
            child: OSMFlutter(
              controller: _mapController,
              osmOption: OSMOption(
                zoomOption: const ZoomOption(
                  initZoom: 16,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                staticPoints: [
                  StaticPositionGeoPoint(
                    "log_marker_${widget.log.id}",
                    const MarkerIcon(
                      icon: Icon(
                        Icons.location_on,
                        color: senaiRed,
                        size: 48,
                      ),
                    ),
                    [
                      GeoPoint(
                        latitude: widget.log.latitude,
                        longitude: widget.log.longitude,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}