import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ [FirebaseService] Firebase initialized successfully.');
      }
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('⚠️ [FirebaseService] Firebase not initialized or config pending: $e');
        print('ℹ️ [FirebaseService] Running with resilient local-first fallback mode.');
      }
    }
  }
}
