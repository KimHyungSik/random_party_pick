class Player {
  final String id;
  final String name;
  final DateTime joinedAt;
  final bool isHost;
  final String? cardColor; // 'red' or 'green'

  const Player({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.isHost = false,
    this.cardColor,
  });

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joinedAt': joinedAt.toIso8601String(),
      'isHost': isHost,
      'cardColor': cardColor,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    // Safe parsing with fallbacks
    String id = '';
    String name = 'Unknown';
    DateTime joinedAt = DateTime.now();
    bool isHost = false;
    String? cardColor;

    try {
      id = json['id']?.toString() ?? '';
      name = json['name']?.toString() ?? 'Unknown';

      if (json['joinedAt'] != null) {
        if (json['joinedAt'] is String) {
          try {
            joinedAt = DateTime.parse(json['joinedAt'] as String);
          } catch (_) {
            joinedAt = DateTime.now();
          }
        } else if (json['joinedAt'] is DateTime) {
          joinedAt = json['joinedAt'] as DateTime;
        }
      }

      isHost = json['isHost'] == true;

      if (json['cardColor'] != null) {
        cardColor = json['cardColor'].toString();
      }
    } catch (e) {
      print('Error parsing player data: $e');
    }

    return Player(
      id: id,
      name: name,
      joinedAt: joinedAt,
      isHost: isHost,
      cardColor: cardColor,
    );
  }

  // copyWith 메서드
  Player copyWith({
    String? id,
    String? name,
    DateTime? joinedAt,
    bool? isHost,
    String? cardColor,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      isHost: isHost ?? this.isHost,
      cardColor: cardColor ?? this.cardColor,
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
    return 'Player(id: $id, name: $name, joinedAt: $joinedAt, isHost: $isHost, cardColor: $cardColor)';
  }
}