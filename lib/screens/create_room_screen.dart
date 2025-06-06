import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_party_pick/screens/waiting_room_screen.dart';
import '../providers/game_providers.dart';
import '../services/room_history_service.dart';
import '../widgets/game_settings_form.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  int maxPlayers = 8;
  int redCardCount = 2;
  bool isLoading = false;

  void _updateMaxPlayers(int value) {
    setState(() {
      maxPlayers = value;
      // Ensure redCardCount is valid when maxPlayers changes
      if (redCardCount >= maxPlayers) {
        redCardCount = maxPlayers - 1;
      }
    });
  }

  void _updateRedCardCount(int value) {
    setState(() {
      redCardCount = value;
    });
  }

  Future<void> _createRoom() async {
    final userId = ref.read(currentUserIdProvider);
    final userName = ref.read(currentUserNameProvider);

    if (userId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final room = await repository.createRoom(
        hostId: userId,
        hostName: userName,
        maxPlayers: maxPlayers,
        redCardCount: redCardCount,
      );

      ref.read(currentRoomIdProvider.notifier).state = room.id;

      await RoomHistoryService.addRoomToHistory(
        room.inviteCode,
        '방 ${room.inviteCode}',
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WaitingRoomScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방 생성 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 만들기'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: GameSettingsForm(
                  maxPlayers: maxPlayers,
                  redCardCount: redCardCount,
                  isLoading: isLoading,
                  onMaxPlayersChanged: _updateMaxPlayers,
                  onRedCardCountChanged: _updateRedCardCount,
                  onCreateRoom: _createRoom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}