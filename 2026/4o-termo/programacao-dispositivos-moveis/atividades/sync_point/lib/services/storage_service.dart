import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/time_record_model.dart';
import '../models/workplace_model.dart';
import '../utils/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // --- User Session ---
  Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(AppConstants.keySavedUser, user.toJson());
  }

  UserModel? getUser() {
    final raw = _prefs?.getString(AppConstants.keySavedUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs?.remove(AppConstants.keySavedUser);
  }

  // --- Biometrics Preferences ---
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyBiometricEnabled, enabled);
  }

  bool isBiometricEnabled() {
    return _prefs?.getBool(AppConstants.keyBiometricEnabled) ?? false;
  }

  Future<void> saveRememberedLogin(String emailOrNif) async {
    await _prefs?.setString(AppConstants.keyRememberEmailOrNif, emailOrNif);
  }

  String? getRememberedLogin() {
    return _prefs?.getString(AppConstants.keyRememberEmailOrNif);
  }

  // --- Local Time Records (Offline & Realtime Cache) ---
  Future<void> saveTimeRecord(TimeRecordModel record) async {
    final list = getTimeRecords();
    // Prepend new record so newest is at the top
    list.removeWhere((r) => r.id == record.id);
    list.insert(0, record);
    final jsonList = list.map((e) => e.toMap()).toList();
    await _prefs?.setString(AppConstants.keyLocalRecords, json.encode(jsonList));
  }

  List<TimeRecordModel> getTimeRecords() {
    final raw = _prefs?.getString(AppConstants.keyLocalRecords);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((e) => TimeRecordModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearTimeRecords() async {
    await _prefs?.remove(AppConstants.keyLocalRecords);
  }

  // --- Custom Workplace Settings ---
  Future<void> saveCustomWorkplace(WorkplaceModel workplace) async {
    await _prefs?.setString(AppConstants.keyCustomWorkplace, workplace.toJson());
  }

  WorkplaceModel getWorkplace() {
    final raw = _prefs?.getString(AppConstants.keyCustomWorkplace);
    if (raw == null || raw.isEmpty) {
      return WorkplaceModel.defaultHeadquarters;
    }
    try {
      return WorkplaceModel.fromJson(raw);
    } catch (_) {
      return WorkplaceModel.defaultHeadquarters;
    }
  }

  Future<void> resetWorkplaceToDefault() async {
    await _prefs?.remove(AppConstants.keyCustomWorkplace);
  }
}
