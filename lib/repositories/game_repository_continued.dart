        ) {
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