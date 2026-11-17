import 'package:flutter_test/flutter_test.dart';
import 'package:qr_studio/src/services/qr_payload_builder.dart';

void main() {
  group('QrPayloadBuilder', () {
    test('normalizes a URL to HTTPS', () {
      expect(
        QrPayloadBuilder.build(type: 'URL', primary: 'nexauren.com'),
        'https://nexauren.com',
      );
    });

    test('rejects an invalid URL', () {
      expect(
        QrPayloadBuilder.build(type: 'URL', primary: 'not a url'),
        isNull,
      );
    });

    test('builds a Wi-Fi payload and escapes separators', () {
      final value = QrPayloadBuilder.build(
        type: 'Wi-Fi',
        primary: 'Office;Guest',
        secondary: 'p,ass',
        tertiary: 'WPA',
      );
      expect(value, contains(r'S:Office\;Guest'));
      expect(value, contains(r'P:p\,ass'));
      expect(value, endsWith(';;'));
    });

    test('builds a contact vCard', () {
      final value = QrPayloadBuilder.build(
        type: 'Contact',
        primary: 'Nexauren',
        secondary: '+258 84 000 0000',
        tertiary: 'hello@nexauren.com',
      );
      expect(value, contains('BEGIN:VCARD'));
      expect(value, contains('FN:Nexauren'));
      expect(value, contains('END:VCARD'));
    });

    test('builds an email QR payload', () {
      final value = QrPayloadBuilder.build(
        type: 'Email',
        primary: 'hello@nexauren.com',
        secondary: 'Hello from QR Studio',
        tertiary: 'A test message',
      );
      expect(value, startsWith('mailto:hello@nexauren.com?'));
      expect(value, contains('subject='));
    });

    test('builds a WhatsApp click-to-chat link', () {
      final value = QrPayloadBuilder.build(
        type: 'WhatsApp',
        primary: '+258 84 123 4567',
        secondary: 'Hello there',
      );
      expect(value, startsWith('https://wa.me/258841234567'));
      expect(value, contains('text=Hello'));
    });

    test('rejects out-of-range coordinates', () {
      expect(
        QrPayloadBuilder.build(
          type: 'Location',
          primary: '120',
          secondary: '32.5',
        ),
        isNull,
      );
    });

    test('builds a calendar event with a one-hour duration', () {
      final value = QrPayloadBuilder.build(
        type: 'Event',
        primary: 'Nexauren launch',
        secondary: 'Maputo',
        eventStart: DateTime.utc(2027, 1, 10, 10),
      );
      expect(value, contains('BEGIN:VCALENDAR'));
      expect(value, contains('SUMMARY:Nexauren launch'));
      expect(value, contains('DTSTART:20270110T100000Z'));
      expect(value, contains('DTEND:20270110T110000Z'));
      expect(value, contains('END:VCALENDAR'));
    });

    test('returns text without changing it except outer whitespace', () {
      expect(
        QrPayloadBuilder.build(type: 'Text', primary: ' Hello '),
        'Hello',
      );
    });
  });
}
