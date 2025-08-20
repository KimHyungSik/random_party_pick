import 'enums.dart';

class Player {
  final String id;
  final String name;
  final DateTime joinedAt;
  final bool isHost;
  final CardColor? cardColor;

  const Player({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.isHost = false,
    this.cardColor,
  });

  // JSON conversion with better type safety
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'isHost': isHost,
      'cardColor': cardColor?.value,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    // Safe parsing with better error handling
    return Player(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      joinedAt: _parseDateTime(json['joinedAt']),
      isHost: json['isHost'] == true,
      cardColor: CardColor.fromString(json['cardColor']?.toString()),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  // copyWith method
  Player copyWith({
    String? id,
    String? name,
    DateTime? joinedAt,
    bool? isHost,
    CardColor? cardColor,
    bool clearCardColor = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      isHost: isHost ?? this.isHost,
      cardColor: clearCardColor ? null : (cardColor ?? this.cardColor),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player &&
        other.id == id &&
        other.name == name &&
        other.joinedAt == joinedAt &&
        other.isHost == isHost &&
        other.cardColor == cardColor;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, joinedAt, isHost, cardColor);
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, isHost: $isHost, cardColor: ${cardColor?.value})';
  }
}