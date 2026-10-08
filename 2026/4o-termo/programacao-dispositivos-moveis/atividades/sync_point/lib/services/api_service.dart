import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  static bool _isServerOnline = false;
  static bool get isServerOnline => _isServerOnline;

  /// Compatibility getter: allows views to verify connection to the backend
  static bool get isInitialized => _isServerOnline;

  /// Initializes API connection check with json-server
  static Future<void> initialize() async {
    await checkServerConnection();
  }

  /// Verifies connectivity with json-server backend
  static Future<bool> checkServerConnection() async {
    try {
      final storage = await StorageService.getInstance();
      final baseUrl = storage.getApiBaseUrl();

      final uri = Uri.parse('$baseUrl${AppConstants.endpointStatus}');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isServerOnline = true;
        if (kDebugMode) {
          print('✅ [ApiService] Conectado ao json-server com sucesso em: $baseUrl');
        }
        return true;
      }

      // Fallback check to /workplaces if custom /status route is not present
      final fallbackUri = Uri.parse('$baseUrl${AppConstants.endpointWorkplaces}');
      final fallbackRes = await http.get(fallbackUri).timeout(const Duration(seconds: 2));
      _isServerOnline = fallbackRes.statusCode >= 200 && fallbackRes.statusCode < 300;
      return _isServerOnline;
    } catch (e) {
      _isServerOnline = false;
      if (kDebugMode) {
        print('⚠️ [ApiService] Servidor REST json-server offline ou inacessível ($e).');
        print('ℹ️ [ApiService] Operando em modo de contingência local / offline.');
      }
      return false;
    }
  }

  /// Helper to get base URL
  static Future<String> getBaseUrl() async {
    final storage = await StorageService.getInstance();
    return storage.getApiBaseUrl();
  }
}
