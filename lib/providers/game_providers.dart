import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/game_repository.dart';
import '../services/firebase_service.dart';
import '../models/room.dart';

// Repository Provider
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return GameRepository(firebaseService);
});

// 현재 사용자 ID Provider (실제로는 인증에서 가져와야 함)
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// 현재 사용자 이름 Provider
final currentUserNameProvider = StateProvider<String?>((ref) => null);

// 현재 참가한 방 ID Provider
final currentRoomIdProvider = StateProvider<String?>((ref) => null);

// 방 스트림 Provider
final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.watchRoom(roomId);
});

// 현재 방 Provider
final currentRoomProvider = Provider<AsyncValue<Room?>>((ref) {
  final roomId = ref.watch(currentRoomIdProvider);
  if (roomId == null) return const AsyncValue.data(null);
  return ref.watch(roomStreamProvider(roomId));
});

// 방 생성 Provider
final createRoomProvider = FutureProvider.family<Room, CreateRoomParams>((ref, params) async {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.createRoom(
    hostId: params.hostId,
    hostName: params.hostName,
    maxPlayers: params.maxPlayers,
    redCardCount: params.redCardCount,
  );
});

// ===== 5. Parameter Classes =====

class CreateRoomParams {
  final String hostId;
  final String hostName;
  final int maxPlayers;
  final int redCardCount;

  CreateRoomParams({
    required this.hostId,
    required this.hostName,
    this.maxPlayers = 8,
    this.redCardCount = 2,
  });
}

class JoinRoomParams {
  final String inviteCode;
  final String playerId;
  final String playerName;

  JoinRoomParams({
    required this.inviteCode,
    required this.playerId,
    required this.playerName,
  });
}