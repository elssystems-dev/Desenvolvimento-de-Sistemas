import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../models/time_record_model.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Checks if device has biometric hardware supported and configured
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Lists available biometric hardware types (Face, Fingerprint, Iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Determines primary biometric method available
  Future<AuthMethod> getPrimaryAuthMethod() async {
    final list = await getAvailableBiometrics();
    if (list.contains(BiometricType.face)) {
      return AuthMethod.biometricFace;
    } else if (list.contains(BiometricType.fingerprint) || list.contains(BiometricType.strong)) {
      return AuthMethod.biometricFingerprint;
    }
    return AuthMethod.biometricFace;
  }

  /// Prompts biometric / facial authentication dialog
  Future<bool> authenticate({
    String reason = 'Confirme sua biometria / reconhecimento facial para autenticar no SyncPoint',
    bool biometricOnly = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
