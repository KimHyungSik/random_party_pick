import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../models/room.dart';
import '../models/player.dart';
import '../models/enums.dart';
import '../services/firebase_service.dart';

class GameRepositoryException implements Exception {
  final String message;
  final String? code;
  
  GameRepositoryException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

class GameRepository {
  final FirebaseService _firebaseService;
  final Map<String, StreamSubscription> _subscriptions = {};

  GameRepository(this._firebaseService);

  // Create room with transaction for atomicity
  Future<Room> createRoom({
    required String hostId,
    required String hostName,
    int redCardCount = 1,
  }) async {
    if (hostId.isEmpty || hostName.isEmpty) {
      throw GameRepositoryException('Host information is required');
    }
    
    final roomId = _generateRoomId();
    final inviteCode = await _generateUniqueInviteCode();
    final now = DateTime.now();

    final host = Player(
      id: hostId,
      name: hostName,
      joinedAt: now,
      isHost: true,
    );

    final room = Room(
      id: roomId,
      hostId: hostId,
      inviteCode: inviteCode,
      createdAt: now,
      redCardCount: redCardCount,
      players: {hostId: host},
      lastActivityAt: now,
      version: 1,
    );

    try {
      await FirebaseService.getRoomRef(roomId).set(room.toJson());
      return room;
    } catch (e) {
      throw GameRepositoryException('Failed to create room: $e');
    }
  }

  // Join room with proper validation
  Future<String> joinRoom({
    required String inviteCode,
    required String playerId,
    required String playerName,
  }) async {
    if (inviteCode.isEmpty || playerId.isEmpty || playerName.isEmpty) {
      throw GameRepositoryException('All fields are required');
    }
    
    try {
      // Find room by invite code
      final snapshot = await FirebaseService.roomsRef
          .orderByChild('inviteCode')
          .equalTo(inviteCode.toUpperCase())
          .once();

      if (snapshot.snapshot.value == null) {
        throw GameRepositoryException('Room not found', 'ROOM_NOT_FOUND');
      }

      final roomsData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      final roomId = roomsData.keys.first;
      final roomData = Map<String, dynamic>.from(roomsData[roomId]);
      final room = Room.fromJson(roomData);

      // Validate room state
      if (room.status != RoomStatus.waiting) {
        throw GameRepositoryException(
          'Game has already started or finished', 
          'GAME_NOT_WAITING'
        );
      }

      // Check if player name already exists
      final existingPlayer = room.players.values.firstWhere(
        (p) => p.name.toLowerCase() == playerName.toLowerCase() && p.id != playerId,
        orElse: () => Player(id: '', name: '', joinedAt: DateTime.now()),
      );
      
      if (existingPlayer.id.isNotEmpty) {
        throw GameRepositoryException(
          'This name is already taken in the room',
          'NAME_TAKEN'
        );
      }

      // Check room capacity
      if (room.players.length >= GameConstants.maxPlayers) {
        throw GameRepositoryException(
          'Room is full',
          'ROOM_FULL'
        );
      }

      // Add player with transaction to prevent race conditions
      final newPlayer = Player(
        id: playerId,
        name: playerName,
        joinedAt: DateTime.now(),
      );

      final playerRef = FirebaseService.getRoomPlayersRef(roomId).child(playerId);
      
      await playerRef.runTransaction((Object? player) {
        if (player != null && player is Map) {
          // Player already exists
          return Transaction.abort();
        }
        return Transaction.success(newPlayer.toJson());
      });

      // Update last activity
      await FirebaseService.getRoomRef(roomId).child('lastActivityAt')
          .set(DateTime.now().toIso8601String());

      return roomId;
    } catch (e) {
      if (e is GameRepositoryException) rethrow;
      throw GameRepositoryException('Failed to join room: $e');
    }
  }

