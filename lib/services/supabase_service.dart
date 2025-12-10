import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Obtém o cliente Supabase configurado
  static SupabaseClient get client => _client;

  /// Obtém a sessão do usuário atual
  static Session? get currentSession => _client.auth.currentSession;

  /// Obtém o usuário atual
  static User? get currentUser => _client.auth.currentUser;

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated => currentUser != null;

  /// Inicializa o Supabase e exibe informações de debug
  static void initializeSupabase() {
    try {
      developer.log('Supabase inicializado com sucesso', name: 'SupabaseService');
      
      if (isAuthenticated) {
        developer.log(
          'Usuário autenticado: ${currentUser?.email}',
          name: 'SupabaseService',
        );
      } else {
        developer.log('Nenhum usuário autenticado', name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Erro ao inicializar Supabase: $e', name: 'SupabaseService', error: e);
    }
  }
}
