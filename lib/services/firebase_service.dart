import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  static FirebaseDatabase? _database;

  static FirebaseDatabase get database {
    if (_database == null) {
      _database = FirebaseDatabase.instance;

      // Configure persistence based on environment
      if (kReleaseMode) {
        // Production configuration
        _database!.setPersistenceEnabled(true);
        _database!.setPersistenceCacheSizeBytes(10000000); // 10MB
      } else {
        // Debug configuration
        _database!.setPersistenceEnabled(false);
        if (kDebugMode) {
          print('Firebase Database initialized in DEBUG mode (persistence disabled)');
        }
      }
    }
    return _database!;
  }

  // 환경별 경로 분리
  static String get _environmentPrefix => kReleaseMode ? 'prod' : 'dev';

  static DatabaseReference get roomsRef =>
      database.ref().child('$_environmentPrefix/rooms');
  static DatabaseReference get playersRef =>
      database.ref().child('$_environmentPrefix/players');

  static DatabaseReference getRoomRef(String roomId) => roomsRef.child(roomId);
  static DatabaseReference getRoomPlayersRef(String roomId) =>
      getRoomRef(roomId).child('players');
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});