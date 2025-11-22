import 'package:flutter/material.dart';

class OnboardingTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final String tooltipKey;

  const OnboardingTooltip({
    required this.child,
    required this.message,
    required this.tooltipKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: child,
    );
  }
}
