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
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _canFlip = true;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _flipController.dispose();
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
        // 카드
        GestureDetector(
          onTap: flipCard,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final isShowingFront = _flipAnimation.value >= 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * 3.14159),
                child: Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isShowingFront
                      ? _buildResultCard()
                      : _buildBackCard(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 안내 텍스트
        if (!_isFlipped) ...[
          const Icon(
            Icons.touch_app,
            color: Colors.white70,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            '카드를 터치해서 결과를 확인하세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ]
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
            SizedBox(height: 16),
            Text(
              '?',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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