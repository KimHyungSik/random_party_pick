import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_party_pick/screens/waiting_room_screen.dart';
import '../providers/game_providers.dart';
import '../widgets/gradient_button.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int maxPlayers = 8;
  int redCardCount = 2;
  bool isLoading = false;

  Future<void> _createRoom() async {
    final userId = ref.read(currentUserIdProvider);
    final userName = ref.read(currentUserNameProvider);

    if (userId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final room = await repository.createRoom(
        hostId: userId,
        hostName: userName,
        maxPlayers: maxPlayers,
        redCardCount: redCardCount,
      );

      ref.read(currentRoomIdProvider.notifier).state = room.id;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WaitingRoomScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 만들기'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '게임 설정',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 최대 인원수 설정
                        const Text(
                          '최대 인원수',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: maxPlayers > 2
                                    ? () => setState(() => maxPlayers--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Expanded(
                                child: Text(
                                  '$maxPlayers명',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: maxPlayers < 20
                                    ? () => setState(() => maxPlayers++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 빨간 카드 개수 설정
                        const Text(
                          '빨간 카드 개수',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: redCardCount > 1
                                    ? () => setState(() => redCardCount--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Expanded(
                                child: Text(
                                  '$redCardCount개',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: redCardCount < maxPlayers - 1
                                    ? () => setState(() => redCardCount++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '녹색 카드: ${maxPlayers - redCardCount}개',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),

                        // 방 만들기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: isLoading ? null : _createRoom,
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : const Text(
                              '방 만들기',
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}