import 'package:flutter/material.dart';
import '../models/player.dart';

class ResultSection extends StatelessWidget {
  final String title;
  final List<String> playerIds;
  final Map<String, Player> allPlayers;
  final Color color;
  final IconData icon;

  const ResultSection({
    super.key,
    required this.title,
    required this.playerIds,
    required this.allPlayers,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
}