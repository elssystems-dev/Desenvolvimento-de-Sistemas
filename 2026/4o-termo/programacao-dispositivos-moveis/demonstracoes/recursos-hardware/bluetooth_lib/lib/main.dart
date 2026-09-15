import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main(List<String> args) {
  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const new({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dispositivos Bluetooth", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue, centerTitle: true,
      actions: [
        IconButton(onPressed: _startScan, icon: Icon(Icons.refresh))
      ]),
      body: StreamBuilder<bool>(
        // 1o Stream: Verificar a busca do bluetooth
        stream: FlutterBluePlus.isScanning, 
        initialData: false,
        builder:  (context, snapshotScanning) {
          final isScanning = snapshotScanning.data ?? false; // Verificador de nulidade (coalescência nula)
          // 2o Stream: Monitorar os dispositivos
          return StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: [], // Armazenar os dispositivos bluetoothr
            builder: (context, snapshotResults) {
              final devices = snapshotResults.data ?? [];
              if (isScanning && devices.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (devices.isEmpty) {
                return Center(
                  child: Text("Nenhum dispositivo encontrado."),
                );
              } else {
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final item = devices[index];
                    final name = item.device.platformName.isNotEmpty ? item.device.platformName : "Dispositivo sem nome";
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(item.device.remoteId.str),
                      trailing: Text("${item.rssi} dBm"), // Indicador de força de sinal recebido (Received Signal Strenght Indicator)
                    );
                  }
                );
              }
            }
          );
        }
      ),
    );
  }
}