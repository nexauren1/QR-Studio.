import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/code_record.dart';

class StudioStorage {
  static const _recordsKey = 'qr_studio.records.v1';
  static const _darkKey = 'qr_studio.dark';
  static const _languageKey = 'qr_studio.language_pt';

  static Future<List<CodeRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recordsKey);
    if (raw == null || raw.isEmpty) return <CodeRecord>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CodeRecord.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return <CodeRecord>[];
    }
  }

  static Future<void> saveRecords(List<CodeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recordsKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkKey) ?? true;
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  static Future<bool> loadPortuguese() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageKey) ?? true;
  }

  static Future<void> savePortuguese(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageKey, value);
  }
}
