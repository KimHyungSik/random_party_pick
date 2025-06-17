import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/game_providers.dart';
import '../widgets/gradient_button.dart';
import 'join_room_screen.dart';
import 'waiting_room_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? userName;
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final userId = prefs.getString('user_id') ?? const Uuid().v4();

    await prefs.setString('user_id', userId);
    ref.read(currentUserIdProvider.notifier).state = userId;

    if (savedName != null) {
      setState(() {
        userName = savedName;
        _nameController.text = savedName;
      });
      ref.read(currentUserNameProvider.notifier).state = savedName;
    }
  }

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    ref.read(currentUserNameProvider.notifier).state = name;
    setState(() {
      userName = name;
    });
  }

  Future<void> _createRoom() async {
    setState(() => _isCreatingRoom = true);

    try {
      final repository = ref.read(gameRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);
      final userName = ref.read(currentUserNameProvider);

      if (userId == null || userName == null) {
        throw Exception('User information is missing');
      }

      final room = await repository.createRoom(
        hostId: userId,
        hostName: userName,
        redCardCount: 1, // 기본값
      );

      ref.read(currentRoomIdProvider.notifier).state = room.id;

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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      setState(() => _isCreatingRoom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // App logo/title
                const Icon(
                  Icons.casino,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.homeScreenTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                // Name input
                if (userName == null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            l10n.enterPlayerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l10n.playerName,
                              border: const OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _saveUserName(value.trim());
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_nameController.text.trim().isNotEmpty) {
                                  _saveUserName(_nameController.text.trim());
                                }
                              },
                              child: Text(l10n.join),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Welcome message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Hello, $userName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                userName = null;
                                _nameController.clear();
                              });
                            },
                            child: Text(l10n.playerName),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Game buttons
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      onPressed: _isCreatingRoom ? null : _createRoom,
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      child: _isCreatingRoom
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.loading,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.createRoom,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinRoomScreen(),
                          ),
                        );
                      },
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.teal],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.joinRoom,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}