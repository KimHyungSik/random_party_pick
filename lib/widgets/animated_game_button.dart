// 파티 게임에 어울리는 재미있는 애니메이션
import 'package:flutter/material.dart';

import 'gradient_button.dart';

class AnimatedGameButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool show;
  final String buttonText;

  const AnimatedGameButton({
    super.key,
    required this.onPressed,
    required this.show,
    required this.buttonText,
  });

  @override
  State<AnimatedGameButton> createState() => _AnimatedGameButtonState();
}

class _AnimatedGameButtonState extends State<AnimatedGameButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 메인 애니메이션 컨트롤러
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 펄스 애니메이션 컨트롤러
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 슬라이드 애니메이션 (밑에서 위로)
    _slideAnimation = Tween<double>(
      begin: 150.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // 스케일 애니메이션 (펑! 하고 나타나기)
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.bounceOut),
    ));

    // 살짝 회전 효과
    _rotationAnimation = Tween<double>(
      begin: 0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    // 펄스 효과 (반복)
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedGameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward().then((_) {
        // 메인 애니메이션 완료 후 펄스 시작
        _pulseController.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    // 글로우 효과
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 0),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    onPressed: () {
                      widget.onPressed();
                    },
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6A5ACD), // 슬레이트 블루
                        Color(0xFF8A2BE2), // 블루 바이올렛
                        Color(0xFF9932CC), // 다크 오키드
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}