import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  static FirebaseDatabase? _database;

  static FirebaseDatabase get database {
    _database ??= FirebaseDatabase.instance;
    return _database!;
  }

  static DatabaseReference get roomsRef => database.ref().child('rooms');
  static DatabaseReference get playersRef => database.ref().child('players');

  static DatabaseReference getRoomRef(String roomId) => roomsRef.child(roomId);
  static DatabaseReference getRoomPlayersRef(String roomId) =>
      getRoomRef(roomId).child('players');
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});