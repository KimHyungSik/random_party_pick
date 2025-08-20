import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:random_party_pick/screens/waiting_room_screen.dart';
import '../models/room.dart';
import '../models/enums.dart';
import '../providers/game_providers.dart';
import '../repositories/game_repository.dart';
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
  bool _isNavigating = false;
  bool _hasNavigatedHome = false;

  @override
  void dispose() {
    _isNavigating = false;
    _hasNavigatedHome = false;
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigatedHome || _isNavigating) return;
    _hasNavigatedHome = true;
    _isNavigating = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomId = ref.watch(currentRoomIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final l10n = AppLocalizations.of(context);

    if (roomId == null || currentUserId == null) {
      _navigateToHome();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during game
        return false;
      },
      child: Scaffold(
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
                  _navigateToHome();
                  return Center(child: Text(l10n.roomClosed));
                }

                // Check if player is in the room
                if (!room.players.containsKey(currentUserId)) {
                  _navigateToHome();
                  return Center(child: Text(l10n.error));
                }

                // Handle different room states
                if (room.status == RoomStatus.waiting) {
                  if (!_isNavigating) {
                    _isNavigating = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WaitingRoomScreen(),
                          ),
                        );
                      }
                    });
                  }
                  return Center(child: Text(l10n.waiting));
                }

                if (room.status != RoomStatus.playing) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildGameResult(context, ref, room, currentUserId, roomId);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('${l10n.error}: ${_getErrorMessage(error, l10n)}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(roomStreamProvider(roomId)),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.tryAgain),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        ),
                        child: Text(l10n.backToHome),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error, AppLocalizations l10n) {
    if (error is GameRepositoryException) {
      return error.message;
    }
    return error.toString();
  }

  Widget _buildGameResult(BuildContext context, WidgetRef ref, Room room,
      String currentUserId, String roomId) {
    final l10n = AppLocalizations.of(context);
    final currentPlayer = room.players[currentUserId];
    
    if (currentPlayer == null) {
      return Center(child: Text(l10n.error));
    }

    final hasRedCard = currentPlayer.cardColor == CardColor.red;
    final playerName = currentPlayer.name;
    final isHost = room.hostId == currentUserId;

    // Build results summary
    final redCardPlayers = room.players.values
        .where((p) => p.cardColor == CardColor.red)
        .toList();
    final greenCardPlayers = room.players.values
        .where((p) => p.cardColor == CardColor.green)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Title
                Text(
                  l10n.gameResults,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Card Animation
                SizedBox(
                  height: 300,
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
                
                // Your result
                AnimatedOpacity(
                  opacity: _showOtherResults ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Card(
                        color: hasRedCard ? Colors.red.shade50 : Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            hasRedCard ? l10n.youGotRedCard : l10n.youGotGreenCard,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: hasRedCard ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Results summary
                      if (_showOtherResults) ...[
                        _buildResultsSection(
                          title: l10n.redCardHolder,
                          players: redCardPlayers,
                          color: Colors.red,
                          currentUserId: currentUserId,
                        ),
                        const SizedBox(height: 16),
                        _buildResultsSection(
                          title: l10n.greenCardHolder,
                          players: greenCardPlayers,
                          color: Colors.green,
                          currentUserId: currentUserId,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action buttons
                AnimatedOpacity(
                  opacity: _showOtherResults ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      if (isHost) ...[
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: () => _resetGame(context, ref, roomId),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.playAgain),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: () => _leaveGame(context, ref, roomId, currentUserId),
                          icon: const Icon(Icons.home),
                          label: Text(l10n.backToHome),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsSection({
    required String title,
    required List<Player> players,
    required Color color,
    required String currentUserId,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: players.map((player) {
                final isMe = player.id == currentUserId;
                return Chip(
                  label: Text(
                    player.name + (isMe ? ' (You)' : ''),
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: color.withOpacity(0.2),
                  avatar: Icon(
                    Icons.person,
                    size: 18,
                    color: color,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetGame(BuildContext context, WidgetRef ref, String roomId) async {
    final l10n = AppLocalizations.of(context);
    
    // Show loading
    showDialog(
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
      final repository = ref.read(gameRepositoryProvider);
      await repository.resetGame(roomId);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: ${_getErrorMessage(e, l10n)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGame(BuildContext context, WidgetRef ref, 
      String roomId, String playerId) async {
    final l10n = AppLocalizations.of(context);
    
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
          SnackBar(
            content: Text('${l10n.error}: ${_getErrorMessage(e, l10n)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}