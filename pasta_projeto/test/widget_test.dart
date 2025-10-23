import 'package:flutter_test/flutter_test.dart';
import 'package:lan_party_planner/features/app/lan_party_planner_app.dart';

void main() {
  testWidgets('App mostra título da splash', (WidgetTester tester) async {
    await tester.pumpWidget(const LanPartyPlannerApp());
    await tester.pumpAndSettle();
    expect(find.text('GAMER EVENT PLATFORM'), findsOneWidget);
  });
}
