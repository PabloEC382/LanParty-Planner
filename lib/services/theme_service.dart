import 'package:lan_party_planner/features/core/theme_controller.dart';

/// Serviço global para acessar o ThemeController
class ThemeService {
  static late ThemeController _controller;

  /// Inicializa o serviço com o controller
  static void initialize(ThemeController controller) {
    _controller = controller;
  }

  /// Retorna a instância do ThemeController
  static ThemeController get instance => _controller;
}
