import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../widgets/gradient_button.dart';
import 'waiting_room_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;

  Future<void> _joinRoom(String inviteCode) async {
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
      await repository.joinRoom(
        inviteCode: inviteCode.toUpperCase(),
        playerId: userId,
        playerName: userName,
      );

      // 방 ID를 찾기 위해 임시로 저장 (실제로는 joinRoom이 roomId 반환하도록 수정 필요)
      ref.read(currentRoomIdProvider.notifier).state = 'temp_room_id';

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
          SnackBar(content: Text('방 참가 실패: $e')),
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
        title: const Text('방 참가하기'),
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
                          '초대코드 입력',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 초대코드 입력
                        TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: '초대코드',
                            hintText: 'ABC123',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _joinRoom(value.trim());
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        const Spacer(),

                        // 참가하기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: isLoading || _codeController.text.isEmpty
                                ? null
                                : () => _joinRoom(_codeController.text),
                            gradient: const LinearGradient(
                              colors: [Colors.green, Colors.teal],
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
                              '방 참가하기',
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
