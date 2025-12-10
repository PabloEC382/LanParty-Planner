import 'package:flutter/material.dart';

/// Product Tour - Indicadores que guiam o usuário na primeira execução
class ProductTour extends StatefulWidget {
  final int stepIndex;
  final String title;
  final String description;
  final Offset targetPosition;
  final Size targetSize;

  const ProductTour({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.description,
    required this.targetPosition,
    required this.targetSize,
  }) : super();

  @override
  State<ProductTour> createState() => _ProductTourState();
}

class _ProductTourState extends State<ProductTour> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.targetPosition.dx,
      top: widget.targetPosition.dy + widget.targetSize.height + 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Passo ${widget.stepIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              widget.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Widget que sobrepõe um overlay com destaque e desfoque do resto da tela
class ProductTourOverlay extends StatefulWidget {
  final int totalSteps;
  final int currentStep;
  final String title;
  final String description;
  final Offset targetPosition;
  final Size targetSize;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastStep;

  const ProductTourOverlay({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.title,
    required this.description,
    required this.targetPosition,
    required this.targetSize,
    required this.onNext,
    required this.onSkip,
    required this.isLastStep,
  }) : super();

  @override
  State<ProductTourOverlay> createState() => _ProductTourOverlayState();
}

class _ProductTourOverlayState extends State<ProductTourOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent dark overlay
        Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),

        // Highlight area (cutout in the overlay)
        CustomPaint(
          painter: _HighlightPainter(
            targetPosition: widget.targetPosition,
            targetSize: widget.targetSize,
          ),
          size: Size.infinite,
        ),

        // Tour tooltip with buttons
        Positioned(
          left: 16,
          right: 16,
          bottom: 32,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Passo ${widget.currentStep + 1} de ${widget.totalSteps}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${((widget.currentStep + 1) / widget.totalSteps * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (widget.currentStep + 1) / widget.totalSteps,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onSkip,
                      child: const Text('Pular'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.onNext,
                      child: Text(
                        widget.isLastStep ? 'Concluir' : 'Próximo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter para desenhar o cutout circular/arredondado
class _HighlightPainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;

  _HighlightPainter({
    required this.targetPosition,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const borderRadius = 8.0;
    
    // Draw path para criar o cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            targetPosition.dx - 8,
            targetPosition.dy - 8,
            targetSize.width + 16,
            targetSize.height + 16,
          ),
          const Radius.circular(borderRadius),
        ),
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5),
    );

    // Draw border ao redor do highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          targetPosition.dx - 8,
          targetPosition.dy - 8,
          targetSize.width + 16,
          targetSize.height + 16,
        ),
        const Radius.circular(borderRadius),
      ),
      Paint()
        ..color = Colors.purple.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_HighlightPainter oldDelegate) {
    return oldDelegate.targetPosition != targetPosition ||
        oldDelegate.targetSize != targetSize;
  }
}
