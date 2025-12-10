
class Participant {
  final String id;
  final String name;
  final String email;
  final Uri? avatarUri;
  final String nickname;
  final int skillLevel;
  final Set<String> preferredGames;
  final bool isPremium;
  final DateTime registeredAt;
  final DateTime updatedAt;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUri,
    required this.nickname,
    required int skillLevel,
    Set<String>? preferredGames,
    this.isPremium = false,
    required this.registeredAt,
    required this.updatedAt,
  })  : skillLevel = skillLevel.clamp(1, 5),
        preferredGames = {...?preferredGames};

  String get displayName => '$name (@$nickname)';

  String get skillLevelText {
    switch (skillLevel) {
      case 1: return 'Iniciante';
      case 2: return 'Casual';
      case 3: return 'Intermediário';
      case 4: return 'Avançado';
      case 5: return 'Profissional';
      default: return 'Desconhecido';
    }
  }

  String get badge => isPremium ? '⭐ Premium' : '🎮 Jogador';

  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Participant copyWith({
    String? id,
    String? name,
    String? email,
    Uri? avatarUri,
    String? nickname,
    int? skillLevel,
    Set<String>? preferredGames,
    bool? isPremium,
    DateTime? registeredAt,
    DateTime? updatedAt,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUri: avatarUri ?? this.avatarUri,
      nickname: nickname ?? this.nickname,
      skillLevel: skillLevel ?? this.skillLevel,
      preferredGames: preferredGames ?? this.preferredGames,
      isPremium: isPremium ?? this.isPremium,
      registeredAt: registeredAt ?? this.registeredAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}