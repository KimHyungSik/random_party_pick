import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../models/player.dart';
import '../services/firebase_service.dart';

class GameRepository {
  final FirebaseService _firebaseService;

  GameRepository(this._firebaseService);

  // 방 생성
  Future<Room> createRoom({
    required String hostId,
    required String hostName,
    int maxPlayers = 8,
    int redCardCount = 2,
  }) async {
    final roomId = _generateRoomId();
    final inviteCode = _generateInviteCode();
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
      maxPlayers: maxPlayers,
      redCardCount: redCardCount,
      players: {hostId: host},
    );

    // 직접 toJson() 사용 가능
    await FirebaseService.getRoomRef(roomId).set(room.toJson());
    return room;
  }

  // 방 참가
  Future<String> joinRoom({
    required String inviteCode,
    required String playerId,
    required String playerName,
  }) async {
    try {
      // 초대코드로 방 찾기
      final snapshot = await FirebaseService.roomsRef
          .orderByChild('inviteCode')
          .equalTo(inviteCode)
          .once();

      if (snapshot.snapshot.value == null) {
        throw Exception('방을 찾을 수 없습니다.');
      }

      final roomsData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      final roomId = roomsData.keys.first;
      final roomData = Map<String, dynamic>.from(roomsData[roomId]);
      final room = Room.fromJson(roomData);

      // 방 상태 확인
      if (room.status != 'waiting') {
        throw Exception('게임이 이미 시작되었거나 종료되었습니다.');
      }

      // 인원 수 확인
      if (room.players.length >= room.maxPlayers) {
        throw Exception('방이 가득 찼습니다.');
      }

      // 플레이어 추가
      final newPlayer = Player(
        id: playerId,
        name: playerName,
        joinedAt: DateTime.now(),
      );

      await FirebaseService.getRoomPlayersRef(roomId)
          .child(playerId)
          .set(newPlayer.toJson());

      return roomId;
    } catch (e) {
      throw Exception('방 참가 실패: ${e.toString()}');
    }
  }

  // 게임 시작 (랜덤 카드 배분)
  Future<void> startGame(String roomId) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      final snapshot = await roomRef.once();

      if (snapshot.snapshot.value == null) {
        throw Exception('방을 찾을 수 없습니다.');
      }

      final roomData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      final room = Room.fromJson(roomData);

      if (room.status != 'waiting') {
        throw Exception('이미 시작된 게임입니다.');
      }

      final playerIds = room.players.keys.toList();
      final random = Random();

      // 랜덤하게 빨간 카드 받을 플레이어 선택
      final shuffledIds = List<String>.from(playerIds)..shuffle(random);
      final redPlayerIds = shuffledIds.take(room.redCardCount).toList();
      final greenPlayerIds = shuffledIds.skip(room.redCardCount).toList();

      // 플레이어들에게 카드 색깔 배정
      final updatedPlayersMap = <String, Map<String, dynamic>>{};
      for (final playerId in playerIds) {
        final player = room.players[playerId]!;
        final cardColor = redPlayerIds.contains(playerId) ? 'red' : 'green';
        final updatedPlayer = player.copyWith(cardColor: cardColor);
        updatedPlayersMap[playerId] = updatedPlayer.toJson();
      }

      // 방 상태 업데이트
      await roomRef.update({
        'status': 'playing',
        'redPlayers': redPlayerIds,
        'greenPlayers': greenPlayerIds,
        'players': updatedPlayersMap,
      });
    } catch (e) {
      throw Exception('게임 시작 실패: ${e.toString()}');
    }
  }

  // 게임 종료
  Future<void> finishGame(String roomId) async {
    await FirebaseService.getRoomRef(roomId).update({'status': 'finished'});
  }

  // 방 나가기
  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = FirebaseService.getRoomRef(roomId);
      final snapshot = await roomRef.once();

      if (snapshot.snapshot.value == null) return;

      final roomData = Map<String, dynamic>.from(
          snapshot.snapshot.value as Map);
      final room = Room.fromJson(roomData);

      // 플레이어 제거
      await FirebaseService.getRoomPlayersRef(roomId)
          .child(playerId)
          .remove();

      // 방장이 나가면 방 삭제 또는 다른 사람에게 방장 위임
      if (room.hostId == playerId) {
        final remainingPlayers = Map<String, Player>.from(room.players);
        remainingPlayers.remove(playerId);

        if (remainingPlayers.isEmpty) {
          // 방 삭제
          await roomRef.remove();
        } else {
          // 새로운 방장 지정
          final newHostId = remainingPlayers.keys.first;
          final updatedPlayersMap = <String, Map<String, dynamic>>{};

          for (final entry in remainingPlayers.entries) {
            final playerId = entry.key;
            final player = entry.value;
            final updatedPlayer = playerId == newHostId
                ? player.copyWith(isHost: true)
                : player;
            updatedPlayersMap[playerId] = updatedPlayer.toJson();
          }

          await roomRef.update({
            'hostId': newHostId,
            'players': updatedPlayersMap,
          });
        }
      }
    } catch (e) {
      throw Exception('방 나가기 실패: ${e.toString()}');
    }
  }

  // 방 실시간 스트림
  Stream<Room?> watchRoom(String roomId) {
    return FirebaseService.getRoomRef(roomId).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return Room.fromJson(data);
    });
  }

  // 방 목록 스트림 (개발/테스트용)
  Stream<List<Room>> watchRooms() {
    return FirebaseService.roomsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries
          .map((e) => Room.fromJson(Map<String, dynamic>.from(e.value)))
          .toList();
    });
  }

  // 유틸리티 메서드들
  String _generateRoomId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}