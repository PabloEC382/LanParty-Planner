import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mnbvzkyxglxwuoxhcbtl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1uYnZ6a3l4Z2x4d3VveGhjYnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxMDY2MzIsImV4cCI6MjA3NzY4MjYzMn0.2TkEK2MDK-QAhl_JbTdqL6GfZhYok043-FgFo4_aHCk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}