import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

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

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final unique = <String>{};
    for (final line in _controller.text.split(RegExp(r'[\r\n]+'))) {
      final value = line.trim();
      if (value.isNotEmpty) unique.add(value);
      if (unique.length >= 50) break;
    }
    if (unique.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Add one item per line.', 'Introduza um item por linha.'))));
      return;
    }
    final values = unique.toList();
    setState(() => _values = values);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Bulk QR Generator', 'Gerador QR em lote'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
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
                    onChanged: (_) => setState(() => _values = []),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: tr('Generate batch', 'Gerar lote'),
                    icon: Icons.qr_code_2_rounded,
                    onPressed: _generate,
                  ),
                  if (_values.isNotEmpty) ...[
                    const SizedBox(height: 23),
                    SectionHeading(
                      tr('${_values.length} codes created', '${_values.length} códigos criados'),
                      action: tr('Share list', 'Partilhar lista'),
                      onAction: _shareList,
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
      ),
    );
  }
}
