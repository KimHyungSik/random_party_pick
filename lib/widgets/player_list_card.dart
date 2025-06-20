import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/player.dart';
import '../providers/game_providers.dart';

class PlayerListCard extends StatelessWidget {
  final Map<String, Player> players;
  final String currentUserId;
  final String hostId;
  final String roomId;
  final Function(BuildContext, String, String, String, String) onKickPlayer;

  const PlayerListCard({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.hostId,
    required this.onKickPlayer,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playerCount = players.length;

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${l10n.numPlayers}: $playerCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players.values.toList()[index];
                return PlayerListItem(
                  player: player,
                  isCurrentUser: player.id == currentUserId,
                  isHost: hostId == player.id,
                  currentUserId: currentUserId,
                  onKickPlayer: onKickPlayer,
                  roomId: roomId,  // This will be passed from the parent
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final Player player;
  final bool isCurrentUser;
  final bool isHost;
  final String currentUserId;
  final String roomId;
  final Function(BuildContext, String, String, String, String) onKickPlayer;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.isCurrentUser,
    required this.isHost,
    required this.currentUserId,
    required this.roomId,
    required this.onKickPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHost ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHost ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isHost ? Colors.orange : Colors.blue,
            child: Text(
              player.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (isHost)
                  Text(
                    'Host',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Me',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Only the host can kick other players
          if (isHost && player.id != currentUserId)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: () => onKickPlayer(
                  context,
                  roomId,
                  player.id,
                  player.name,
                  currentUserId,
                ),
                icon: const Icon(
                  Icons.person_remove,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: player.name,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  minimumSize: const Size(32, 32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}