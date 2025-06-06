import 'package:flutter/material.dart';
import 'player_count_selector.dart';

class CardCountSelector extends StatelessWidget {
  final int redCardCount;
  final int maxPlayers;
  final Function(int) onChanged;

  const CardCountSelector({
    super.key,
    required this.redCardCount,
    required this.maxPlayers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerCountSelector(
          value: redCardCount,
          onChanged: onChanged,
          minValue: 1,
          maxValue: maxPlayers - 1,
          label: '빨간 카드 개수',
          unit: '개',
        ),
        const SizedBox(height: 16),
        Text(
          '녹색 카드: ${maxPlayers - redCardCount}개',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}