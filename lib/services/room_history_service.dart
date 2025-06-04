// lib/services/room_history_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RoomHistoryService {
  static const String _historyKey = 'room_history';

  // 방 참여 이력 저장
  static Future<void> addRoomToHistory(String inviteCode, String roomName) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> history = json.decode(historyJson);

    // 중복 제거
    history.removeWhere((item) => item['inviteCode'] == inviteCode);

    // 새 항목 추가 (맨 앞에)
    history.insert(0, {
      'inviteCode': inviteCode,
      'roomName': roomName,
      'joinedAt': DateTime.now().toIso8601String(),
    });

    // 최대 10개까지만 저장
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setString(_historyKey, json.encode(history));
  }

  // 방 참여 이력 조회
  static Future<List<Map<String, dynamic>>> getRoomHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> history = json.decode(historyJson);
    return history.cast<Map<String, dynamic>>();
  }

  // 특정 방 이력 제거
  static Future<void> removeRoomFromHistory(String inviteCode) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey) ?? '[]';
    final List<dynamic> history = json.decode(historyJson);

    history.removeWhere((item) => item['inviteCode'] == inviteCode);

    await prefs.setString(_historyKey, json.encode(history));
  }

  // 이력 전체 삭제
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}