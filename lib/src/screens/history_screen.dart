import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../models/code_record.dart';
import '../services/studio_localization.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.records,
    required this.portuguese,
    required this.languageCode,
    required this.onFavorite,
    required this.onDelete,
    required this.onClear,
    this.favoritesOnly = false,
    this.embedded = false,
  });

  final List<CodeRecord> records;
  final bool portuguese;
  final String languageCode;
  final bool favoritesOnly;
  final bool embedded;
  final ValueChanged<CodeRecord> onFavorite;
  final ValueChanged<CodeRecord> onDelete;
  final VoidCallback onClear;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  String _query = '';

  String tr(String en, String pt) => StudioLocalization.translate(en, pt, widget.languageCode);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CodeRecord> get _filtered {
    final query = _query.trim().toLowerCase();
    return widget.records.where((record) {
      if (widget.favoritesOnly && !record.isFavorite) return false;
      if (_filter == 'Generated' &&
          !record.type.toLowerCase().contains('qr ·') &&
          !record.type.toLowerCase().contains('barcode')) {
        return false;
      }
      if (_filter == 'Scanned' &&
          !record.type.toLowerCase().contains('scan') &&
          !record.type.toLowerCase().contains('lido')) {
        return false;
      }
      if (query.isNotEmpty &&
          !record.data.toLowerCase().contains(query) &&
          !record.type.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _showDetails(CodeRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.type,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            SelectableText(record.data),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: record.data));
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(tr('Copy', 'Copiar')),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onFavorite(record);
                    Navigator.pop(sheetContext);
                  },
                  icon: Icon(record.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  label: Text(tr('Favorite', 'Favorito')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportHistoryCsv() async {
    final records = _filtered;
    if (records.isEmpty) return;
    try {
      String cell(String value) => '"${value.replaceAll('"', '""')}"';
      final rows = <List<String>>[
        ['Created at', 'Type', 'Content', 'Favorite'],
        for (final record in records)
          [record.createdAt.toIso8601String(), record.type, record.data, record.isFavorite ? 'yes' : 'no'],
      ];
      final csv = '\\uFEFF' + rows.map((row) => row.map(cell).join(',')).join('\\r\\n');
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/qr_studio_history_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv, encoding: utf8, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        text: tr('QR Studio history export', 'Exportação do histórico QR Studio'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('History exported.', 'Histórico exportado.'))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Could not export history.', 'Não foi possível exportar o histórico.'))),
        );
      }
    }
  }

  Widget _content(BuildContext context) {
    final items = _filtered;
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.favoritesOnly
                        ? tr('Favorites', 'Favoritos')
                        : tr('QR History', 'Histórico QR'),
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),
                if (widget.records.isNotEmpty)
                  IconButton(
                    tooltip: tr('Export history CSV', 'Exportar histórico CSV'),
                    onPressed: _exportHistoryCsv,
                    icon: const Icon(Icons.file_download_outlined),
                  ),
                if (!widget.favoritesOnly && widget.records.isNotEmpty)
                  IconButton(
                    tooltip: tr('Clear history', 'Limpar histórico'),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(tr('Clear history?', 'Limpar histórico?')),
                        content: Text(tr(
                            'This removes all saved QR and scan records from this device.',
                            'Isto remove todos os registos QR e leituras guardados neste dispositivo.')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(tr('Cancel', 'Cancelar')),
                          ),
                          FilledButton(
                            onPressed: () {
                              widget.onClear();
                              Navigator.pop(dialogContext);
                            },
                            child: Text(tr('Clear', 'Limpar')),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              widget.favoritesOnly
                  ? tr('Your bookmarked codes', 'Os seus códigos favoritos')
                  : tr('Codes created and scanned on this device',
                      'Códigos criados e lidos neste dispositivo'),
              style: const TextStyle(color: StudioColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: tr('Search codes and content…',
                    'Pesquisar códigos e conteúdo…'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            if (!widget.favoritesOnly) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                      label: tr('All', 'Todos'),
                      selected: _filter == 'All',
                      onTap: () => setState(() => _filter = 'All')),
                  _FilterChip(
                      label: tr('Generated', 'Criados'),
                      selected: _filter == 'Generated',
                      onTap: () => setState(() => _filter = 'Generated')),
                  _FilterChip(
                      label: tr('Scanned', 'Lidos'),
                      selected: _filter == 'Scanned',
                      onTap: () => setState(() => _filter = 'Scanned')),
                ],
              ),
            ],
            const SizedBox(height: 15),
            if (items.isEmpty)
              StudioCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        size: 46, color: StudioColors.muted),
                    const SizedBox(height: 12),
                    Text(
                      tr('Nothing here yet', 'Ainda não há registos'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _query.isNotEmpty
                          ? tr('No results match your search.',
                              'Nenhum resultado corresponde à pesquisa.')
                          : widget.favoritesOnly
                              ? tr('Tap the heart on a record to keep it here.',
                                  'Toque no coração de um registo para o guardar aqui.')
                              : tr('Create or scan a code and it will appear here.',
                                  'Crie ou leia um código e ele aparecerá aqui.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: StudioColors.muted,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ],
                ),
              )
            else
              ...items.map((record) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _HistoryTile(
                      record: record,
                      portuguese: widget.portuguese,
                      languageCode: widget.languageCode,
                      onTap: () => _showDetails(record),
                      onFavorite: () => widget.onFavorite(record),
                      onDelete: () => widget.onDelete(record),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _content(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.favoritesOnly
            ? tr('Favorites', 'Favoritos')
            : tr('QR History', 'Histórico QR')),
      ),
      body: _content(context),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: StudioColors.purple,
      backgroundColor: Theme.of(context).cardTheme.color,
      side: BorderSide(
          color: selected ? StudioColors.purple : StudioColors.border),
      labelStyle: TextStyle(
          color: selected ? Colors.white : null,
          fontWeight: FontWeight.w700,
          fontSize: 12),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
    required this.portuguese,
    required this.languageCode,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  final CodeRecord record;
  final bool portuguese;
  final String languageCode;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scanned = record.type.toLowerCase().contains('scan') ||
        record.type.toLowerCase().contains('lido');
    final date =
        '${record.createdAt.day.toString().padLeft(2, '0')}/${record.createdAt.month.toString().padLeft(2, '0')}  •  ${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')}';
    return StudioCard(
      padding: const EdgeInsets.fromLTRB(12, 11, 7, 11),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: StudioColors.purple.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              scanned ? Icons.qr_code_scanner_rounded : Icons.qr_code_2_rounded,
              color: scanned ? StudioColors.green : StudioColors.purple,
              size: 25,
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
                        fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$date  •  ${record.type}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: StudioColors.muted, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onFavorite,
            icon: Icon(
              record.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: record.isFavorite
                  ? const Color(0xFFFF5F91)
                  : StudioColors.muted,
              size: 20,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(StudioLocalization.translate('Delete', 'Eliminar', languageCode)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
