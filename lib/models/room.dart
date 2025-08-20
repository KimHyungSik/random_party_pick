import 'package:random_party_pick/models/player.dart';
import 'enums.dart';

class Room {
  final String id;
  final String hostId;
  final String inviteCode;
  final DateTime createdAt;
  final int redCardCount;
  final RoomStatus status;
  final Map<String, Player> players;
  final List<String> redPlayers;
  final List<String> greenPlayers;
  final DateTime? lastActivityAt;
  final int? version; // For optimistic locking

  const Room({
    required this.id,
    required this.hostId,
    required this.inviteCode,
    required this.createdAt,
    this.redCardCount = 1,
    this.status = RoomStatus.waiting,
    this.players = const {},
    this.redPlayers = const [],
    this.greenPlayers = const [],
    this.lastActivityAt,
    this.version,
  });

  // Validation methods
  bool get isValid => players.isNotEmpty && hostId.isNotEmpty;
  bool get canStart => players.length >= GameConstants.minPlayers && 
                       status == RoomStatus.waiting;
  bool get isActive => status != RoomStatus.finished;
  
  // JSON conversion with improved type safety
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
      'redCardCount': redCardCount,
      'status': status.value,
      'players': players.map((key, player) => MapEntry(key, player.toJson())),
      'redPlayers': redPlayers,
      'greenPlayers': greenPlayers,
      'lastActivityAt': (lastActivityAt ?? DateTime.now()).toIso8601String(),
      'version': (version ?? 0) + 1,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // Parse players with error handling
    final players = <String, Player>{};
    final playersData = json['players'];
    
    if (playersData != null && playersData is Map) {
      for (final entry in playersData.entries) {
        try {
          final playerData = entry.value;
          if (playerData is Map<String, dynamic>) {
            players[entry.key.toString()] = Player.fromJson(playerData);
          }
        } catch (e) {
          // Skip invalid player data
          print('Error parsing player ${entry.key}: $e');
        }
      }
    }

    return Room(
      id: json['id']?.toString() ?? '',
      hostId: json['hostId']?.toString() ?? '',
      inviteCode: json['inviteCode']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      redCardCount: _parseInt(json['redCardCount']) ?? GameConstants.minRedCards,
      status: RoomStatus.fromString(json['status']?.toString() ?? 'waiting'),
      players: players,
      redPlayers: _parseStringList(json['redPlayers']),
      greenPlayers: _parseStringList(json['greenPlayers']),
      lastActivityAt: _parseDateTime(json['lastActivityAt']),
      version: _parseInt(json['version']),
    );
  }

  // Helper methods for safe parsing
  static DateTime _parseDateTime(dynamic data) {
    if (data == null) return DateTime.now();
    if (data is DateTime) return data;
    if (data is String) {
      try {
        return DateTime.parse(data);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (data is int) {
      return DateTime.fromMillisecondsSinceEpoch(data);
    }
    return DateTime.now();
  }

  static int? _parseInt(dynamic data) {
    if (data == null) return null;
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) {
      return int.tryParse(data);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Object>().map((e) => e.toString()).toList();
    }
    return [];
  }

  // copyWith method with validation
  Room copyWith({
    String? id,
    String? hostId,
    String? inviteCode,
    DateTime? createdAt,
    int? redCardCount,
    RoomStatus? status,
    Map<String, Player>? players,
    List<String>? redPlayers,
    List<String>? greenPlayers,
    DateTime? lastActivityAt,
    int? version,
  }) {
    // Validate red card count
    final newRedCardCount = redCardCount ?? this.redCardCount;
    final newPlayers = players ?? this.players;
    
    if (newRedCardCount >= newPlayers.length && newPlayers.length > 0) {
      throw ArgumentError('Red card count must be less than total players');
    }
    
    return Room(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      redCardCount: newRedCardCount,
      status: status ?? this.status,
      players: newPlayers,
      redPlayers: redPlayers ?? this.redPlayers,
      greenPlayers: greenPlayers ?? this.greenPlayers,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt ?? DateTime.now(),
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room &&
        other.id == id &&
        other.version == version;
  }

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() {
    return 'Room(id: $id, status: ${status.value}, players: ${players.length})';
  }
}