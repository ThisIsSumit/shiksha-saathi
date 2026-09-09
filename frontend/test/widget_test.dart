import 'package:flutter_test/flutter_test.dart';
import 'package:shiksha_saathi/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App cold start renders splash screen with branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShikshaSaathiApp());

    // Verify Shiksha Saathi branding is present on splash screen
    expect(find.text('Shiksha Saathi'), findsOneWidget);
    expect(find.text('शिक्षा साथी'), findsOneWidget);

    // Advance clock past the splash fallback and auth check timers
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
