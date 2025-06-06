import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/game_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 백그라운드로 가거나 종료될 때
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _handleAppExit();
    }
  }

  Future<void> _handleAppExit() async {
    try {
      final roomId = ref.read(currentRoomIdProvider);
      final userId = ref.read(currentUserIdProvider);

      if (roomId != null && userId != null) {
        final repository = ref.read(gameRepositoryProvider);
        await repository.leaveRoom(roomId, userId);
        ref.read(currentRoomIdProvider.notifier).state = null;
      }
    } catch (e) {
      // 로그 출력 또는 에러 처리
      debugPrint('앱 종료 시 방 나가기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}