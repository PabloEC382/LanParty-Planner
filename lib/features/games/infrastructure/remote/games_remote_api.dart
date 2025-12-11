import '../dtos/game_dto.dart';
import '../../../../core/models/remote_page.dart';

abstract class GamesRemoteApi {
  /// Busca games do servidor Supabase com paginação e filtro por data.
  Future<RemotePage<GameDto>> fetchGames({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Faz upsert de games no servidor Supabase.
  Future<int> upsertGames(List<GameDto> dtos);

  /// Cria um novo game no servidor Supabase.
  Future<GameDto> createGame(GameDto dto);

  /// Atualiza um game existente no servidor Supabase.
  Future<GameDto> updateGame(String id, GameDto dto);

  /// Deleta um game do servidor Supabase.
  Future<void> deleteGame(String id);
}