  // Start game with transaction to prevent multiple starts
  Future<void> startGame(String roomId) async {
    if (roomId.isEmpty) {
      throw GameRepositoryException('Room ID is required');
    }
    
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      
      final transactionResult = await roomRef.runTransaction((Object? data) {
        if (data == null) {
          return Transaction.abort();
        }
        
        final roomData = Map<String, dynamic>.from(data as Map);
        final room = Room.fromJson(roomData);

        // Validate game can start
        if (room.status != RoomStatus.waiting) {
          throw GameRepositoryException('Game already started', 'ALREADY_STARTED');
        }

        if (room.players.length < GameConstants.minPlayers) {
          throw GameRepositoryException(
            'Need at least ${GameConstants.minPlayers} players to start',
            'NOT_ENOUGH_PLAYERS'
          );
        }

        if (room.redCardCount >= room.players.length) {
          throw GameRepositoryException(
            'Red card count must be less than total players',
            'INVALID_RED_COUNT'
          );
        }

        // Randomly assign cards
        final playerIds = room.players.keys.toList();
        final random = Random();
        final shuffledIds = List<String>.from(playerIds)..shuffle(random);
        final redPlayerIds = shuffledIds.take(room.redCardCount).toList();
        final greenPlayerIds = shuffledIds.skip(room.redCardCount).toList();

        // Update players with card colors
        final updatedPlayersMap = <String, Map<String, dynamic>>{};
        for (final playerId in playerIds) {
          final player = room.players[playerId]!;
          final cardColor = redPlayerIds.contains(playerId) 
              ? CardColor.red 
              : CardColor.green;
          final updatedPlayer = player.copyWith(cardColor: cardColor);
          updatedPlayersMap[playerId] = updatedPlayer.toJson();
        }

        // Return updated room data
        final updatedRoom = room.copyWith(
          status: RoomStatus.playing,
          redPlayers: redPlayerIds,
          greenPlayers: greenPlayerIds,
          players: room.players.map(
            (key, value) => MapEntry(
              key,
              value.copyWith(
                cardColor: redPlayerIds.contains(key) 
                    ? CardColor.red 
                    : CardColor.green,
              ),
            ),
          ),
          lastActivityAt: DateTime.now(),
        );

        return Transaction.success(updatedRoom.toJson());
      });

      if (!transactionResult.committed) {
        throw GameRepositoryException('Failed to start game - please try again');
      }
    } catch (e) {
      if (e is GameRepositoryException) rethrow;
      throw GameRepositoryException('Failed to start game: $e');
    }
  }

  // Finish game
  Future<void> finishGame(String roomId) async {
    await FirebaseService.getRoomRef(roomId).update({
      'status': RoomStatus.finished.value,
      'lastActivityAt': DateTime.now().toIso8601String(),
    });
  }

  // Reset game to waiting
  Future<void> resetGame(String roomId) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      
      await roomRef.runTransaction((Object? data) {
        if (data == null) return Transaction.abort();
        
        final roomData = Map<String, dynamic>.from(data as Map);
        final room = Room.fromJson(roomData);
        
        // Clear card assignments
        final clearedPlayers = <String, Map<String, dynamic>>{};
        for (final entry in room.players.entries) {
          final clearedPlayer = entry.value.copyWith(clearCardColor: true);
          clearedPlayers[entry.key] = clearedPlayer.toJson();
        }
        
        return Transaction.success({
          ...roomData,
          'status': RoomStatus.waiting.value,
          'redPlayers': [],
          'greenPlayers': [],
          'players': clearedPlayers,
          'lastActivityAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw GameRepositoryException('Failed to reset game: $e');
    }
  }

  // Kick player with proper validation
  Future<void> kickPlayer(String roomId, String playerId, String hostId) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      final snapshot = await roomRef.once();

      if (snapshot.snapshot.value == null) {
        throw GameRepositoryException('Room not found');
      }

      final roomData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      final room = Room.fromJson(roomData);

      // Validate permissions
      if (room.hostId != hostId) {
        throw GameRepositoryException(
          'Only the host can kick players',
          'NOT_HOST'
        );
      }

      if (playerId == hostId) {
        throw GameRepositoryException(
          'Cannot kick yourself',
          'SELF_KICK'
        );
      }

      if (!room.players.containsKey(playerId)) {
        throw GameRepositoryException(
          'Player not in room',
          'PLAYER_NOT_FOUND'
        );
      }

      if (room.status != RoomStatus.waiting) {
        throw GameRepositoryException(
          'Cannot kick players after game starts',
          'GAME_STARTED'
        );
      }

      // Remove player
      await FirebaseService.getRoomPlayersRef(roomId)
          .child(playerId)
          .remove();
          
      // Update last activity
      await roomRef.child('lastActivityAt')
          .set(DateTime.now().toIso8601String());
    } catch (e) {
      if (e is GameRepositoryException) rethrow;
      throw GameRepositoryException('Failed to kick player: $e');
    }
  }

