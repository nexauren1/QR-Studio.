import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../models/code_record.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({
    super.key,
    required this.portuguese,
    required this.onSaved,
  });

  final bool portuguese;
  final ValueChanged<CodeRecord> onSaved;

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final _controller = TextEditingController();
  String? _value;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generate() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Enter a value first.', 'Introduza um valor.'))));
      return;
    }
    setState(() => _value = value);
    widget.onSaved(CodeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      data: value,
      type: 'Barcode · Code 128',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Create Barcode', 'Criar código de barras'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Code 128 generator', 'Gerador Code 128'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(
              tr('Create a linear barcode from letters or numbers.',
                  'Crie um código de barras linear a partir de letras ou números.'),
              style: const TextStyle(color: StudioColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 17),
            StudioCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: tr('Barcode content', 'Conteúdo do código'),
                      hintText: 'ABC-123456',
                    ),
                    onChanged: (_) => setState(() => _value = null),
                  ),
                  const SizedBox(height: 14),
                  GradientButton(
                    label: tr('Generate Barcode', 'Gerar código de barras'),
                    icon: Icons.view_week_rounded,
                    onPressed: _generate,
                  ),
                ],
              ),
            ),
            if (_value != null) ...[
              const SizedBox(height: 20),
              StudioCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: _value!,
                        width: 270,
                        height: 110,
                        drawText: true,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(_value!,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _value!));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                tr('Content copied.', 'Conteúdo copiado.'))));
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(tr('Copy value', 'Copiar valor')),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
