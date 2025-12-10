enum TournamentStatus { 
  draft, 
  registration, 
  inProgress, 
  finished, 
  cancelled 
}

enum TournamentFormat { 
  singleElimination, 
  doubleElimination, 
  roundRobin, 
  swiss 
}

class Tournament {
  final String id;
  final String name;
  final String? description;
  final String gameId;
  final TournamentFormat format;
  final TournamentStatus status;
  final int maxParticipants; 
  final int currentParticipants; 
  final double prizePool;
  final DateTime startDate;
  final DateTime? endDate;
  final Set<String> organizerIds;
  final Map<String, dynamic> rules;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tournament({
    required this.id,
    required this.name,
    this.description,
    required this.gameId,
    required this.format,
    required this.status,
    required int maxParticipants,
    required int currentParticipants,
    required double prizePool,
    required this.startDate,
    this.endDate,
    Set<String>? organizerIds,
    Map<String, dynamic>? rules,
    required this.createdAt,
    required this.updatedAt,
  })  : maxParticipants = maxParticipants < 2 ? 2 : maxParticipants,
        currentParticipants = currentParticipants < 0 ? 0 : currentParticipants,
        prizePool = prizePool < 0 ? 0 : prizePool,
        organizerIds = {...?organizerIds},
        rules = {...?rules};

  String get statusText {
    switch (status) {
      case TournamentStatus.draft: return 'Rascunho';
      case TournamentStatus.registration: return 'Inscrições Abertas';
      case TournamentStatus.inProgress: return 'Em Andamento';
      case TournamentStatus.finished: return 'Finalizado';
      case TournamentStatus.cancelled: return 'Cancelado';
    }
  }

  String get formatText {
    switch (format) {
      case TournamentFormat.singleElimination: return 'Eliminação Simples';
      case TournamentFormat.doubleElimination: return 'Eliminação Dupla';
      case TournamentFormat.roundRobin: return 'Todos contra Todos';
      case TournamentFormat.swiss: return 'Sistema Suíço';
    }
  }

  String get prizeDisplay => prizePool > 0 
      ? 'R\$ ${prizePool.toStringAsFixed(2)}' 
      : 'Sem premiação';

  double get fillPercentage => (currentParticipants / maxParticipants) * 100;

  bool get isFull => currentParticipants >= maxParticipants;

  bool get canRegister => status == TournamentStatus.registration && !isFull;

  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    String? gameId,
    TournamentFormat? format,
    TournamentStatus? status,
    int? maxParticipants,
    int? currentParticipants,
    double? prizePool,
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? organizerIds,
    Map<String, dynamic>? rules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      gameId: gameId ?? this.gameId,
      format: format ?? this.format,
      status: status ?? this.status,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      prizePool: prizePool ?? this.prizePool,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      organizerIds: organizerIds ?? this.organizerIds,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}