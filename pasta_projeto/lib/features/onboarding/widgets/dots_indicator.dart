import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const DotsIndicator({super.key, required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: i == activeIndex ? const Color(0xFFFBBF24) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), shape: BoxShape.circle),
      )),
    );
  }
}