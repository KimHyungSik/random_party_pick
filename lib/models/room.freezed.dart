// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get hostId => throw _privateConstructorUsedError;
  String get inviteCode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get maxPlayers => throw _privateConstructorUsedError;
  int get redCardCount => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'waiting', 'playing', 'finished'
  Map<String, Player> get players => throw _privateConstructorUsedError;
  List<String> get redPlayers => throw _privateConstructorUsedError;
  List<String> get greenPlayers => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call(
      {String id,
      String hostId,
      String inviteCode,
      DateTime createdAt,
      int maxPlayers,
      int redCardCount,
      String status,
      Map<String, Player> players,
      List<String> redPlayers,
      List<String> greenPlayers});
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hostId = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? redCardCount = null,
    Object? status = null,
    Object? players = null,
    Object? redPlayers = null,
    Object? greenPlayers = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      redCardCount: null == redCardCount
          ? _value.redCardCount
          : redCardCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, Player>,
      redPlayers: null == redPlayers
          ? _value.redPlayers
          : redPlayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      greenPlayers: null == greenPlayers
          ? _value.greenPlayers
          : greenPlayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
          _$RoomImpl value, $Res Function(_$RoomImpl) then) =
      __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String hostId,
      String inviteCode,
      DateTime createdAt,
      int maxPlayers,
      int redCardCount,
      String status,
      Map<String, Player> players,
      List<String> redPlayers,
      List<String> greenPlayers});
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hostId = null,
    Object? inviteCode = null,
    Object? createdAt = null,
    Object? maxPlayers = null,
    Object? redCardCount = null,
    Object? status = null,
    Object? players = null,
    Object? redPlayers = null,
    Object? greenPlayers = null,
  }) {
    return _then(_$RoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxPlayers: null == maxPlayers
          ? _value.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      redCardCount: null == redCardCount
          ? _value.redCardCount
          : redCardCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as Map<String, Player>,
      redPlayers: null == redPlayers
          ? _value._redPlayers
          : redPlayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      greenPlayers: null == greenPlayers
          ? _value._greenPlayers
          : greenPlayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl(
      {required this.id,
      required this.hostId,
      required this.inviteCode,
      required this.createdAt,
      this.maxPlayers = 8,
      this.redCardCount = 2,
      this.status = 'waiting',
      final Map<String, Player> players = const {},
      final List<String> redPlayers = const [],
      final List<String> greenPlayers = const []})
      : _players = players,
        _redPlayers = redPlayers,
        _greenPlayers = greenPlayers;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String hostId;
  @override
  final String inviteCode;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int maxPlayers;
  @override
  @JsonKey()
  final int redCardCount;
  @override
  @JsonKey()
  final String status;
// 'waiting', 'playing', 'finished'
  final Map<String, Player> _players;
// 'waiting', 'playing', 'finished'
  @override
  @JsonKey()
  Map<String, Player> get players {
    if (_players is EqualUnmodifiableMapView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_players);
  }

  final List<String> _redPlayers;
  @override
  @JsonKey()
  List<String> get redPlayers {
    if (_redPlayers is EqualUnmodifiableListView) return _redPlayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_redPlayers);
  }

  final List<String> _greenPlayers;
  @override
  @JsonKey()
  List<String> get greenPlayers {
    if (_greenPlayers is EqualUnmodifiableListView) return _greenPlayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_greenPlayers);
  }

  @override
  String toString() {
    return 'Room(id: $id, hostId: $hostId, inviteCode: $inviteCode, createdAt: $createdAt, maxPlayers: $maxPlayers, redCardCount: $redCardCount, status: $status, players: $players, redPlayers: $redPlayers, greenPlayers: $greenPlayers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.redCardCount, redCardCount) ||
                other.redCardCount == redCardCount) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            const DeepCollectionEquality()
                .equals(other._redPlayers, _redPlayers) &&
            const DeepCollectionEquality()
                .equals(other._greenPlayers, _greenPlayers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      hostId,
      inviteCode,
      createdAt,
      maxPlayers,
      redCardCount,
      status,
      const DeepCollectionEquality().hash(_players),
      const DeepCollectionEquality().hash(_redPlayers),
      const DeepCollectionEquality().hash(_greenPlayers));

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(
      this,
    );
  }
}

abstract class _Room implements Room {
  const factory _Room(
      {required final String id,
      required final String hostId,
      required final String inviteCode,
      required final DateTime createdAt,
      final int maxPlayers,
      final int redCardCount,
      final String status,
      final Map<String, Player> players,
      final List<String> redPlayers,
      final List<String> greenPlayers}) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get hostId;
  @override
  String get inviteCode;
  @override
  DateTime get createdAt;
  @override
  int get maxPlayers;
  @override
  int get redCardCount;
  @override
  String get status; // 'waiting', 'playing', 'finished'
  @override
  Map<String, Player> get players;
  @override
  List<String> get redPlayers;
  @override
  List<String> get greenPlayers;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
