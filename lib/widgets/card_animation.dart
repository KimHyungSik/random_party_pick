import 'package:flutter/material.dart';

class CardAnimation extends StatefulWidget {
  final bool hasRedCard;
  final VoidCallback? onFlipComplete;
  final String playerName;

  const CardAnimation({
    super.key,
    required this.hasRedCard,
    this.onFlipComplete,
    required this.playerName,
  });

  @override
  State<CardAnimation> createState() => _CardAnimationState();
}

class _CardAnimationState extends State<CardAnimation>
    with TickerProviderStateMixin {
  // 기존 플립 애니메이션
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // 새로 추가된 진입 애니메이션
  late AnimationController _entryController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isFlipped = false;
  bool _canFlip = false; // 진입 애니메이션 완료 후에만 플립 가능

  @override
  void initState() {
    super.initState();

    // 기존 플립 애니메이션 초기화
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // 진입 애니메이션 초기화
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 위에서 아래로 내려오는 애니메이션
    _slideAnimation = Tween<double>(
      begin: -400.0, // 카드 높이만큼 위에서 시작
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut, // 탄성 효과로 부드럽게 착지
    ));

    // 페이드 인 애니메이션
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    // 화면 진입 시 자동으로 애니메이션 시작
    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    _entryController.forward().then((_) {
      // 진입 애니메이션 완료 후 플립 가능하게 설정
      setState(() {
        _canFlip = true;
      });
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void flipCard() {
    if (!_canFlip || _isFlipped) return;

    setState(() {
      _isFlipped = true;
      _canFlip = false;
    });

    _flipController.forward().then((_) {
      if (widget.onFlipComplete != null) {
        widget.onFlipComplete!();
      }

      // 애니메이션 완료 후 1초 뒤에 다시 뒤집을 수 있게 함 (선택적)
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _canFlip = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카드 (진입 + 플립 애니메이션)
        GestureDetector(
          onTap: flipCard,
          child: AnimatedBuilder(
            animation: Listenable.merge([_slideAnimation, _fadeAnimation, _flipAnimation]),
            builder: (context, child) {
              final isShowingFront = _flipAnimation.value >= 0.5;
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                  // 진입 애니메이션: Y축 이동
                    ..translate(0.0, _slideAnimation.value)
                  // 플립 애니메이션: Y축 회전
                    ..rotateY(_flipAnimation.value * 3.14159),
                  child: Container(
                    width: 250,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: isShowingFront
                        ? _buildResultCard()
                        : _buildBackCard(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9E9E9E),
            Color(0xFF616161),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159), // 뒤집어서 표시
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.hasRedCard
                ? [Colors.red.shade400, Colors.red.shade700]
                : [Colors.green.shade400, Colors.green.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.hasRedCard ? Icons.close : Icons.check,
                size: 80,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Getter methods for external access
  bool get isFlipped => _isFlipped;
  bool get canFlip => _canFlip;
}