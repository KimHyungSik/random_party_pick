import 'package:random_party_pick/models/player.dart';

class Room {
  final String id;
  final String hostId;
  final String inviteCode;
  final DateTime createdAt;
  final int maxPlayers;
  final int redCardCount;
  final String status; // 'waiting', 'playing', 'finished'
  final Map<String, Player> players;
  final List<String> redPlayers;
  final List<String> greenPlayers;

  const Room({
    required this.id,
    required this.hostId,
    required this.inviteCode,
    required this.createdAt,
    this.maxPlayers = 8,
    this.redCardCount = 2,
    this.status = 'waiting',
    this.players = const {},
    this.redPlayers = const [],
    this.greenPlayers = const [],
  });

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,
      'redCardCount': redCardCount,
      'status': status,
      'players': players.map((key, player) => MapEntry(key, player.toJson())),
      'redPlayers': redPlayers,
      'greenPlayers': greenPlayers,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // players 필드를 안전하게 파싱
    final playersRaw = json['players'];
    final players = <String, Player>{};

    if (playersRaw != null) {
      // Object?를 Map으로 안전하게 변환
      final playersData = _safeMapConversion(playersRaw);

      for (final entry in playersData.entries) {
        try {
          // 각 플레이어 데이터도 안전하게 변환
          final playerData = _safeMapConversion(entry.value);
          if (playerData.isNotEmpty) {
            players[entry.key] = Player.fromJson(playerData);
          }
        } catch (e) {
          print('Error parsing player ${entry.key}: $e');
          // 개별 플레이어 파싱 실패 시 해당 플레이어만 스킵
        }
      }
    }

    return Room(
      id: json['id']?.toString() ?? '',
      hostId: json['hostId']?.toString() ?? '',
      inviteCode: json['inviteCode']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      maxPlayers: _parseInt(json['maxPlayers']) ?? 8,
      redCardCount: _parseInt(json['redCardCount']) ?? 2,
      status: json['status']?.toString() ?? 'waiting',
      players: players,
      redPlayers: _parseStringList(json['redPlayers']),
      greenPlayers: _parseStringList(json['greenPlayers']),
    );
  }

  // 안전한 Map 변환 헬퍼 메서드
  static Map<String, dynamic> _safeMapConversion(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(data.map(
            (key, value) => MapEntry(key.toString(), value),
      ));
    }
    return {};
  }

  // 안전한 DateTime 파싱
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
    return DateTime.now();
  }

  // 안전한 int 파싱
  static int? _parseInt(dynamic data) {
    if (data == null) return null;
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is String) {
      try {
        return int.parse(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 안전한 List<String> 파싱
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List<String>) return data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  // copyWith 메서드
  Room copyWith({
    String? id,
    String? hostId,
    String? inviteCode,
    DateTime? createdAt,
    int? maxPlayers,
    int? redCardCount,
    String? status,
    Map<String, Player>? players,
    List<String>? redPlayers,
    List<String>? greenPlayers,
  }) {
    return Room(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      redCardCount: redCardCount ?? this.redCardCount,
      status: status ?? this.status,
      players: players ?? this.players,
      redPlayers: redPlayers ?? this.redPlayers,
      greenPlayers: greenPlayers ?? this.greenPlayers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room &&
        other.id == id &&
        other.hostId == hostId &&
        other.inviteCode == inviteCode &&
        other.createdAt == createdAt &&
        other.maxPlayers == maxPlayers &&
        other.redCardCount == redCardCount &&
        other.status == status &&
        _mapEquals(other.players, players) &&
        _listEquals(other.redPlayers, redPlayers) &&
        _listEquals(other.greenPlayers, greenPlayers);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      hostId,
      inviteCode,
      createdAt,
      maxPlayers,
      redCardCount,
      status,
      players,
      redPlayers,
      greenPlayers,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, hostId: $hostId, inviteCode: $inviteCode, status: $status, players: ${players.length}, redPlayers: ${redPlayers.length}, greenPlayers: ${greenPlayers.length})';
  }

  // Helper methods for equality
  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}