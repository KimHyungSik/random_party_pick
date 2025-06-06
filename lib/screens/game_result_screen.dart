import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../models/room.dart';
import '../widgets/gradient_button.dart';
import 'home_screen.dart';
import 'waiting_room_screen.dart';

class GameResultScreen extends ConsumerWidget {
  const GameResultScreen({super.key});

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
      body: Container(
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
        child: SafeArea(
          child: roomAsync.when(
            data: (room) {
              print("LOGEE room $room");
              if (room == null) {
                return const Center(child: Text('방을 찾을 수 없습니다.'));
              }

              final currentPlayer = room.players[currentUserId];
              if (currentPlayer == null) {
                return const Center(child: Text('플레이어 정보를 찾을 수 없습니다.'));
              }

              final isRedCard = currentPlayer.cardColor?.toLowerCase() == 'red';
              return _buildResultScreen(
                  context, ref, room, currentPlayer, isRedCard);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류가 발생했습니다: $error'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, WidgetRef ref, Room room,
      Player currentPlayer, bool isRedCard) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),

          // 카드 결과 애니메이션
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Transform.rotate(
                  angle: (1 - value) * 4,
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.3,
                      constraints: BoxConstraints(
                        maxWidth: 200,
                        maxHeight: 280,
                      ),
                      decoration: BoxDecoration(
                        color: isRedCard ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isRedCard ? Colors.red : Colors.green)
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRedCard ? Icons.close : Icons.check,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRedCard ? '빨간 카드' : '녹색 카드',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // 결과 메시지
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    isRedCard ? '😭 아쉽네요!' : '🎉 축하합니다!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRedCard
                        ? '빨간 카드를 뽑으셨습니다.\n다음 기회에 도전해보세요!'
                        : '녹색 카드를 뽑으셨습니다.\n운이 좋으시네요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 전체 결과 보기
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '게임 결과',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 빨간 카드 받은 사람들
                  _buildResultSection(
                    '빨간 카드 (${room.redPlayers.length}명)',
                    room.redPlayers,
                    room.players,
                    Colors.red,
                    Icons.close,
                  ),
                  const SizedBox(height: 16),

                  // 녹색 카드 받은 사람들
                  _buildResultSection(
                    '녹색 카드 (${room.greenPlayers.length}명)',
                    room.greenPlayers,
                    room.players,
                    Colors.green,
                    Icons.check,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // 대기실로 돌아가기 버튼
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: () => _goWaitingRoom(context, ref, room.id),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              child: const Text(
                '대기실로 돌아가기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, List<String> playerIds,
      Map<String, Player> allPlayers, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: playerIds.map((playerId) {
            final player = allPlayers[playerId];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                player?.name ?? '알 수 없음',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _goWaitingRoom(BuildContext context, WidgetRef ref, roomId) async {
    final repository = ref.read(gameRepositoryProvider);
    await repository.prepareGame(roomId);

    // Navigate to waiting room instead of home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
      (route) => false,
    );
  }
}
