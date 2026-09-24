import 'dart:convert';
import 'dart:io';

class ApiHelper {
  static Future<String?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      client.userAgent = 'SENAI-CheckIn-App/1.0';
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as Map<String, dynamic>;
        return data['display_name'] as String?;
      }
    } catch (_) {
      // Em caso de falta de conexão ou erro no serviço, retorna null sem quebrar a app
    }
    return null;
  }
}