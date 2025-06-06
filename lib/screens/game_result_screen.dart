import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';
import '../models/room.dart';
import '../widgets/gradient_button.dart';
import '../widgets/game_result_card.dart';
import '../widgets/card_animation.dart';
import '../widgets/player_result_list.dart';
import 'home_screen.dart';
import 'waiting_room_screen.dart';

class GameResultScreen extends ConsumerWidget {
  const GameResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(currentRoomIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    print("LOGEE $roomId, $currentUserId");

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

              if (room == null) {
                return const Center(child: Text('방을 찾을 수 없습니다.'));
              }

              final currentPlayer = room.players[currentUserId];
              if (currentPlayer == null) {
                return const Center(child: Text('플레이어 정보를 찾을 수 없습니다.'));
              }

              final isRedCard = currentPlayer.cardColor?.toLowerCase() == 'red';
              return _buildResultScreen(context, ref, room, isRedCard, roomId);
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
      bool isRedCard, String roomId) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),

          // 카드 결과 애니메이션
          CardAnimation(isRedCard: isRedCard),
          const SizedBox(height: 40),

          // 전체 결과 보기
          PlayerResultList(room: room),
          const Spacer(),

          // 대기실로 돌아가기 버튼
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
      ),
    );
  }

  void _goWaitingRoom(BuildContext context, WidgetRef ref, String roomId) async {
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