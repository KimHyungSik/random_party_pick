// lib/screens/join_room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../services/room_history_service.dart';
import '../widgets/join_room_form.dart';
import '../widgets/room_history_list.dart';
import 'waiting_room_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  List<Room> _validHistoryRooms = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadRoomHistory();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await RoomHistoryService.getRoomHistory();
      final inviteCodes =
          history.map((item) => item['inviteCode'] as String).toList();

      if (inviteCodes.isNotEmpty) {
        final repository = ref.read(gameRepositoryProvider);
        final validRooms =
            await repository.getValidRoomsByInviteCodes(inviteCodes);

        setState(() {
          _validHistoryRooms = validRooms;
        });
      }
    } catch (e) {
      // 에러 무시 (히스토리 로딩 실패는 치명적이지 않음)
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _joinRoom(String inviteCode) async {
    final currentUserId = ref.watch(currentUserIdProvider);
    final userName = ref.read(currentUserNameProvider);

    print("LOGEE joinRoom :userId $currentUserId");

    if (currentUserId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final roomId = await repository.joinRoom(
        inviteCode: inviteCode,
        playerId: currentUserId,
        playerName: userName,
      );

      // 성공시 방 이력에 추가
      await RoomHistoryService.addRoomToHistory(
        inviteCode,
        '방 $inviteCode',
      );

      ref.read(currentRoomIdProvider.notifier).state = roomId;

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
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('방 참가'),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 제목
                const Text(
                  '방에 참가하기',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '초대코드와 닉네임을 입력해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 입력 폼
                JoinRoomForm(
                  inviteCodeController: _inviteCodeController,
                  onJoinRoom: _joinRoom,
                  isLoading: _isLoading,
                  formKey: _formKey,
                ),

                const SizedBox(height: 24),

                // 최근 참가한 방 목록
                Expanded(
                  child: RoomHistoryList(
                    validHistoryRooms: _validHistoryRooms,
                    isLoading: _isLoadingHistory,
                    onJoinRoom: _joinRoom,
                    isJoining: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
