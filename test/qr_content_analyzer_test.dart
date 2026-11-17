import 'package:flutter_test/flutter_test.dart';
import 'package:qr_studio/src/services/qr_content_analyzer.dart';

void main() {
  group('QrContentAnalyzer', () {
    test('identifies website links without a scheme', () {
      final result = QrContentAnalyzer.analyze('example.com/path');
      expect(result.type, 'Website link');
      expect(result.actionUri?.scheme, 'https');
      expect(result.actionUri?.host, 'example.com');
    });

    test('extracts Wi-Fi details', () {
      final result = QrContentAnalyzer.analyze(
        r'WIFI:T:WPA;S:Studio Guest;P:welcome123;H:false;;',
      );
      expect(result.type, 'Wi-Fi network');
      expect(result.details['Network name'], 'Studio Guest');
      expect(result.details['Password'], 'welcome123');
      expect(result.details['Security'], 'WPA');
    });

    test('identifies contact cards', () {
      final result = QrContentAnalyzer.analyze(
        'BEGIN:VCARD\nVERSION:3.0\nFN:Alex Doe\nTEL:+258840000000\nEND:VCARD',
      );
      expect(result.type, 'Contact card');
      expect(result.details['Contact name'], 'Alex Doe');
      expect(result.details['Phone'], '+258840000000');
    });

    test('keeps ordinary text as plain text', () {
      final result = QrContentAnalyzer.analyze('Hello from QR Studio');
      expect(result.type, 'Plain text');
      expect(result.actionUri, isNull);
    });
  });
}
