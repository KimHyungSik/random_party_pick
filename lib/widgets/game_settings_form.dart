import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import 'player_count_selector.dart';
import 'card_count_selector.dart';

class GameSettingsForm extends StatelessWidget {
  final int redCardCount;
  final bool isLoading;
  final Function(int) onRedCardCountChanged;
  final VoidCallback onCreateRoom;

  const GameSettingsForm({
    super.key,
    required this.redCardCount,
    required this.isLoading,
    required this.onRedCardCountChanged,
    required this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '게임 설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // 빨간 카드 개수 설정
            CardCountSelector(
              redCardCount: redCardCount,
              onChanged: onRedCardCountChanged,
            ),
            const Spacer(),

            // 방 만들기 버튼
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: isLoading ? null : onCreateRoom,
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
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
                  '방 만들기',
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
    );
  }
}