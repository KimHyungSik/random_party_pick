// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
      id: json['id'] as String,
      hostId: json['hostId'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 8,
      redCardCount: (json['redCardCount'] as num?)?.toInt() ?? 2,
      status: json['status'] as String? ?? 'waiting',
      players: (json['players'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Player.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      redPlayers: (json['redPlayers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      greenPlayers: (json['greenPlayers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostId': instance.hostId,
      'inviteCode': instance.inviteCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'maxPlayers': instance.maxPlayers,
      'redCardCount': instance.redCardCount,
      'status': instance.status,
      'players': instance.players,
      'redPlayers': instance.redPlayers,
      'greenPlayers': instance.greenPlayers,
    };
