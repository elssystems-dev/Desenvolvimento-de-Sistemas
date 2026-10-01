import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/time_record_model.dart';
import '../models/workplace_model.dart';
import '../utils/app_constants.dart';
import 'firebase_service.dart';
import 'storage_service.dart';

class FirestoreService {
  FirebaseFirestore? get _firestore =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  /// Saves or updates user document in Firestore
  Future<void> saveUserProfile(UserModel user) async {
    final storage = await StorageService.getInstance();
    await storage.saveUser(user);

    if (_firestore != null) {
      try {
        await _firestore!
            .collection(AppConstants.collectionUsers)
            .doc(user.id)
            .set(user.toMap(), SetOptions(merge: true));
        if (kDebugMode) {
          print('✅ [FirestoreService] User profile saved to Cloud Firestore.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [FirestoreService] Could not save user to Firestore: $e');
        }
      }
    }
  }

  /// Retrieves user document from Firestore or Local Cache
  Future<UserModel?> getUserProfile(String userId) async {
    if (_firestore != null) {
      try {
        final doc = await _firestore!
            .collection(AppConstants.collectionUsers)
            .doc(userId)
            .get();
        if (doc.exists && doc.data() != null) {
          final user = UserModel.fromMap(doc.data()!, doc.id);
          final storage = await StorageService.getInstance();
          await storage.saveUser(user);
          return user;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [FirestoreService] Error fetching user from Firestore: $e');
        }
      }
    }

    final storage = await StorageService.getInstance();
    return storage.getUser();
  }

  /// Saves a time record (punch clock) to Firestore and Local Storage
  Future<TimeRecordModel> recordPunch(TimeRecordModel record) async {
    final storage = await StorageService.getInstance();
    TimeRecordModel finalRecord = record;

    if (_firestore != null) {
      try {
        await _firestore!
            .collection(AppConstants.collectionTimeRecords)
            .doc(record.id)
            .set(record.toMap());
        finalRecord = record.copyWith(syncedWithServer: true);
        if (kDebugMode) {
          print('✅ [FirestoreService] Time record synchronized with Cloud Firestore.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [FirestoreService] Storing time record locally (offline mode): $e');
        }
        finalRecord = record.copyWith(syncedWithServer: false);
      }
    } else {
      finalRecord = record.copyWith(syncedWithServer: false);
    }

    await storage.saveTimeRecord(finalRecord);
    return finalRecord;
  }

  /// Retrieves all punch records for a specific user
  Future<List<TimeRecordModel>> getUserTimeRecords(String userId) async {
    final storage = await StorageService.getInstance();
    final localRecords = storage.getTimeRecords();

    if (_firestore != null) {
      try {
        final query = await _firestore!
            .collection(AppConstants.collectionTimeRecords)
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

        if (query.docs.isNotEmpty) {
          final serverRecords = query.docs
              .map((doc) => TimeRecordModel.fromMap(doc.data(), doc.id))
              .toList();

          // Sync local storage with latest server records
          for (final rec in serverRecords) {
            await storage.saveTimeRecord(rec.copyWith(syncedWithServer: true));
          }
          return serverRecords;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [FirestoreService] Fallback to local storage for records: $e');
        }
      }
    }

    return localRecords.where((r) => r.userId == userId || userId.isEmpty).toList();
  }

  /// Real-time stream of time records
  Stream<List<TimeRecordModel>> streamUserTimeRecords(String userId) {
    if (_firestore != null) {
      return _firestore!
          .collection(AppConstants.collectionTimeRecords)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TimeRecordModel.fromMap(doc.data(), doc.id))
              .toList());
    }
    return Stream.value([]);
  }

  /// Retrieves workplace list or default
  Future<List<WorkplaceModel>> getWorkplaces() async {
    final storage = await StorageService.getInstance();
    final active = storage.getWorkplace();
    return [active, WorkplaceModel.defaultHeadquarters];
  }
}
