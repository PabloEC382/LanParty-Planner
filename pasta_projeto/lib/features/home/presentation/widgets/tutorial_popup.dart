import 'package:flutter/material.dart';

class TutorialPopup extends StatefulWidget {
  final VoidCallback onClose;

  const TutorialPopup({
    super.key,
    required this.onClose,
  }) : super();

  @override
  State<TutorialPopup> createState() => _TutorialPopupState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => TutorialPopup(
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _TutorialPopupState extends State<TutorialPopup> {
  int _currentStep = 0;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      title: 'Bem-vindo ao Lan Party Planner!',
      description: 'Este aplicativo ajuda você a organizar e gerenciar eventos de jogos.',
      icon: Icons.celebration,
    ),
    _TutorialStep(
      title: 'Próximos Eventos',
      description: 'Veja os eventos programados para a próxima semana na seção destacada.',
      icon: Icons.calendar_today,
    ),
    _TutorialStep(
      title: 'Gerenciar Eventos',
      description: 'Crie, edite ou delete seus eventos através do menu lateral.',
      icon: Icons.event,
    ),
    _TutorialStep(
      title: 'Jogos e Torneios',
      description: 'Organize seus jogos, crie torneios e convide participantes.',
      icon: Icons.sports_esports,
    ),
    _TutorialStep(
      title: 'Locais e Participantes',
      description: 'Gerencie os locais dos eventos e a lista de participantes.',
      icon: Icons.people,
    ),
    _TutorialStep(
      title: 'Pronto!',
      description: 'Agora você está pronto para começar. Aproveite o aplicativo!',
      icon: Icons.check_circle,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                step.icon,
                size: 32,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              step.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentStep
                        ? Colors.purple
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentStep == 0 ? null : _previousStep,
                  child: const Text(
                    'Anterior',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text(
                    'Fechar',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: ElevatedButton(
                    onPressed: _currentStep == _steps.length - 1
                        ? widget.onClose
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1 ? 'Concluir' : 'Próx.',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  _TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
