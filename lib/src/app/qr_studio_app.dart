import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/code_record.dart';
import '../screens/barcode_screen.dart';
import '../screens/bulk_generator_screen.dart';
import '../screens/generator_screen.dart';
import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/more_screen.dart';
import '../screens/qr_analyzer_screen.dart';
import '../screens/scanner_screen.dart';
import '../services/studio_localization.dart';
import '../services/studio_storage.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class QRStudioApp extends StatefulWidget {
  const QRStudioApp({super.key});

  @override
  State<QRStudioApp> createState() => _QRStudioAppState();
}

class _QRStudioAppState extends State<QRStudioApp> {
  List<CodeRecord> _records = [];
  bool _darkMode = true;
  String _languageCode = 'pt';
  bool get _portuguese => _languageCode == 'pt';
  bool _ready = false;
  int _tab = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final values = await Future.wait<Object>([
      StudioStorage.loadRecords(),
      StudioStorage.loadDarkMode(),
      StudioStorage.loadLanguageCode(),
    ]);
    if (!mounted) return;
    setState(() {
      _records = values[0] as List<CodeRecord>;
      _darkMode = values[1] as bool;
      _languageCode = values[2] as String;
      _ready = true;
    });
  }

  String tr(String en, String pt) => StudioLocalization.translate(en, pt, _languageCode);

  Future<void> _saveRecords() => StudioStorage.saveRecords(_records);

  void _addRecord(CodeRecord record) {
    _addRecords([record]);
  }

  void _addRecords(List<CodeRecord> records) {
    if (records.isEmpty) return;
    setState(() {
      final incomingIds = records.map((item) => item.id).toSet();
      _records = [
        ...records.reversed,
        ..._records.where((item) => !incomingIds.contains(item.id)),
      ].take(500).toList();
    });
    _saveRecords();
  }

  void _toggleFavorite(CodeRecord record) {
    setState(() {
      _records = _records
          .map((item) => item.id == record.id
              ? item.copyWith(isFavorite: !item.isFavorite)
              : item)
          .toList();
    });
    _saveRecords();
  }

  void _deleteRecord(CodeRecord record) {
    setState(() {
      _records = _records.where((item) => item.id != record.id).toList();
    });
    _saveRecords();
  }

  void _clearHistory() {
    setState(() => _records = []);
    _saveRecords();
  }

  void _openGenerator() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => GeneratorScreen(
        portuguese: _portuguese,
        languageCode: _languageCode,
        onSaved: _addRecord,
      ),
    ));
  }

  void _openBulkGenerator() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => BulkGeneratorScreen(
        portuguese: _portuguese,
        onSaved: _addRecords,
      ),
    ));
  }

  void _openScanner() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => ScannerScreen(
        portuguese: _portuguese,
        onSaved: _addRecord,
      ),
    ));
  }

  void _openBarcodeGenerator() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => BarcodeScreen(
        portuguese: _portuguese,
        onSaved: _addRecord,
      ),
    ));
  }

  void _openHistory() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => HistoryScreen(
        records: _records,
        portuguese: _portuguese,
        onFavorite: _toggleFavorite,
        onDelete: _deleteRecord,
        onClear: _clearHistory,
      ),
    ));
  }

  void _openAnalyzer() {
    _navigatorKey.currentState?.push(StudioPageRoute<void>(
      builder: (_) => QrAnalyzerScreen(portuguese: _portuguese, languageCode: _languageCode),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      locale: Locale(_languageCode),
      supportedLocales: StudioLocalization.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'QR Studio',
      debugShowCheckedModeBanner: false,
      theme: StudioTheme.light,
      darkTheme: StudioTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: !_ready
          ? const _LaunchScreen()
          : Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .025),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: _tab == 0
                      ? HomeScreen(
                          portuguese: _portuguese,
                          records: _records,
                          onGenerate: _openGenerator,
                          onScan: _openScanner,
                          onHistory: _openHistory,
                          onBulk: _openBulkGenerator,
                          onFavorites: () => setState(() => _tab = 1),
                          onMore: () => setState(() => _tab = 2),
                          onBarcode: _openBarcodeGenerator,
                          onAnalyze: _openAnalyzer,
                          onOpenRecord: _showRecord,
                        )
                      : _tab == 1
                          ? HistoryScreen(
                              records: _records,
                              portuguese: _portuguese,
                              favoritesOnly: true,
                              embedded: true,
                              onFavorite: _toggleFavorite,
                              onDelete: _deleteRecord,
                              onClear: _clearHistory,
                            )
                          : MoreScreen(
                              portuguese: _portuguese,
                              darkMode: _darkMode,
                              onGenerate: _openGenerator,
                              onScan: _openScanner,
                              onBarcode: _openBarcodeGenerator,
                              onBulk: _openBulkGenerator,
                              onHistory: _openHistory,
                              onAnalyze: _openAnalyzer,
                              onThemeChanged: (value) {
                                setState(() => _darkMode = value);
                                StudioStorage.saveDarkMode(value);
                              },
                              onLanguageChanged: (value) {
                                setState(() => _languageCode = value);
                                StudioStorage.saveLanguageCode(value);
                              },
                            ),
                ),
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: (value) =>
                    setState(() => _tab = value),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: tr('Home', 'Início'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border_rounded),
                    selectedIcon: const Icon(Icons.favorite_rounded),
                    label: tr('Favorites', 'Favoritos'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.more_horiz_rounded),
                    selectedIcon: const Icon(Icons.grid_view_rounded),
                    label: tr('More', 'Mais'),
                  ),
                ],
              ),
            ),
    );
  }

  void _showRecord(CodeRecord record) {
    final modalContext = _navigatorKey.currentState?.overlay?.context;
    if (modalContext == null) return;
    showModalBottomSheet<void>(
      context: modalContext,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.type,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SelectableText(record.data),
            const SizedBox(height: 18),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _toggleFavorite(record);
                    Navigator.pop(sheetContext);
                  },
                  icon: Icon(record.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  label: Text(tr('Favorite', 'Favoritar')),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.check),
                  label: Text(tr('Done', 'Concluir')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08091B), Color(0xFF171044), Color(0xFF08091B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StudioLogo(size: 104),
            SizedBox(height: 22),
            Text('QR Studio',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Text('CREATE  •  SCAN  •  SHARE',
                style: TextStyle(
                    color: StudioColors.muted,
                    fontSize: 11,
                    letterSpacing: 2)),
            SizedBox(height: 36),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: StudioColors.purple,
              ),
            ),
            SizedBox(height: 12),
            Text('Preparing your tools…',
                style: TextStyle(color: StudioColors.muted, fontSize: 12)),
            SizedBox(height: 44),
            Text('N E X A U R E N',
                style: TextStyle(
                    color: StudioColors.muted,
                    fontSize: 10,
                    letterSpacing: 3)),
          ],
        ),
      ),
    );
  }
}
