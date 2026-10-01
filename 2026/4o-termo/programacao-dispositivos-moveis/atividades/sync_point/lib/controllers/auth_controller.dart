import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBiometricHardwareAvailable = false;
  bool _isBiometricEnrolledInApp = false;
  String? _rememberedLogin;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBiometricHardwareAvailable => _isBiometricHardwareAvailable;
  bool get isBiometricEnrolledInApp => _isBiometricEnrolledInApp;
  String? get rememberedLogin => _rememberedLogin;

  /// Initializes auth controller state, loads saved session & checks hardware
  Future<void> init() async {
    _setLoading(true);
    try {
      final storage = await StorageService.getInstance();
      _rememberedLogin = storage.getRememberedLogin();
      _isBiometricEnrolledInApp = storage.isBiometricEnabled();
      _isBiometricHardwareAvailable = await _biometricService.isBiometricAvailable();
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Login with NIF or Email + Password
  Future<bool> login({
    required String emailOrNif,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.signIn(
        emailOrNif: emailOrNif,
        password: password,
      );
      _currentUser = user;
      final storage = await StorageService.getInstance();
      _isBiometricEnrolledInApp = storage.isBiometricEnabled();
      _rememberedLogin = emailOrNif;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// One-touch Biometric / Face Recognition Login
  Future<bool> loginWithBiometrics() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.signInWithBiometrics();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new employee
  Future<bool> register({
    required String name,
    required String nif,
    required String email,
    required String password,
    required String department,
    required String role,
    bool enableBiometrics = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.register(
        name: name,
        nif: nif,
        email: email,
        password: password,
        department: department,
        role: role,
        enableBiometrics: enableBiometrics,
      );
      _currentUser = user;
      _isBiometricEnrolledInApp = enableBiometrics;
      _rememberedLogin = nif.isNotEmpty ? nif : email;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle Biometric enrollment for the current user
  Future<void> toggleBiometric(bool enabled) async {
    final storage = await StorageService.getInstance();
    await storage.setBiometricEnabled(enabled);
    _isBiometricEnrolledInApp = enabled;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isBiometricEnabled: enabled);
      await storage.saveUser(_currentUser!);
    }
    notifyListeners();
  }

  /// Sign out
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
