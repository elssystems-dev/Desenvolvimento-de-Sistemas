import 'dart:async'; // Biblioteca para usar o StreamSubscription

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // Criar uma mensagem
  String _mensagem = "Verificando...";

  // Objeto para "ouvir" as mudanças de conexão
  late StreamSubscription<List<ConnectivityResult>> _wifiObserver;

  @override
  void initState() {
    super.initState();
    // Checar o Wi-Fi
    _checkInitialConnection();
    // Começar a ouvir as mudanças de conexão em tempo real
    _wifiObserver = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // Pega o primeiro resultado disponível
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        _updateConnectionStatus(result);
      }
    );
  }

  Future<void> _checkInitialConnection() async {
    var connectivityResult = (await Connectivity().checkConnectivity()) as ConnectivityResult;
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (!mounted) return;

    setState(() {
      switch(result) {
        case ConnectivityResult.wifi:
          _mensagem = "Conectado no Wi-Fi";
          break;
        case ConnectivityResult.mobile:
          _mensagem = "Conectado via Dados Móveis";
          break;
        case ConnectivityResult.none:
          _mensagem = "Sem conexão com a internet";
          break;
        default:
          _mensagem = "Procurando conexão...";
      }
    });
  }

  @override
  void dispose() {
    _wifiObserver.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status de Conexão", style: TextStyle(color: Colors.white)), backgroundColor: Colors.teal, centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Muda de acordo com a conexão
              _mensagem.contains("Wi-Fi") ? Icons.wifi :
              _mensagem.contains("Dados") ? Icons.network_cell
              : Icons.wifi_off,
              size: 80,
              color: _mensagem.contains("Sem") ? Colors.red : Colors.green,
            ),
            SizedBox(height: 10),
            Text("Status: $_mensagem")
          ],
        ),
      ),
    );
  }
}
