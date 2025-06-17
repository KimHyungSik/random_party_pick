import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

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
            playerCount >= 2 ? l10n.startGame : l10n.waitingForPlayers,
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
        child: Text(
          l10n.waiting,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
  }
}