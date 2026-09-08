// Permitir a conexão com a API de clima

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String baseUrl = dotenv.get("BASE_URL");
  String apiKey = dotenv.get("CHAVE_API_CLIMA");

  Future<Map<String, dynamic>?> getWeatherLocation(Position position) async {
    // Endereço URL da consulta da API
    final response = await http.get(
      Uri.parse("$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey")
    );
    // Verifica a resposta
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Falha de conexão");
    }
  }

}
