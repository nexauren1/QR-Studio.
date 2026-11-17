import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/code_record.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class BulkGeneratorScreen extends StatefulWidget {
  const BulkGeneratorScreen({
    super.key,
    required this.portuguese,
    required this.onSaved,
  });

  final bool portuguese;
  final ValueChanged<List<CodeRecord>> onSaved;

  @override
  State<BulkGeneratorScreen> createState() => _BulkGeneratorScreenState();
}

class _BulkGeneratorScreenState extends State<BulkGeneratorScreen> {
  final _controller = TextEditingController();
  List<String> _values = [];
  bool _busy = false;
  int _duplicatesRemoved = 0;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    final unique = <String>{};
    var duplicatesRemoved = 0;
    for (final line in _controller.text.split(RegExp(r'[\r\n]+'))) {
      final value = line.trim();
      if (value.isEmpty) continue;
      if (!unique.add(value)) duplicatesRemoved++;
      if (unique.length >= 50) break;
    }
    if (unique.isEmpty) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Add one item per line.', 'Introduza um item por linha.'))));
      return;
    }
    final values = unique.toList();
    setState(() {
      _values = values;
      _duplicatesRemoved = duplicatesRemoved;
      _busy = false;
    });
    final now = DateTime.now();
    widget.onSaved(values
        .map((value) => CodeRecord(
              id: '${now.microsecondsSinceEpoch}_${values.indexOf(value)}',
              data: value,
              type: 'QR · Bulk',
              createdAt: now,
            ))
        .toList());
  }

  Future<void> _shareList() async {
    if (_values.isEmpty) return;
    await Share.share(
      _values.join('\n'),
      subject: tr('QR Studio bulk list', 'Lista QR Studio'),
    );
  }

  Future<void> _exportCsv() async {
    if (_values.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      String csvCell(String value) =>
          '"' + value.replaceAll('"', '""') + '"';
      final rows = <List<String>>[
        <String>['Number', 'QR content'],
        for (var index = 0; index < _values.length; index++)
          <String>[(index + 1).toString(), _values[index]],
      ];
      final csv = rows
          .map((row) => row.map(csvCell).join(','))
          .join('\r\n');
      final directory = await getTemporaryDirectory();
      final file = File(
        directory.path +
            '/qr_studio_batch_' +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.csv',
      );
      await file.writeAsString(csv, encoding: utf8, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        text: tr('QR Studio batch export', 'Exportação em lote do QR Studio'),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(
            'Could not export the CSV file.',
            'Não foi possível exportar o ficheiro CSV.',
          )),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Bulk QR Generator', 'Gerador QR em lote'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StudioProcessingOverlay(
        active: _busy,
        title: tr('Building QR batch', 'A criar lote QR'),
        message: tr(
          'Preparing your unique entries and generating previews…',
          'A preparar entradas únicas e a gerar pré-visualizações…',
        ),
        child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudioCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35156E), Color(0xFF182D75)],
                    ),
                    borderColor: Colors.transparent,
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_mosaic_rounded,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            tr(
                              'Create up to 50 QR codes in one batch. Put each value on a new line.',
                              'Crie até 50 códigos QR de uma só vez. Coloque cada valor numa linha nova.',
                            ),
                            style: const TextStyle(
                                color: Colors.white,
                                height: 1.45,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(tr('Your list', 'A sua lista'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _controller,
                    minLines: 6,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText:
                          'https://example.com\nWi-Fi Guest\nMy product 001\nHello world',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) => setState(() {
                      _values = [];
                      _duplicatesRemoved = 0;
                    }),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: _busy
                        ? tr('Preparing…', 'A preparar…')
                        : tr('Generate batch', 'Gerar lote'),
                    icon: Icons.qr_code_2_rounded,
                    onPressed: _busy ? null : _generate,
                  ),
                  if (_values.isNotEmpty) ...[
                    const SizedBox(height: 23),
                    SectionHeading(
                      tr('${_values.length} codes created', '${_values.length} códigos criados'),
                      action: tr('Export CSV', 'Exportar CSV'),
                      onAction: _exportCsv,
                    ),
                    if (_duplicatesRemoved > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Text(
                          _duplicatesRemoved.toString() +
                              tr(' duplicate entries ignored', ' entradas repetidas ignoradas'),
                          style: const TextStyle(
                            color: StudioColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _shareList,
                        icon: const Icon(Icons.share_rounded, size: 17),
                        label: Text(tr('Share values as text', 'Partilhar valores em texto')),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      itemCount: _values.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: .9,
                      ),
                      itemBuilder: (context, index) {
                        final value = _values[index];
                        return StudioCard(
                          padding: const EdgeInsets.all(10),
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: value));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(tr(
                                        'Value copied.', 'Valor copiado.'))));
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: QrImageView(
                                    data: value,
                                    backgroundColor: Colors.white,
                                    size: 110,
                                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                value,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr(
                        'All codes were added to your local history.',
                        'Todos os códigos foram adicionados ao histórico local.',
                      ),
                      style: const TextStyle(
                          color: StudioColors.muted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
