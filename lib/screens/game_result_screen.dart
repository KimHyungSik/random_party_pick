import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:random_party_pick/screens/waiting_room_screen.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../widgets/animated_game_button.dart';
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
              final l10n = AppLocalizations.of(context);

              if (room == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                });
                return Center(child: Text(l10n.error));
              }

              // Navigate to results screen if game has started
              if (room.status == 'waiting' && room.hostId != currentUserId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WaitingRoomScreen()),
                    (route) => false,
                  );
                });
                return Center(child: Text(l10n.waiting));
              }

              // Return to waiting room if the game hasn't started yet
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
            error: (error, stack) {
              final l10n = AppLocalizations.of(context);
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

  Widget _buildGameResult(BuildContext context, WidgetRef ref, Room room,
      String currentUserId, String roomId) {
    final l10n = AppLocalizations.of(context);
    final currentPlayer = room.players[currentUserId];
    if (currentPlayer == null) {
      return Center(child: Text(l10n.error));
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
                child: Stack(
                  children: [
                    // 카드 애니메이션 - 화면 중앙에 배치
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 400,
                        child: Center(
                          child: CardAnimation(
                            hasRedCard: hasRedCard,
                            playerName: playerName,
                            onFlipComplete: () {
                              setState(() {
                                _showOtherResults = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // 버튼 - 하단 중앙에 배치
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24, // 하단에서 24px 떨어진 위치
                      child: SizedBox(
                        width: double.infinity,
                        child: AnimatedGameButton(
                          show: _showOtherResults,
                          onPressed: () {
                            if (room.hostId == currentUserId) {
                              _goWaitingRoom(context, ref, roomId);
                            }
                          },
                          buttonText: room.hostId == currentUserId
                              ? l10n.backToHome
                              : l10n.waiting,
                        ),
                      ),
                    ),
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
    // 🔑 핵심: Provider 참조를 미리 저장
    final repository = ref.read(gameRepositoryProvider);

    try {
      // 1. 먼저 게임 준비 작업 완료
      await repository.prepareGame(roomId);

      // 2. 작업 완료 후 네비게이션 (mounted 체크 필수)
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 3. Handle errors
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }
}
