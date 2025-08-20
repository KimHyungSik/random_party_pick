import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  static FirebaseDatabase? _database;
  static bool _persistenceInitialized = false;

  static FirebaseDatabase get database {
    if (_database == null) {
      _database = FirebaseDatabase.instance;

      // Only set persistence once and handle web platform
      if (!_persistenceInitialized && !kIsWeb) {
        try {
          // Configure persistence based on environment
          if (kReleaseMode) {
            _database!.setPersistenceEnabled(true);
            _database!.setPersistenceCacheSizeBytes(10000000); // 10MB
          } else {
            // Debug mode - persistence disabled for easier testing
            _database!.setPersistenceEnabled(false);
          }
          _persistenceInitialized = true;
          
          if (kDebugMode) {
            print('Firebase Database initialized (persistence: ${kReleaseMode})');
          }
        } catch (e) {
          // Persistence already set, ignore error
          if (kDebugMode) {
            print('Firebase persistence already configured: $e');
          }
        }
      }
      
      // Set offline persistence for web
      if (kIsWeb) {
        _database!.goOffline();
        _database!.goOnline();
      }
    }
    return _database!;
  }

  // Environment-based path separation
  static String get _environmentPrefix => kReleaseMode ? 'prod' : 'dev';

  static DatabaseReference get roomsRef =>
      database.ref().child('$_environmentPrefix/rooms');
  static DatabaseReference get playersRef =>
      database.ref().child('$_environmentPrefix/players');

  static DatabaseReference getRoomRef(String roomId) => roomsRef.child(roomId);
  static DatabaseReference getRoomPlayersRef(String roomId) =>
      getRoomRef(roomId).child('players');
  
  // Connection state monitoring
  static Stream<bool> get connectionStream {
    return database.ref('.info/connected').onValue.map(
      (event) => event.snapshot.value as bool? ?? false,
    );
  }
  
  // Clean up resources
  static Future<void> dispose() async {
    await _database?.goOffline();
    _database = null;
    _persistenceInitialized = false;
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  // Clean up on dispose
  ref.onDispose(() {
    FirebaseService.dispose();
  });
  
  return FirebaseService();
});

// Connection state provider
final connectionStateProvider = StreamProvider<bool>((ref) {
  return FirebaseService.connectionStream;
});