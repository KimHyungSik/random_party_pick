import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/player.dart';
import 'result_section.dart';

class PlayerResultList extends StatelessWidget {
  final Room room;

  const PlayerResultList({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            ResultSection(
              title: '빨간 카드 (${room.redPlayers.length}명)',
              playerIds: room.redPlayers,
              allPlayers: room.players,
              color: Colors.red,
              icon: Icons.close,
            ),
            const SizedBox(height: 16),

            // 녹색 카드 받은 사람들
            ResultSection(
              title: '녹색 카드 (${room.greenPlayers.length}명)',
              playerIds: room.greenPlayers,
              allPlayers: room.players,
              color: Colors.green,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }
}