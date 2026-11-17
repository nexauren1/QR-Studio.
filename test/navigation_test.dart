import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_studio/src/app/qr_studio_app.dart';
import 'package:qr_studio/src/screens/generator_screen.dart';
import 'package:qr_studio/src/screens/history_screen.dart';
import 'package:qr_studio/src/screens/qr_analyzer_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home tools open through the app navigator', (tester) async {
    await tester.pumpWidget(const QRStudioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gerar código QR'));
    await tester.pumpAndSettle();
    expect(find.byType(GeneratorScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histórico QR'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Analisador QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrAnalyzerScreen), findsOneWidget);
  });
}