  // Leave room with host transfer
  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      
      await roomRef.runTransaction((Object? data) {
        if (data == null) return Transaction.abort();
        
        final roomData = Map<String, dynamic>.from(data as Map);
        final room = Room.fromJson(roomData);
        
        // Remove player
        final remainingPlayers = Map<String, Player>.from(room.players);
        remainingPlayers.remove(playerId);
        
        if (remainingPlayers.isEmpty) {
          // Delete empty room
          return Transaction.success(null);
        }
        
        // Transfer host if needed
        String newHostId = room.hostId;
        if (room.hostId == playerId) {
          // Select new host (oldest player)
          final sortedPlayers = remainingPlayers.entries.toList()
            ..sort((a, b) => a.value.joinedAt.compareTo(b.value.joinedAt));
          newHostId = sortedPlayers.first.key;
          
          // Update new host flag
          final newHost = remainingPlayers[newHostId]!.copyWith(isHost: true);
          remainingPlayers[newHostId] = newHost;
        }
        
        // Update room
        final updatedRoom = room.copyWith(
          hostId: newHostId,
          players: remainingPlayers,
          lastActivityAt: DateTime.now(),
        );
        
        return Transaction.success(updatedRoom.toJson());
      });
    } catch (e) {
      throw GameRepositoryException('Failed to leave room: $e');
    }
  }

  // Watch room with error handling
  Stream<Room?> watchRoom(String roomId) {
    return FirebaseService.getRoomRef(roomId).onValue
        .map((event) {
          if (event.snapshot.value == null) return null;
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          return Room.fromJson(data);
        })
        .handleError((error) {
          print('Error watching room: $error');
          return null;
        });
  }

  // Update red card count with validation
  Future<void> updateRedCardCount(String roomId, int newRedCardCount) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      
      await roomRef.runTransaction((Object? data) {
        if (data == null) return Transaction.abort();
        
        final roomData = Map<String, dynamic>.from(data as Map);
        final room = Room.fromJson(roomData);

        // Validate
        if (room.status != RoomStatus.waiting) {
          throw GameRepositoryException(
            'Cannot change settings after game starts',
            'GAME_STARTED'
          );
        }

        if (newRedCardCount >= room.players.length) {
          throw GameRepositoryException(
            'Red card count must be less than total players',
            'INVALID_COUNT'
          );
        }

        if (newRedCardCount < GameConstants.minRedCards) {
          throw GameRepositoryException(
            'Minimum 1 red card required',
            'MIN_CARDS'
          );
        }
        
        return Transaction.success({
          ...roomData,
          'redCardCount': newRedCardCount,
          'lastActivityAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      if (e is GameRepositoryException) rethrow;
      throw GameRepositoryException('Failed to update red card count: $e');
    }
  }

  // Generate unique invite code
  Future<String> _generateUniqueInviteCode() async {
    const maxAttempts = 10;
    
    for (int i = 0; i < maxAttempts; i++) {
      final code = _generateInviteCode();
      
      // Check if code exists
      final snapshot = await FirebaseService.roomsRef
          .orderByChild('inviteCode')
          .equalTo(code)
          .once();
          
      if (snapshot.snapshot.value == null) {
        return code;
      }
    }
    
    // Fallback to longer code if can't find unique
    return '${_generateInviteCode()}${Random().nextInt(999)}';
  }

  // Utility methods
  String _generateRoomId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        GameConstants.inviteCodeLength,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Get room by invite code
  Future<Room?> getRoomByInviteCode(String inviteCode) async {
    try {
      final snapshot = await FirebaseService.roomsRef
          .orderByChild('inviteCode')
          .equalTo(inviteCode.toUpperCase())
          .once();

      if (snapshot.snapshot.value == null) {
        return null;
      }

      final roomsData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      if (roomsData.isEmpty) return null;

      final roomData = Map<String, dynamic>.from(roomsData.values.first);
      return Room.fromJson(roomData);
    } catch (e) {
      print('Error getting room by code: $e');
      return null;
    }
  }

  // Clean up old rooms (for maintenance)
  Future<void> cleanupOldRooms() async {
    try {
      final cutoffTime = DateTime.now().subtract(GameConstants.roomTimeout);
      
      final snapshot = await FirebaseService.roomsRef
          .orderByChild('lastActivityAt')
          .endAt(cutoffTime.toIso8601String())
          .once();
          
      if (snapshot.snapshot.value != null) {
        final rooms = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        
        for (final roomId in rooms.keys) {
          final room = Room.fromJson(Map<String, dynamic>.from(rooms[roomId]));
          if (room.status == RoomStatus.finished || room.players.isEmpty) {
            await FirebaseService.getRoomRef(roomId).remove();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up rooms: $e');
    }
  }

  // Dispose subscriptions
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}