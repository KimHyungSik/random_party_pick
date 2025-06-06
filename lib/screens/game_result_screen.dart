import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_party_pick/screens/waiting_room_screen.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../widgets/gradient_button.dart';
import '../widgets/card_animation.dart';
import 'home_screen.dart';

class GameResultScreen extends ConsumerStatefulWidget {
  const GameResultScreen({super.key});

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen> {
  bool _showOtherResults = false;

  @override
  Widget build(BuildContext context) {
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
        width: double.infinity,
        height: double.infinity,
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

              // 게임이 아직 시작되지 않았으면 대기실로 돌아가기
              if (room.status != 'playing') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return _buildGameResult(
                  context, ref, room, currentUserId, roomId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameResult(BuildContext context, WidgetRef ref, Room room,
      String currentUserId, String roomId) {
    final currentPlayer = room.players[currentUserId];
    if (currentPlayer == null) {
      return const Center(child: Text('플레이어 정보를 찾을 수 없습니다.'));
    }

    final hasRedCard = currentPlayer.cardColor == "red";
    final playerName = currentPlayer.name;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // 카드 애니메이션
                    CardAnimation(
                      hasRedCard: hasRedCard,
                      playerName: playerName,
                      onFlipComplete: () {
                        setState(() {
                          _showOtherResults = true;
                        });
                      },
                    ),

                    const Spacer(),

                    // 다른 플레이어 결과 (카드 뒤집기 완료 후)
                    if (_showOtherResults) ...[
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          onPressed: () => _goWaitingRoom(context, ref, roomId),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _goWaitingRoom(
      BuildContext context, WidgetRef ref, String roomId) async {
    final repository = ref.read(gameRepositoryProvider);
    await repository.prepareGame(roomId);

    // Navigate to waiting room instead of home
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
        (route) => false,
      );
    }
  }
}
