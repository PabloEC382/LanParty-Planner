import 'package:flutter/material.dart';
import 'features/core/supabase_config.dart';
import 'features/app/lan_party_planner_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const LanPartyPlannerApp());
}