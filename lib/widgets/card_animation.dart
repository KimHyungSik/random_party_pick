import 'package:flutter/material.dart';

class CardAnimation extends StatelessWidget {
  final bool isRedCard;

  const CardAnimation({
    super.key,
    required this.isRedCard,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Transform.rotate(
            angle: (1 - value) * 4,
            child: Opacity(
              opacity: value,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  maxHeight: 280,
                ),
                decoration: BoxDecoration(
                  color: isRedCard ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isRedCard ? Colors.red : Colors.green)
                          .withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRedCard ? Icons.close : Icons.check,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRedCard ? '빨간 카드' : '녹색 카드',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}