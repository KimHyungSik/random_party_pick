import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class StartGameButton extends StatelessWidget {
  final bool isHost;
  final int playerCount;
  final Function(BuildContext, String) onStartGame;
  final String roomId;

  const StartGameButton({
    super.key,
    required this.isHost,
    required this.playerCount,
    required this.onStartGame,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return SizedBox(
        width: double.infinity,
        child: GradientButton(
          onPressed: playerCount >= 2 
              ? () => onStartGame(context, roomId)
              : null,
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.pink],
          ),
          child: Text(
            playerCount >= 2 ? '게임 시작' : '최소 2명 이상 필요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          '방장이 게임을 시작하길 기다리는 중...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
  }
}