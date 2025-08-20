import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/room.dart';
import '../models/enums.dart';
import '../providers/game_providers.dart';
import '../repositories/game_repository.dart';
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
  bool _isNavigating = false;
  bool _isLeaving = false;
  bool _hasNavigatedToResult = false;
  bool _hasNavigatedToHome = false;

  @override
  void dispose() {
    _isNavigating = false;
    _isLeaving = false;
    _hasNavigatedToResult = false;
    _hasNavigatedToHome = false;
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigatedToHome || _isNavigating) return;
    _hasNavigatedToHome = true;
    _isNavigating = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        ).then((_) {
          if (mounted) {
            _isNavigating = false;
          }
        });
      }
    });
  }

  void _navigateToResult() {
    if (_hasNavigatedToResult || _isNavigating) return;
    _hasNavigatedToResult = true;
    _isNavigating = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GameResultScreen(),
          ),
        ).then((_) {
          if (mounted) {
            _isNavigating = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roomId = ref.watch(currentRoomIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    
    // Check connection status
    final connectionAsync = ref.watch(connectionStateProvider);
    
    if ((roomId == null || currentUserId == null) && !_isLeaving) {
      _navigateToHome();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (roomId == null || currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return WillPopScope(
      onWillPop: () async {
        await _showLeaveDialog(context, ref, roomId, currentUserId);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.waiting),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showLeaveDialog(context, ref, roomId, currentUserId),
          ),
          actions: [
            // Connection status indicator
            connectionAsync.when(
              data: (isConnected) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
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
                  _navigateToHome();
                  return Center(child: Text(l10n.roomClosed));
                }

                if (room == null) {
                  return Center(child: Text(l10n.error));
                }

                // Check if player was kicked
                if (!room.players.containsKey(currentUserId) && !_isLeaving) {
                  _navigateToHome();
                  return Center(child: Text(l10n.error));
                }

                // Navigate to result screen if game has started
                if (room.status == RoomStatus.playing && !_hasNavigatedToResult) {
                  _navigateToResult();
                  return const Center(child: CircularProgressIndicator());
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
                      Text('${l10n.error}: ${_getErrorMessage(error, l10n)}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(roomStreamProvider(roomId)),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.tryAgain),
                      ),
                      const SizedBox(height: 8),
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
      ),
    );
  }

  String _getErrorMessage(Object error, AppLocalizations l10n) {
    if (error is GameRepositoryException) {
      switch (error.code) {
        case 'ROOM_NOT_FOUND':
          return l10n.roomNotFound;
        case 'GAME_NOT_WAITING':
          return l10n.gameAlreadyStarted;
        case 'NAME_TAKEN':
          return l10n.nameAlreadyTaken;
        case 'ROOM_FULL':
          return l10n.roomIsFull;
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  Widget _buildWaitingRoom(
      BuildContext context, WidgetRef ref, Room room, String currentUserId) {
    final isHost = room.hostId == currentUserId;
    final playerCount = room.players.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Room info card
          RoomInfoCard(inviteCode: room.inviteCode),
          const SizedBox(height: 16),

          // Game settings (host only)
          if (isHost) ...{
            _buildGameSettingsCard(context, ref, room, playerCount),
            const SizedBox(height: 16),
          },

          // Player list
          Expanded(
            child: PlayerListCard(
              players: room.players,
              currentUserId: currentUserId,
              hostId: room.hostId,
              room: room,
              onKickPlayer: _showKickDialog,
            ),
          ),
          const SizedBox(height: 16),

          // Start game button
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  onPressed: room.redCardCount > GameConstants.minRedCards
                      ? () => _updateRedCardCount(context, ref, room.id, room.redCardCount - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: room.redCardCount > GameConstants.minRedCards 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
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
                  color: room.redCardCount < playerCount - 1 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey,
                ),
              ],
            ),
            if (room.redCardCount >= playerCount && playerCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.redCardCountError,
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
          SnackBar(
            content: Text(_getErrorMessage(e, l10n)),
            backgroundColor: Colors.red,
          ),
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
        content: Text(l10n.kickPlayerConfirm(playerName)),
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
            SnackBar(
              content: Text(l10n.playerKicked(playerName)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e, AppLocalizations.of(context))),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _startGame(BuildContext context, String roomId) async {
    final l10n = AppLocalizations.of(context);
    
    // Show loading indicator
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
      final repository = ProviderScope.containerOf(context).read(gameRepositoryProvider);
      await repository.startGame(roomId);
      
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e, l10n)),
            backgroundColor: Colors.red,
          ),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() {
        _isLeaving = true;
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
          _isLeaving = false;
        });
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(e, l10n)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}