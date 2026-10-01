import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'biometric_service.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';

class AuthService {
  final BiometricService _biometricService = BiometricService();
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  FirebaseAuth? get _auth =>
      FirebaseService.isInitialized ? FirebaseAuth.instance : null;

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

  /// Sign in with Email or NIF + Password
  Future<UserModel> signIn({
    required String emailOrNif,
    required String password,
  }) async {
    final normalizedEmail = normalizeLoginToEmail(emailOrNif);
    final storage = await StorageService.getInstance();

    if (_auth != null) {
      try {
        final UserCredential credential = await _auth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final uid = credential.user?.uid ?? '';
        final profile = await _firestoreService.getUserProfile(uid);

        if (profile != null) {
          await storage.saveUser(profile);
          await storage.saveRememberedLogin(emailOrNif);
          return profile;
        } else {
          // If profile does not exist yet in Firestore, create basic profile
          final newProfile = UserModel(
            id: uid,
            nif: emailOrNif.contains('@') ? 'NIF-${uid.substring(0, 6)}' : emailOrNif,
            name: credential.user?.displayName ?? 'Colaborador',
            email: credential.user?.email ?? normalizedEmail,
            role: 'Colaborador',
            department: 'Tecnologia da Informação',
            createdAt: DateTime.now(),
          );
          await _firestoreService.saveUserProfile(newProfile);
          await storage.saveUser(newProfile);
          await storage.saveRememberedLogin(emailOrNif);
          return newProfile;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [AuthService] FirebaseAuth login failed ($e). Checking local fallback.');
        }
        // If Firebase error occurs, throw clean message
        throw Exception(_formatFirebaseAuthError(e));
      }
    } else {
      // Local-first / Demo Mode fallback when Firebase credentials are not yet configured
      final savedUser = storage.getUser();
      if (savedUser != null &&
          (savedUser.email.toLowerCase() == normalizedEmail ||
              savedUser.nif.toLowerCase() == emailOrNif.toLowerCase())) {
        await storage.saveRememberedLogin(emailOrNif);
        return savedUser;
      }

      // Generate simulated user for quick testing
      final isNif = !emailOrNif.contains('@');
      final fallbackUser = UserModel(
        id: 'user-${_uuid.v4().substring(0, 8)}',
        nif: isNif ? emailOrNif : 'NIF-883921',
        name: isNif ? 'Colaborador (NIF $emailOrNif)' : emailOrNif.split('@').first,
        email: normalizedEmail,
        role: 'Engenheiro de Software',
        department: 'Engenharia & Operações',
        isBiometricEnabled: true,
        createdAt: DateTime.now(),
      );
      await storage.saveUser(fallbackUser);
      await storage.saveRememberedLogin(emailOrNif);
      return fallbackUser;
    }
  }

  /// Register a new employee
  Future<UserModel> register({
    required String name,
    required String nif,
    required String email,
    required String password,
    required String department,
    required String role,
    bool enableBiometrics = false,
  }) async {
    final normalizedEmail = email.contains('@') ? email.trim().toLowerCase() : normalizeLoginToEmail(nif);
    final storage = await StorageService.getInstance();

    if (_auth != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        await credential.user?.updateDisplayName(name);

        final uid = credential.user?.uid ?? _uuid.v4();
        final newUser = UserModel(
          id: uid,
          nif: nif.trim().toUpperCase(),
          name: name.trim(),
          email: normalizedEmail,
          role: role.trim(),
          department: department.trim(),
          isBiometricEnabled: enableBiometrics,
          createdAt: DateTime.now(),
        );

        await _firestoreService.saveUserProfile(newUser);
        await storage.saveUser(newUser);
        await storage.setBiometricEnabled(enableBiometrics);
        await storage.saveRememberedLogin(nif.isNotEmpty ? nif : email);

        return newUser;
      } catch (e) {
        throw Exception(_formatFirebaseAuthError(e));
      }
    } else {
      // Local fallback registration
      final newUser = UserModel(
        id: 'user-${_uuid.v4().substring(0, 8)}',
        nif: nif.trim().toUpperCase(),
        name: name.trim(),
        email: normalizedEmail,
        role: role.trim().isNotEmpty ? role.trim() : 'Colaborador',
        department: department.trim().isNotEmpty ? department.trim() : 'Tecnologia da Informação',
        isBiometricEnabled: enableBiometrics,
        createdAt: DateTime.now(),
      );

      await storage.saveUser(newUser);
      await storage.setBiometricEnabled(enableBiometrics);
      await storage.saveRememberedLogin(nif.isNotEmpty ? nif : email);
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
    if (_auth != null) {
      await _auth!.signOut();
    }
    final storage = await StorageService.getInstance();
    await storage.clearUser();
  }

  /// Get active current user session
  Future<UserModel?> getCurrentUser() async {
    final storage = await StorageService.getInstance();
    final localUser = storage.getUser();
    if (localUser != null) return localUser;

    if (_auth != null && _auth!.currentUser != null) {
      final uid = _auth!.currentUser!.uid;
      return await _firestoreService.getUserProfile(uid);
    }
    return null;
  }

  String _formatFirebaseAuthError(dynamic error) {
    final message = error.toString();
    if (message.contains('user-not-found')) {
      return 'Usuário ou NIF não encontrado.';
    } else if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'Senha incorreta. Verifique suas credenciais.';
    } else if (message.contains('email-already-in-use')) {
      return 'Este e-mail ou NIF já está cadastrado no sistema.';
    } else if (message.contains('weak-password')) {
      return 'A senha deve conter no mínimo 6 caracteres.';
    } else if (message.contains('invalid-email')) {
      return 'Formato de e-mail ou NIF inválido.';
    } else if (message.contains('network-request-failed')) {
      return 'Sem conexão com a internet para autenticação no Firebase.';
    }
    return 'Erro de autenticação: ${message.replaceAll('Exception: ', '')}';
  }
}
