import '../dtos/tournament_dto.dart';
import '../../../../core/models/remote_page.dart';

abstract class TournamentsRemoteApi {
  /// Busca tournaments do servidor Supabase com paginação e filtro por data.
  Future<RemotePage<TournamentDto>> fetchTournaments({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert de tournaments no servidor Supabase.
  Future<int> upsertTournaments(List<TournamentDto> dtos);

  /// Cria um novo tournament no servidor Supabase.
  Future<TournamentDto> createTournament(TournamentDto dto);

  /// Atualiza um tournament existente no servidor Supabase.
  Future<TournamentDto> updateTournament(String id, TournamentDto dto);

  /// Deleta um tournament do servidor Supabase.
  Future<void> deleteTournament(String id);
}
