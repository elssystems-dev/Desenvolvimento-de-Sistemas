import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator_weather/api_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String message = "Esperando...";
  String weather = "Esperando...";
  late Position? position;

  final ApiService apiService = ApiService();

  Future<void> getLocation() async {
    bool enable;
    LocationPermission permission;

    // Verificar se o serviço de localização está habilitado
    enable = await Geolocator.isLocationServiceEnabled();

    if (!enable) {
      if (mounted) {
        setState(() {
          message = "Serviço de localização desabilitado";
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Solicitar a permissão
      if (permission == LocationPermission.denied) {
        message = "Acesso não permitido pelo usuário";
      }
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    if (mounted) {
      setState(() {
        position = currentPosition;
        message = "Latitude: ${position!.latitude} | Longitude: ${position!.longitude}";
      });
    }
  }

  Future<void> getWeather() async {
    if (position == null) {
      await getLocation();
    }

    if (position == null) { return; }

    try {
      setState(() {
        weather = "Buscando...";
      });
      final currentWeather = await apiService.getWeatherLocation(position!);
      if (currentWeather != null && mounted) {
        setState(() {
          final temp = (currentWeather["main"]["temp"] - 273.15).toStringAsFixed(1);
          weather = "${currentWeather["name"]} | $temp°";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          weather = "Erro ao carregar clima: $e";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clima e GPS"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Coordenadas - $message", textAlign: TextAlign.center,),
            Text("Clima atual - $weather", textAlign: TextAlign.center),
            SizedBox(height: 40),
            ElevatedButton(onPressed: () async {
              getWeather();
            }, 
            child: Text("Buscar clima")),
          ],
        ),
      ),
    );
  }
}