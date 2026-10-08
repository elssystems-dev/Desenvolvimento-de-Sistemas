import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/time_record_model.dart';
import '../models/workplace_model.dart';
import '../utils/app_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class RecordApiService {
  /// Salva ou atualiza os dados do colaborador no json-server e no cache local
  Future<void> saveUserProfile(UserModel user) async {
    final storage = await StorageService.getInstance();
    await storage.saveUser(user);

    try {
      final baseUrl = storage.getApiBaseUrl();
      final checkUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}/${user.id}');
      final checkRes = await http.get(checkUri).timeout(const Duration(seconds: 3));

      if (checkRes.statusCode == 200) {
        // Usuário já existe -> PUT para atualizar
        final updateUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}/${user.id}');
        await http.put(
          updateUri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toMap()),
        ).timeout(const Duration(seconds: 3));
      } else {
        // Usuário não existe -> POST para criar
        final postUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}');
        await http.post(
          postUri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toMap()),
        ).timeout(const Duration(seconds: 3));
      }

      if (kDebugMode) {
        print('✅ [RecordApiService] Perfil do usuário sincronizado com json-server.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RecordApiService] Falha ao enviar usuário para json-server (armazenado localmente): $e');
      }
    }
  }

  /// Recupera perfil do colaborador do json-server ou do cache local
  Future<UserModel?> getUserProfile(String userId) async {
    final storage = await StorageService.getInstance();

    try {
      final baseUrl = storage.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl${AppConstants.endpointUsers}/$userId');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        final user = UserModel.fromMap(data, userId);
        await storage.saveUser(user);
        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RecordApiService] Erro ao buscar usuário no servidor REST, usando cache local: $e');
      }
    }

    return storage.getUser();
  }

  /// Registra um novo ponto eletrônico no json-server (POST /time_records) e persiste no cache local
  Future<TimeRecordModel> recordPunch(TimeRecordModel record) async {
    final storage = await StorageService.getInstance();
    TimeRecordModel finalRecord = record;

    try {
      final baseUrl = storage.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl${AppConstants.endpointTimeRecords}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(record.toMap()),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        finalRecord = record.copyWith(syncedWithServer: true);
        if (kDebugMode) {
          print('✅ [RecordApiService] Ponto sincronizado com sucesso no json-server.');
        }
      } else {
        finalRecord = record.copyWith(syncedWithServer: false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RecordApiService] Erro de rede com json-server. Gravando registro apenas no modo offline: $e');
      }
      finalRecord = record.copyWith(syncedWithServer: false);
    }

    await storage.saveTimeRecord(finalRecord);
    return finalRecord;
  }

  /// Recupera todos os registros de ponto de um colaborador (GET /time_records?userId=...)
  Future<List<TimeRecordModel>> getUserTimeRecords(String userId) async {
    final storage = await StorageService.getInstance();
    final localRecords = storage.getTimeRecords();

    try {
      final baseUrl = storage.getApiBaseUrl();
      final uri = Uri.parse(
        userId.isNotEmpty
            ? '$baseUrl${AppConstants.endpointTimeRecords}?userId=$userId'
            : '$baseUrl${AppConstants.endpointTimeRecords}',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        if (list.isNotEmpty) {
          final serverRecords = list
              .map((item) => TimeRecordModel.fromMap(item as Map<String, dynamic>))
              .toList();

          // Ordena do mais recente para o mais antigo
          serverRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Atualiza o cache local com os registros recebidos do servidor
          for (final rec in serverRecords) {
            await storage.saveTimeRecord(rec.copyWith(syncedWithServer: true));
          }
          return serverRecords;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [RecordApiService] Fallback para armazenamento local ao listar pontos: $e');
      }
    }

    // Retorna do cache local caso offline ou sem conexão
    final filtered = localRecords.where((r) => r.userId == userId || userId.isEmpty).toList();
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  /// Obtém locais de trabalho corporativos
  Future<List<WorkplaceModel>> getWorkplaces() async {
    final storage = await StorageService.getInstance();

    try {
      final baseUrl = storage.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl${AppConstants.endpointWorkplaces}');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        if (list.isNotEmpty) {
          return list.map((item) => WorkplaceModel.fromJson(json.encode(item))).toList();
        }
      }
    } catch (_) {}

    final active = storage.getWorkplace();
    return [active, WorkplaceModel.defaultHeadquarters];
  }
}
