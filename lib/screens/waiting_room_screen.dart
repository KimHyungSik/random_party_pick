import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../widgets/room_info_card.dart';
import '../widgets/player_list_card.dart';
import '../widgets/start_game_button.dart';
import 'game_result_screen.dart';
import 'home_screen.dart';

class WaitingRoomScreen extends ConsumerStatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen> {
  bool _isLeaving = false; // 나가기 플래그 추가

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roomId = ref.watch(currentRoomIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    if ((roomId == null || currentUserId == null) && !_isLeaving) { // 플래그 체크 추가
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isLeaving) { // 추가 체크
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (roomId == null || currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.waiting),
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
              if (room == null && !_isLeaving) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_isLeaving) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                    );
                  }
                });
                return Center(child: Text(l10n.error));
              }

              if (room == null) {
                return Center(child: Text(l10n.error));
              }

              if (!room.players.containsKey(currentUserId) && !_isLeaving) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_isLeaving) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                    );
                  }
                });
                return Center(child: Text(l10n.error));
              }

              // Navigate to result screen if game has started
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
                    Text('${l10n.error}: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.backToHome),
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
          if (isHost) ...{
            _buildGameSettingsCard(context, ref, room, playerCount),
            const SizedBox(height: 16),
          },

          // 플레이어 목록
          Expanded(
            child: PlayerListCard(
              players: room.players,
              currentUserId: currentUserId,
              hostId: room.hostId,
              roomId: room.id,
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
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${l10n.numCards}: ',
                  style: const TextStyle(fontSize: 16),
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
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.error,
                  style: const TextStyle(
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kickPlayer),
        content: Text(l10n.kickPlayerConfirm.replaceFirst('{playerName}', playerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.kick),
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
            SnackBar(content: Text(l10n.playerKicked.replaceFirst('{playerName}', playerName))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')),
          );
        }
      }
    }
  }

  Future<void> _startGame(
      BuildContext context, String roomId) async {
    final l10n = AppLocalizations.of(context);
    // Show loading indicator
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(l10n.loading),
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  Future<void> _showLeaveDialog(BuildContext context, WidgetRef ref,
      String roomId, String playerId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveRoom),
        content: Text(l10n.leaveRoomConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isLeaving = true; // 플래그 설정
      });
      
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
        setState(() {
          _isLeaving = false; // 에러 시 플래그 리셋
        });
        
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')),
          );
        }
      }
    }
  }
}