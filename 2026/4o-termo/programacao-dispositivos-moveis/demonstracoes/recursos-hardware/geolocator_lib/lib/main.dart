import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main(List<String> ars) {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
  ));
}

class MyApp extends StatefulWidget {
  const new({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late LocationPermission permission;
  String location = "Localização não obtida";

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  Future<void> getLocation() async {
    // Solicitar geolocalização ao apertar o botão
    bool enable = false;

    enable = await Geolocator.isLocationServiceEnabled();

    if (!enable) {
      location = "Serviço de localização desabilitado";
    }

    permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always || permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission(); // Solicita caso esteja negado
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        location = "Acesso à localização não permitido pelo usuário";
      }
    } 

    // Pegando a posição atual
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best)
    );

    location = "Latitude: ${position.latitude} | Longitude: ${position.longitude}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilizar a geolocalização para mostrar a localização do dispositivo
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("GPS Localização"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location),
            ElevatedButton(onPressed: () async {
              setState(() {
                getLocation();
              });
            }, child: Text("Obter localização"))
          ],
        ),
      ),
    );
  }
}