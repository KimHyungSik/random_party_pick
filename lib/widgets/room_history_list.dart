import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomHistoryList extends StatelessWidget {
  final List<Room> validHistoryRooms;
  final bool isLoading;
  final Function(String) onJoinRoom;
  final bool isJoining;

  const RoomHistoryList({
    super.key,
    required this.validHistoryRooms,
    required this.isLoading,
    required this.onJoinRoom,
    required this.isJoining,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            '최근 참가한 방',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (validHistoryRooms.isEmpty && !isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          '참가 가능한 방이 없습니다',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: validHistoryRooms.length,
          itemBuilder: (context, index) {
            return _buildRoomListItem(validHistoryRooms[index]);
          },
        ),
      );
    }
  }

  Widget _buildRoomListItem(Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            room.inviteCode[0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          room.inviteCode,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          '${room.players.length}/${room.maxPlayers}명 참가 중',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: isJoining ? null : () => onJoinRoom(room.inviteCode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
  }
}