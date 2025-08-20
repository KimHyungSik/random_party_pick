// Enums for type safety
enum RoomStatus {
  waiting('waiting'),
  playing('playing'),
  finished('finished');

  final String value;
  const RoomStatus(this.value);

  static RoomStatus fromString(String value) {
    return RoomStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RoomStatus.waiting,
    );
  }
}

enum CardColor {
  red('red'),
  green('green');

  final String value;
  const CardColor(this.value);

  static CardColor? fromString(String? value) {
    if (value == null) return null;
    return CardColor.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CardColor.green,
    );
  }
}

// Constants
class GameConstants {
  static const int minPlayers = 2;
  static const int maxPlayers = 20;
  static const int inviteCodeLength = 6;
  static const int minRedCards = 1;
  static const Duration roomTimeout = Duration(hours: 2);
  static const Duration connectionTimeout = Duration(seconds: 30);
}