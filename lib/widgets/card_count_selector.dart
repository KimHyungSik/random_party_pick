import 'package:flutter/material.dart';
import 'player_count_selector.dart';

class CardCountSelector extends StatelessWidget {
  final int redCardCount;
  final Function(int) onChanged;

  const CardCountSelector({
    super.key,
    required this.redCardCount,
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
          label: '빨간 카드 개수',
          unit: '개',
        ),
      ],
    );
  }
}