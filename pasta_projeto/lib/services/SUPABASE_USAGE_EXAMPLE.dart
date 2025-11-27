/// Exemplo de como usar o SupabaseService no seu projeto
/// 
/// Este arquivo é apenas para referência. Você pode deletar depois de ler.
/// 
/// USO SIMPLES:
/// 
/// ```dart
/// import 'package:lan_party_planner/services/supabase_service.dart';
/// 
/// // Acessar o cliente Supabase
/// final client = SupabaseService.client;
/// 
/// // Verificar se há usuário autenticado
/// if (SupabaseService.isAuthenticated) {
///   final userEmail = SupabaseService.currentUser?.email;
///   debugPrint('Usuário: $userEmail');
/// }
/// 
/// // Obter dados do banco de dados
/// final response = await SupabaseService.client
///   .from('sua_tabela')
///   .select()
///   .execute();
/// ```
/// 
/// EXEMPLO EM UM WIDGET:
/// 
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'services/supabase_service.dart';
/// 
/// class MeuWidget extends StatelessWidget {
///   const MeuWidget({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     final isAuthenticated = SupabaseService.isAuthenticated;
///     
///     if (isAuthenticated) {
///       final userEmail = SupabaseService.currentUser?.email ?? 'Desconhecido';
///       return Text('Bem-vindo, $userEmail!');
///     }
///     
///     return const Text('Faça login para continuar');
///   }
/// }
/// ```
/// 
/// PROPRIEDADES DISPONÍVEIS:
/// - `SupabaseService.client` - Cliente Supabase para operações no banco
/// - `SupabaseService.currentUser` - Usuário autenticado (null se deslogado)
/// - `SupabaseService.currentSession` - Sessão atual
/// - `SupabaseService.isAuthenticated` - Boolean se usuário está logado
/// - `SupabaseService.initializeSupabase()` - Exibe logs de inicialização
