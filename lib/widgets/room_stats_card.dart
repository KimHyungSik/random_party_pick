import 'package:flutter/material.dart';

class RoomStatsCard extends StatelessWidget {
  final int maxPlayers;
  final int redCardCount;
  final int playerCount;

  const RoomStatsCard({
    super.key,
    required this.maxPlayers,
    required this.redCardCount,
    required this.playerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('최대 인원', '$maxPlayers명'),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildInfoItem('빨간 카드', '$redCardCount개'),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _buildInfoItem('현재 인원', '$playerCount명'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}