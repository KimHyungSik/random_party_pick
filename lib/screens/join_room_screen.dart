// lib/screens/join_room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../providers/game_providers.dart';
import '../services/room_history_service.dart';
import '../widgets/gradient_button.dart';
import 'waiting_room_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _nameController = TextEditingController();
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
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await RoomHistoryService.getRoomHistory();
      final inviteCodes = history.map((item) => item['inviteCode'] as String).toList();

      if (inviteCodes.isNotEmpty) {
        final repository = ref.read(gameRepositoryProvider);
        final validRooms = await repository.getValidRoomsByInviteCodes(inviteCodes);

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

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final roomId = await repository.joinRoom(
        inviteCode: _inviteCodeController.text.trim().toUpperCase(),
        playerId: DateTime.now().millisecondsSinceEpoch.toString(),
        playerName: _nameController.text.trim(),
      );

      // 성공시 방 이력에 추가
      await RoomHistoryService.addRoomToHistory(
        _inviteCodeController.text.trim().toUpperCase(),
        '방 ${_inviteCodeController.text.trim().toUpperCase()}',
      );

      ref.read(currentRoomIdProvider.notifier).state = roomId;
      ref.read(currentUserIdProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch.toString();

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

  Future<void> _joinHistoryRoom(Room room) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final roomId = await repository.joinRoom(
        inviteCode: room.inviteCode,
        playerId: DateTime.now().millisecondsSinceEpoch.toString(),
        playerName: _nameController.text.trim(),
      );

      // 방 이력 업데이트
      await RoomHistoryService.addRoomToHistory(
        room.inviteCode,
        '방 ${room.inviteCode}',
      );

      ref.read(currentRoomIdProvider.notifier).state = roomId;
      ref.read(currentUserIdProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch.toString();

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
            child: Form(
              key: _formKey,
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
                  const SizedBox(height: 40),

                  // 입력 폼
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _inviteCodeController,
                            decoration: const InputDecoration(
                              labelText: '초대코드',
                              hintText: '6자리 초대코드를 입력하세요',
                              prefixIcon: Icon(Icons.vpn_key),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9]'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '초대코드를 입력해주세요';
                              }
                              if (value.trim().length != 6) {
                                return '초대코드는 6자리입니다';
                              }
                              return null;
                            },
                            onChanged: (value){
                              setState(() {
                                _inviteCodeController.text = value.toUpperCase();
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              onPressed: _isLoading ? null : _joinRoom,
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                '방 참가',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 최근 참가한 방 목록
                  if (_validHistoryRooms.isNotEmpty || _isLoadingHistory)
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
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
                                  if (_isLoadingHistory)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                ],
                              ),
                            ),
                            if (_validHistoryRooms.isEmpty && !_isLoadingHistory)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  '참가 가능한 방이 없습니다',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _validHistoryRooms.length,
                                  itemBuilder: (context, index) {
                                    final room = _validHistoryRooms[index];
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
                                        onTap: _isLoading
                                            ? null
                                            : () => _joinHistoryRoom(room),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        tileColor: Colors.grey.shade50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}