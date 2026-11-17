class QrPayloadBuilder {
  const QrPayloadBuilder._();

  static String? build({
    required String type,
    required String primary,
    String secondary = '',
    String tertiary = '',
    DateTime? eventStart,
  }) {
    final first = primary.trim();
    final second = secondary.trim();
    final third = tertiary.trim();

    switch (type) {
      case 'URL':
        if (first.isEmpty) return null;
        final value = first.startsWith('http://') ||
                first.startsWith('https://')
            ? first
            : 'https://' + first;
        final uri = Uri.tryParse(value);
        return uri != null && uri.hasAuthority ? value : null;
      case 'Wi-Fi':
        if (first.isEmpty) return null;
        return 'WIFI:T:' + third + ';S:' + _escapeWifi(first) +
            ';P:' + _escapeWifi(second) + ';;';
      case 'Contact':
        if (first.isEmpty && second.isEmpty && third.isEmpty) return null;
        return [
          'BEGIN:VCARD',
          'VERSION:3.0',
          if (first.isNotEmpty) 'FN:' + _escapeVCard(first),
          if (second.isNotEmpty) 'TEL:' + _escapeVCard(second),
          if (third.isNotEmpty) 'EMAIL:' + _escapeVCard(third),
          'END:VCARD',
        ].join('\r\n');
      case 'Email':
        if (first.isEmpty || !first.contains('@')) return null;
        final query = <String, String>{};
        if (second.isNotEmpty) query['subject'] = second;
        if (third.isNotEmpty) query['body'] = third;
        return Uri(
          scheme: 'mailto',
          path: first,
          queryParameters: query.isEmpty ? null : query,
        ).toString();
      case 'Phone':
        if (first.isEmpty) return null;
        return 'tel:' + first;
      case 'SMS':
        if (first.isEmpty) return null;
        return 'SMSTO:' + first + ':' + second;
      case 'Location':
        final latitude = double.tryParse(first);
        final longitude = double.tryParse(second);
        if (latitude == null ||
            longitude == null ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180) {
          return null;
        }
        return 'geo:' + latitude.toString() + ',' + longitude.toString() +
            '?q=' + latitude.toString() + ',' + longitude.toString();
      case 'WhatsApp':
        final digits = first.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length < 8 || digits.length > 15) return null;
        final uri = Uri.https(
          'wa.me',
          '/' + digits,
          second.isEmpty ? null : {'text': second},
        );
        return uri.toString();
      case 'Event':
        if (first.isEmpty || eventStart == null) return null;
        final now = DateTime.now();
        final end = eventStart.add(const Duration(hours: 1));
        final stamp = _calendarDate(now.toUtc());
        final start = _calendarDate(eventStart.toUtc());
        final finish = _calendarDate(end.toUtc());
        final uid = now.microsecondsSinceEpoch.toString() + '@qr-studio.nexauren';
        return [
          'BEGIN:VCALENDAR',
          'VERSION:2.0',
          'PRODID:-//Nexauren//QR Studio//EN',
          'BEGIN:VEVENT',
          'UID:' + uid,
          'DTSTAMP:' + stamp,
          'DTSTART:' + start,
          'DTEND:' + finish,
          'SUMMARY:' + _escapeCalendar(first),
          if (second.isNotEmpty) 'LOCATION:' + _escapeCalendar(second),
          if (third.isNotEmpty) 'DESCRIPTION:' + _escapeCalendar(third),
          'END:VEVENT',
          'END:VCALENDAR',
        ].join('\r\n');
      default:
        return first.isEmpty ? null : first;
    }
  }

  static String _escapeWifi(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,');

  static String _escapeVCard(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\n', '\\n');

  static String _escapeCalendar(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\n', '\\n');

  static String _calendarDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return value.year.toString() +
        two(value.month) +
        two(value.day) +
        'T' +
        two(value.hour) +
        two(value.minute) +
        two(value.second) +
        'Z';
  }
}
