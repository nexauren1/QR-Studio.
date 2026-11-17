import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';

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
  String _format = 'Code 128';
  String? _value;
  bool _sharing = false;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  Barcode get _barcode {
    switch (_format) {
      case 'Code 39':
        return Barcode.code39();
      case 'EAN-13':
        return Barcode.ean13();
      case 'EAN-8':
        return Barcode.ean8();
      case 'UPC-A':
        return Barcode.upcA();
      default:
        return Barcode.code128();
    }
  }

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
    if (!_barcode.isValid(value)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr(
          'This value is not valid for $_format. Check its length and characters.',
          'Este valor não é válido para $_format. Verifique o comprimento e os caracteres.',
        )),
      ));
      return;
    }
    setState(() => _value = value);
    widget.onSaved(CodeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      data: value,
      type: 'Barcode · $_format',
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _shareSvg() async {
    final value = _value;
    if (value == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      final svg = _barcode.toSvg(
        value,
        width: 1000,
        height: 320,
        drawText: true,
      );
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/qr_studio_barcode_${DateTime.now().millisecondsSinceEpoch}.svg',
      );
      await file.writeAsString(svg, encoding: utf8, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/svg+xml')],
        text: tr('Created with QR Studio by Nexauren',
            'Criado com QR Studio da Nexauren'),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(tr('Could not export the barcode.', 'Falha ao exportar o código.'))));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const formats = ['Code 128', 'Code 39', 'EAN-13', 'EAN-8', 'UPC-A'];
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
            Text(tr('Barcode generator', 'Gerador de códigos de barras'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(
              tr('Choose a format for products, stock labels and references.',
                  'Escolha um formato para produtos, etiquetas de stock e referências.'),
              style: const TextStyle(color: StudioColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: formats.map((format) {
                final selected = _format == format;
                return ChoiceChip(
                  label: Text(format),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _format = format;
                    _value = null;
                  }),
                  selectedColor: StudioColors.purple,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  side: BorderSide(
                      color: selected
                          ? StudioColors.purple
                          : StudioColors.border),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w700),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            StudioCard(
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: tr('Barcode content', 'Conteúdo do código'),
                      hintText: _format == 'EAN-13'
                          ? '5901234123457'
                          : 'ABC-123456',
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
              SectionHeading(tr('Your barcode', 'O seu código de barras')),
              const SizedBox(height: 10),
              StudioCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: BarcodeWidget(
                        barcode: _barcode,
                        data: _value!,
                        width: 280,
                        height: 115,
                        drawText: true,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12),
                        errorBuilder: (context, error) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(_value!,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: _value!));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(tr(
                                          'Content copied.',
                                          'Conteúdo copiado.'))));
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: Text(tr('Copy value', 'Copiar valor')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            compact: true,
                            onPressed: _sharing ? null : _shareSvg,
                            icon: Icons.share_rounded,
                            label: _sharing
                                ? tr('Preparing…', 'A preparar…')
                                : tr('Export SVG', 'Exportar SVG'),
                          ),
                        ),
                      ],
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
