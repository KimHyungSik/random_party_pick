import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../widgets/room_info_card.dart';
import '../widgets/player_list_card.dart';
import '../widgets/start_game_button.dart';
import 'game_result_screen.dart';
import 'home_screen.dart';

class WaitingRoomScreen extends ConsumerWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(currentRoomIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    if (roomId == null || currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('대기실'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              _showLeaveDialog(context, ref, roomId, currentUserId),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: roomAsync.when(
            data: (room) {
              if (room == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                  );
                });
                return const Center(child: Text('방을 찾을 수 없습니다.'));
              }

              // 게임이 시작되면 결과 화면으로 이동
              if (room.status == 'playing') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameResultScreen(),
                    ),
                  );
                });
              }

              return _buildWaitingRoom(context, ref, room, currentUserId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('오류가 발생했습니다: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('돌아가기'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingRoom(
      BuildContext context, WidgetRef ref, Room room, String currentUserId) {
    final isHost = room.hostId == currentUserId;
    final playerCount = room.players.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 방 정보 카드
          RoomInfoCard(inviteCode: room.inviteCode),
          const SizedBox(height: 16),

          // 게임 설정 (방장만)
          if (isHost) ...[
            _buildGameSettingsCard(context, ref, room, playerCount),
            const SizedBox(height: 16),
          ],

          // 플레이어 목록
          Expanded(
            child: PlayerListCard(
              players: room.players,
              currentUserId: currentUserId,
              isHost: isHost,
              onKickPlayer: _showKickDialog,
            ),
          ),
          const SizedBox(height: 16),

          // 게임 시작 버튼
          StartGameButton(
            isHost: isHost,
            playerCount: playerCount,
            onStartGame: _startGame,
            roomId: room.id,
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsCard(
      BuildContext context, WidgetRef ref, Room room, int playerCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '게임 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  '빨간 카드 개수: ',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: room.redCardCount > 1
                      ? () => _updateRedCardCount(context, ref, room.id, room.redCardCount - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${room.redCardCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: room.redCardCount < playerCount - 1
                      ? () => _updateRedCardCount(context, ref, room.id, room.redCardCount + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (room.redCardCount >= playerCount)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '빨간 카드는 현재 인원보다 적어야 합니다.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRedCardCount(
      BuildContext context, WidgetRef ref, String roomId, int newCount) async {
    try {
      final repository = ref.read(gameRepositoryProvider);
      await repository.updateRedCardCount(roomId, newCount);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 변경 실패: $e')),
        );
      }
    }
  }

  Future<void> _showKickDialog(
      BuildContext context,
      String roomId,
      String playerId,
      String playerName,
      String hostId,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('플레이어 추방'),
        content: Text('$playerName님을 방에서 추방하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('추방'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ProviderScope.containerOf(context).read(gameRepositoryProvider);
        await repository.kickPlayer(roomId, playerId, hostId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$playerName님을 추방했습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('추방 실패: $e')),
          );
        }
      }
    }
  }

  Future<void> _startGame(
      BuildContext context, String roomId) async {
    // Show loading indicator
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('게임을 시작하는 중...'),
          ],
        ),
      ),
    );

    try {
      final repository = ProviderScope.containerOf(context).read(gameRepositoryProvider);
      await repository.startGame(roomId);
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게임 시작 실패: $e')),
        );
      }
    }
  }

  Future<void> _showLeaveDialog(BuildContext context, WidgetRef ref,
      String roomId, String playerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방 나가기'),
        content: const Text('정말로 방을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(gameRepositoryProvider);
        await repository.leaveRoom(roomId, playerId);
        ref.read(currentRoomIdProvider.notifier).state = null;

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('방 나가기 실패: $e')),
          );
        }
      }
    }
  }
}