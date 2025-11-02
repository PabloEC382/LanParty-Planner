/// Domain entity representing a Participant in a gaming event.
///
/// This is the internal application model with strong typing and domain invariants.
/// The UI consumes this clean, validated representation.
class Participant {
  final String id;
  final String name;
  final String email;
  final Uri? avatarUri; // Stronger than String
  final String nickname;
  final int skillLevel; // 1-5, clamped
  final Set<String> preferredGames; // Set prevents duplicates
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
  })  : skillLevel = skillLevel.clamp(1, 5), // Invariant: skill always 1-5
        preferredGames = {...?preferredGames};

  /// Convenience: Display name with nickname
  String get displayName => '$name (@$nickname)';

  /// Convenience: Skill level as text
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

  /// Convenience: Badge for UI
  String get badge => isPremium ? '⭐ Premium' : '🎮 Jogador';

  /// Validation: Check if email format is valid
  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  /// Immutable copy with modifications
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