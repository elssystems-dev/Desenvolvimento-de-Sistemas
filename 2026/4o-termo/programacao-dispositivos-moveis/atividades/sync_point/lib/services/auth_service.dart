import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'biometric_service.dart';
import 'record_api_service.dart';
import 'storage_service.dart';

class AuthService {
  final BiometricService _biometricService = BiometricService();
  final RecordApiService _recordApiService = RecordApiService();
  final Uuid _uuid = const Uuid();

  /// Helper to convert a NIF (e.g., "123456" or "NIF98765") into a standardized auth email
  static String normalizeLoginToEmail(String login) {
    final trimmed = login.trim();
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }
    // Clean non-alphanumeric characters for NIF
    final cleanNif = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return '$cleanNif@syncpoint.internal';
  }

  /// Sign in with Email or NIF + Password via json-server REST API
  Future<UserModel> signIn({
    required String emailOrNif,
    required String password,
  }) async {
    final storage = await StorageService.getInstance();
    final baseUrl = storage.getApiBaseUrl();
    final trimmedLogin = emailOrNif.trim();

    try {
      // 1. Consulta usuário no backend json-server por e-mail ou NIF
      List<dynamic> usersFound = [];

      if (trimmedLogin.contains('@')) {
        final uri = Uri.parse('$baseUrl${AppConstants.endpointUsers}?email=${Uri.encodeComponent(trimmedLogin.toLowerCase())}');
        final res = await http.get(uri).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          usersFound = json.decode(res.body);
        }
      } else {
        // Tenta buscar por NIF (maiúsculo e como digitado)
        final uriNif = Uri.parse('$baseUrl${AppConstants.endpointUsers}?nif=${Uri.encodeComponent(trimmedLogin.toUpperCase())}');
        var res = await http.get(uriNif).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          usersFound = json.decode(res.body);
        }

        // Se não achou, tenta pelo NIF exato sem alterar case
        if (usersFound.isEmpty) {
          final uriRaw = Uri.parse('$baseUrl${AppConstants.endpointUsers}?nif=${Uri.encodeComponent(trimmedLogin)}');
          res = await http.get(uriRaw).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            usersFound = json.decode(res.body);
          }
        }
      }

      if (usersFound.isNotEmpty) {
        final userData = usersFound.first as Map<String, dynamic>;

        // Validação da senha
        final serverPassword = userData['password']?.toString();
        if (serverPassword != null && serverPassword.isNotEmpty && serverPassword != password) {
          throw Exception('Senha incorreta. Verifique suas credenciais.');
        }

        final user = UserModel.fromMap(userData, userData['id']?.toString());
        await storage.saveUser(user);
        await storage.saveRememberedLogin(emailOrNif);
        if (userData['isBiometricEnabled'] == true) {
          await storage.setBiometricEnabled(true);
        }

        if (kDebugMode) {
          print('✅ [AuthService] Login efetuado com sucesso via json-server: ${user.name}');
        }
        return user;
      } else {
        throw Exception('Usuário ou NIF não encontrado.');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('Senha incorreta') || errorMsg.contains('não encontrado')) {
        rethrow;
      }

      if (kDebugMode) {
        print('⚠️ [AuthService] Falha de conexão com json-server ($e). Verificando cache local.');
      }

      // Contingência Offline: se o usuário já havia feito login antes neste aparelho
      final savedUser = storage.getUser();
      if (savedUser != null &&
          (savedUser.email.toLowerCase() == trimmedLogin.toLowerCase() ||
              savedUser.nif.toLowerCase() == trimmedLogin.toLowerCase())) {
        await storage.saveRememberedLogin(emailOrNif);
        return savedUser;
      }

      throw Exception(
        'Não foi possível conectar ao servidor REST ($baseUrl).\n'
        'Certifique-se de que o backend json-server está rodando com: npm start na pasta server/',
      );
    }
  }

  /// Register a new employee via json-server REST API (POST /users)
  Future<UserModel> register({
    required String name,
    required String nif,
    required String email,
    required String password,
    required String department,
    required String role,
    bool enableBiometrics = false,
  }) async {
    final storage = await StorageService.getInstance();
    final baseUrl = storage.getApiBaseUrl();
    final normalizedEmail = email.contains('@') ? email.trim().toLowerCase() : normalizeLoginToEmail(nif);
    final cleanNif = nif.trim().toUpperCase();

    try {
      // 1. Verifica se NIF ou E-mail já existem no json-server
      final checkNifUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}?nif=${Uri.encodeComponent(cleanNif)}');
      final resNif = await http.get(checkNifUri).timeout(const Duration(seconds: 4));
      if (resNif.statusCode == 200) {
        final List<dynamic> found = json.decode(resNif.body);
        if (found.isNotEmpty) {
          throw Exception('Este NIF já está cadastrado no sistema.');
        }
      }

      final checkEmailUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}?email=${Uri.encodeComponent(normalizedEmail)}');
      final resEmail = await http.get(checkEmailUri).timeout(const Duration(seconds: 4));
      if (resEmail.statusCode == 200) {
        final List<dynamic> found = json.decode(resEmail.body);
        if (found.isNotEmpty) {
          throw Exception('Este e-mail já está cadastrado no sistema.');
        }
      }

      // 2. Cria o novo usuário no servidor
      final uid = 'usr-${_uuid.v4().substring(0, 8)}';
      final newUser = UserModel(
        id: uid,
        nif: cleanNif,
        name: name.trim(),
        email: normalizedEmail,
        role: role.trim().isNotEmpty ? role.trim() : 'Colaborador',
        department: department.trim().isNotEmpty ? department.trim() : 'Tecnologia da Informação',
        isBiometricEnabled: enableBiometrics,
        createdAt: DateTime.now(),
      );

      final payload = {
        ...newUser.toMap(),
        'password': password,
      };

      final postUri = Uri.parse('$baseUrl${AppConstants.endpointUsers}');
      final postRes = await http.post(
        postUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));

      if (postRes.statusCode >= 200 && postRes.statusCode < 300) {
        await storage.saveUser(newUser);
        await storage.setBiometricEnabled(enableBiometrics);
        await storage.saveRememberedLogin(cleanNif.isNotEmpty ? cleanNif : normalizedEmail);

        if (kDebugMode) {
          print('✅ [AuthService] Colaborador cadastrado no json-server: ${newUser.name}');
        }
        return newUser;
      } else {
        throw Exception('Falha ao cadastrar no servidor REST (Status: ${postRes.statusCode}).');
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('já está cadastrado')) {
        rethrow;
      }

      if (kDebugMode) {
        print('⚠️ [AuthService] Erro no servidor REST, registrando em contingência local: $e');
      }

      // Registro local offline de contingência
      final newUser = UserModel(
        id: 'usr-${_uuid.v4().substring(0, 8)}',
        nif: cleanNif,
        name: name.trim(),
        email: normalizedEmail,
        role: role.trim().isNotEmpty ? role.trim() : 'Colaborador',
        department: department.trim().isNotEmpty ? department.trim() : 'Tecnologia da Informação',
        isBiometricEnabled: enableBiometrics,
        createdAt: DateTime.now(),
      );

      await storage.saveUser(newUser);
      await storage.setBiometricEnabled(enableBiometrics);
      await storage.saveRememberedLogin(cleanNif.isNotEmpty ? cleanNif : normalizedEmail);
      return newUser;
    }
  }

  /// Fast Biometric / Facial Recognition Login
  Future<UserModel?> signInWithBiometrics() async {
    final storage = await StorageService.getInstance();
    final savedUser = storage.getUser();

    if (savedUser == null) {
      throw Exception('Nenhum usuário cadastrado previamente neste dispositivo para autenticação biométrica. Faça o primeiro login com NIF/Senha.');
    }

    final bool authenticated = await _biometricService.authenticate(
      reason: 'Aproxime seu rosto ou digital para entrar no SyncPoint',
    );

    if (authenticated) {
      return savedUser;
    } else {
      throw Exception('Autenticação biométrica / facial não foi confirmada.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final storage = await StorageService.getInstance();
    await storage.clearUser();
  }

  /// Get active current user session
  Future<UserModel?> getCurrentUser() async {
    final storage = await StorageService.getInstance();
    return storage.getUser();
  }
}
