import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late SupabaseClient _client;
  static bool _isInitialized = false;

  /// Inicializa o cliente Supabase (deve ser chamado após Supabase.initialize)
  static void _initializeClient() {
    if (!_isInitialized) {
      try {
        _client = Supabase.instance.client;
        _isInitialized = true;
        developer.log('SupabaseService cliente inicializado', name: 'SupabaseService');
      } catch (e) {
        developer.log('Erro ao inicializar cliente Supabase: $e', name: 'SupabaseService', error: e);
      }
    }
  }

  /// Obtém o cliente Supabase configurado
  static SupabaseClient get client {
    _initializeClient();
    if (!_isInitialized) {
      throw StateError('Supabase não foi inicializado. Chame Supabase.initialize() em main() antes de usar SupabaseService.');
    }
    return _client;
  }

  /// Obtém a sessão do usuário atual
  static Session? get currentSession {
    try {
      return client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  /// Obtém o usuário atual
  static User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated => currentUser != null;

  /// Inicializa o Supabase e exibe informações de debug
  static void initializeSupabase() {
    try {
      _initializeClient();
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
