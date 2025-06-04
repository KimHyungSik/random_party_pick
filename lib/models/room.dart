import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String hostId,
    required String inviteCode,
    required DateTime createdAt,
    @Default(8) int maxPlayers,
    @Default(2) int redCardCount,
    @Default('waiting') String status, // 'waiting', 'playing', 'finished'
    @Default({}) Map<String, Player> players,
    @Default([]) List<String> redPlayers,
    @Default([]) List<String> greenPlayers,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}