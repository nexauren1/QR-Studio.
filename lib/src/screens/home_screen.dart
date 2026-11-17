import 'package:flutter/material.dart';

import '../models/code_record.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.portuguese,
    required this.records,
    required this.onGenerate,
    required this.onScan,
    required this.onHistory,
    required this.onFavorites,
    required this.onMore,
    required this.onBarcode,
    required this.onBulk,
    required this.onAnalyze,
    required this.onOpenRecord,
  });

  final bool portuguese;
  final List<CodeRecord> records;
  final VoidCallback onGenerate;
  final VoidCallback onScan;
  final VoidCallback onHistory;
  final VoidCallback onFavorites;
  final VoidCallback onMore;
  final VoidCallback onBarcode;
  final VoidCallback onBulk;
  final VoidCallback onAnalyze;
  final ValueChanged<CodeRecord> onOpenRecord;

  String tr(String en, String pt) => portuguese ? pt : en;

  @override
  Widget build(BuildContext context) {
    final recent = records.take(3).toList();
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: tr('Open menu', 'Abrir menu'),
                ),
                const Spacer(),
                const Text(
                  'QR ',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Studio',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: StudioColors.purple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onFavorites,
                  icon: const Icon(Icons.workspace_premium_rounded,
                      color: StudioColors.orange),
                  tooltip: tr('Favorites', 'Favoritos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StudioCard(
              padding: const EdgeInsets.fromLTRB(20, 19, 12, 19),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6E10D9),
                  Color(0xFF3F25CB),
                  Color(0xFF174CCB)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: Colors.transparent,
              onTap: onGenerate,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Smart QR Tools', 'Ferramentas QR inteligentes'),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 7),
                        Text(
                          tr('Generate, scan and share in seconds.',
                              'Crie, leia e partilhe em segundos.'),
                          style: const TextStyle(
                              color: Colors.white70, height: 1.45, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Text(tr('Explore tools', 'Explorar ferramentas'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.qr_code_2_rounded,
                      size: 88, color: Colors.white),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 23),
            SectionHeading(tr('Quick actions', 'Ações rápidas')),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                ToolTile(
                  title: tr('Generate QR Code', 'Gerar código QR'),
                  subtitle: tr('Text, URL, Wi-Fi, contact', 'Texto, URL, Wi-Fi, contacto'),
                  icon: Icons.qr_code_2_rounded,
                  color: const Color(0xFF5E86FF),
                  onTap: onGenerate,
                ),
                ToolTile(
                  title: tr('Scan QR Code', 'Ler código QR'),
                  subtitle: tr('Use camera or gallery', 'Use a câmara ou galeria'),
                  icon: Icons.qr_code_scanner_rounded,
                  color: StudioColors.green,
                  onTap: onScan,
                ),
                ToolTile(
                  title: tr('QR History', 'Histórico QR'),
                  subtitle: tr('Your recent activity', 'A sua atividade recente'),
                  icon: Icons.history_rounded,
                  color: const Color(0xFFAD72FF),
                  onTap: onHistory,
                ),
                ToolTile(
                  title: tr('Create Barcode', 'Criar código de barras'),
                  subtitle: tr('Generate Code 128', 'Gerar Code 128'),
                  icon: Icons.view_week_rounded,
                  color: StudioColors.orange,
                  onTap: onBarcode,
                ),
                ToolTile(
                  title: tr('All tools', 'Todas as ferramentas'),
                  subtitle: tr('Discover QR Studio', 'Conheça o QR Studio'),
                  icon: Icons.handyman_rounded,
                  color: StudioColors.cyan,
                  onTap: onMore,
                ),
                ToolTile(
                  title: tr('Bulk QR Generator', 'Gerador QR em lote'),
                  subtitle: tr('Create up to 50 codes', 'Criar até 50 códigos'),
                  icon: Icons.auto_awesome_mosaic_rounded,
                  color: const Color(0xFF8C6CFF),
                  onTap: onBulk,
                ),
                ToolTile(
                  title: tr('QR Analyzer', 'Analisador QR'),
                  subtitle: tr('Inspect QR content and links', 'Analisar conteúdo e ligações'),
                  icon: Icons.manage_search_rounded,
                  color: StudioColors.cyan,
                  onTap: onAnalyze,
                ),
                ToolTile(
                  title: tr('Settings', 'Definições'),
                  subtitle: tr('Language and appearance', 'Idioma e aparência'),
                  icon: Icons.settings_rounded,
                  color: const Color(0xFFB5A7FF),
                  onTap: onMore,
                ),
              ],
            ),
            const SizedBox(height: 23),
            SectionHeading(
              tr('Recent activity', 'Atividade recente'),
              action: tr('See all', 'Ver tudo'),
              onAction: onHistory,
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              StudioCard(
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_rounded,
                        color: StudioColors.muted, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('Your generated and scanned codes will appear here.',
                            'Os códigos criados e lidos aparecerão aqui.'),
                        style: const TextStyle(
                            color: StudioColors.muted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recent.map((record) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RecentRecord(
                      record: record,
                      portuguese: portuguese,
                      onTap: () => onOpenRecord(record),
                    ),
                  )),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StudioLogo(size: 22),
                  const SizedBox(width: 8),
                  Text('NEXAUREN',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRecord extends StatelessWidget {
  const _RecentRecord({
    required this.record,
    required this.portuguese,
    required this.onTap,
  });

  final CodeRecord record;
  final bool portuguese;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scanned = record.type.toLowerCase().contains('scan') ||
        record.type.toLowerCase().contains('lido');
    return StudioCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: (scanned ? StudioColors.green : StudioColors.purple)
                  .withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              scanned ? Icons.qr_code_scanner_rounded : Icons.qr_code_rounded,
              color: scanned ? StudioColors.green : StudioColors.purple,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '${record.type}  •  ${record.createdAt.day.toString().padLeft(2, '0')}/${record.createdAt.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      color: StudioColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: StudioColors.muted),
        ],
      ),
    );
  }
}
