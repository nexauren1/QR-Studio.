class QrAnalysisResult {
  const QrAnalysisResult({
    required this.type,
    required this.summary,
    this.details = const <String, String>{},
    this.actionUri,
  });

  final String type;
  final String summary;
  final Map<String, String> details;
  final Uri? actionUri;
}

class QrContentAnalyzer {
  const QrContentAnalyzer._();

  static QrAnalysisResult analyze(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return const QrAnalysisResult(
        type: 'Empty',
        summary: 'Enter QR content to inspect it.',
      );
    }

    final upper = value.toUpperCase();

    if (upper.startsWith('WIFI:')) {
      final payload = value.substring(5);
      final ssid = _wifiField(payload, 'S');
      final password = _wifiField(payload, 'P');
      final security = _wifiField(payload, 'T');
      return QrAnalysisResult(
        type: 'Wi-Fi network',
        summary: ssid == null || ssid.isEmpty
            ? 'A wireless network configuration was detected.'
            : 'Network: $ssid',
        details: <String, String>{
          if (ssid != null && ssid.isNotEmpty) 'Network name': ssid,
          if (security != null && security.isNotEmpty) 'Security': security,
          if (password != null && password.isNotEmpty) 'Password': password,
          'Hidden network': _wifiField(payload, 'H') ?? 'false',
        },
      );
    }

    if (upper.contains('BEGIN:VCARD')) {
      final fields = _structuredFields(value, <String, String>{
        'FN': 'Contact name',
        'N': 'Name',
        'ORG': 'Organisation',
        'TEL': 'Phone',
        'EMAIL': 'Email',
        'URL': 'Website',
      });
      return QrAnalysisResult(
        type: 'Contact card',
        summary: fields['Contact name'] ?? 'A contact card was detected.',
        details: fields,
        actionUri: fields['Email'] == null
            ? null
            : Uri(scheme: 'mailto', path: fields['Email']),
      );
    }

    if (upper.contains('BEGIN:VCALENDAR')) {
      final fields = _structuredFields(value, <String, String>{
        'SUMMARY': 'Event',
        'DTSTART': 'Starts',
        'DTEND': 'Ends',
        'LOCATION': 'Location',
        'DESCRIPTION': 'Description',
      });
      return QrAnalysisResult(
        type: 'Calendar event',
        summary: fields['Event'] ?? 'A calendar event was detected.',
        details: fields,
      );
    }

    if (upper.startsWith('GEO:')) {
      final coordinateText = value.substring(4).split('?').first;
      final parts = coordinateText.split(',');
      return QrAnalysisResult(
        type: 'Geographic location',
        summary: 'A geographic location was detected.',
        details: <String, String>{
          if (parts.isNotEmpty) 'Latitude': parts[0],
          if (parts.length > 1) 'Longitude': parts[1],
        },
      );
    }

    if (upper.startsWith('SMSTO:')) {
      final parts = value.substring(6).split(':');
      return QrAnalysisResult(
        type: 'SMS message',
        summary: parts.isEmpty ? 'An SMS action was detected.' : 'To: \${parts[0]}',
        details: <String, String>{
          if (parts.isNotEmpty) 'Phone': parts[0],
          if (parts.length > 1) 'Message': parts.sublist(1).join(':'),
        },
        actionUri: parts.isEmpty || parts[0].isEmpty
            ? null
            : Uri(scheme: 'sms', path: parts[0]),
      );
    }

    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.scheme.toLowerCase() == 'mailto') {
      return QrAnalysisResult(
        type: 'Email',
        summary: parsed.path.isEmpty ? 'An email action was detected.' : 'To: \${parsed.path}',
        details: <String, String>{
          if (parsed.path.isNotEmpty) 'Email address': parsed.path,
          if ((parsed.queryParameters['subject'] ?? '').isNotEmpty)
            'Subject': parsed.queryParameters['subject']!,
        },
        actionUri: parsed,
      );
    }

    if (parsed != null && parsed.scheme.toLowerCase() == 'tel') {
      return QrAnalysisResult(
        type: 'Phone number',
        summary: 'A phone action was detected.',
        details: <String, String>{'Phone': parsed.path},
        actionUri: parsed,
      );
    }

    if (parsed != null &&
        <String>{'http', 'https'}.contains(parsed.scheme.toLowerCase()) &&
        parsed.host.isNotEmpty) {
      final isWhatsApp = parsed.host.toLowerCase() == 'wa.me' ||
          parsed.host.toLowerCase().endsWith('.whatsapp.com');
      return QrAnalysisResult(
        type: isWhatsApp ? 'WhatsApp link' : 'Website link',
        summary: parsed.host,
        details: <String, String>{
          'Address': value,
          if (parsed.path.length > 1) 'Path': parsed.path,
        },
        actionUri: parsed,
      );
    }

    if (!RegExp(r'\s').hasMatch(value)) {
      final candidate = Uri.tryParse('https://$value');
      if (candidate != null &&
          candidate.host.contains('.') &&
          candidate.host.isNotEmpty) {
        return QrAnalysisResult(
          type: 'Website link',
          summary: candidate.host,
          details: <String, String>{'Address': candidate.toString()},
          actionUri: candidate,
        );
      }
    }

    if (RegExp(r'^[+0-9][0-9\s().-]{6,}$').hasMatch(value)) {
      return QrAnalysisResult(
        type: 'Phone number',
        summary: 'A phone number was detected.',
        details: <String, String>{'Phone': value},
        actionUri: Uri(scheme: 'tel', path: value.replaceAll(' ', '')),
      );
    }

    return QrAnalysisResult(
      type: 'Plain text',
      summary: 'This QR code contains text or data.',
      details: <String, String>{'Content': value},
    );
  }

  static String? _wifiField(String payload, String key) {
    final match = RegExp('(?:^|;)$key:([^;]*)').firstMatch(payload);
    return match?.group(1)?.replaceAll(r'\;', ';').replaceAll(r'\:', ':');
  }

  static Map<String, String> _structuredFields(
    String value,
    Map<String, String> labels,
  ) {
    final result = <String, String>{};
    for (final line in value.split(RegExp(r'\r?\n'))) {
      final separator = line.indexOf(':');
      if (separator <= 0) continue;
      final rawKey = line.substring(0, separator).split(';').first.toUpperCase();
      final label = labels[rawKey];
      final content = line.substring(separator + 1).trim();
      if (label != null && content.isNotEmpty) {
        result[label] = content.replaceAll(r'\n', ' ').replaceAll(r'\,', ',');
      }
    }
    return result;
  }
}
