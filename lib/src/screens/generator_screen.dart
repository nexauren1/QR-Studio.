import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/code_record.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({
    super.key,
    required this.portuguese,
    required this.onSaved,
  });

  final bool portuguese;
  final ValueChanged<CodeRecord> onSaved;

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _text = TextEditingController();
  final _ssid = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  String _kind = 'Text';
  String _security = 'WPA';
  String? _generated;
  bool _busy = false;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _text.dispose();
    _ssid.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  String _escapeWifi(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll(';', r'\;').replaceAll(',', r'\,');

  String? _buildPayload() {
    switch (_kind) {
      case 'URL':
        final value = _text.text.trim();
        if (value.isEmpty) return null;
        final withScheme =
            value.startsWith('http://') || value.startsWith('https://')
                ? value
                : 'https://$value';
        final uri = Uri.tryParse(withScheme);
        return uri != null && uri.hasAuthority ? withScheme : null;
      case 'Wi-Fi':
        if (_ssid.text.trim().isEmpty) return null;
        return 'WIFI:T:$_security;S:${_escapeWifi(_ssid.text.trim())};P:${_escapeWifi(_password.text)};;';
      case 'Contact':
        if (_name.text.trim().isEmpty &&
            _phone.text.trim().isEmpty &&
            _email.text.trim().isEmpty) {
          return null;
        }
        return 'MECARD:N:${_name.text.trim()};TEL:${_phone.text.trim()};EMAIL:${_email.text.trim()};;';
      default:
        return _text.text.trim().isEmpty ? null : _text.text.trim();
    }
  }

  void _generate() {
    final payload = _buildPayload();
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Add valid information first.',
              'Introduza informações válidas primeiro.'))));
      return;
    }
    setState(() => _generated = payload);
    widget.onSaved(CodeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      data: payload,
      type: _kind == 'URL'
          ? 'QR · URL'
          : _kind == 'Wi-Fi'
              ? 'QR · Wi-Fi'
              : _kind == 'Contact'
                  ? 'QR · Contact'
                  : 'QR · Text',
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _copy() async {
    final value = _generated;
    if (value == null) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('Content copied.', 'Conteúdo copiado.'))),
    );
  }

  Future<void> _exportPng() async {
    final value = _generated;
    if (value == null || _busy) return;
    setState(() => _busy = true);
    try {
      final painter = QrPainter(
        data: value,
        version: QrVersions.auto,
        gapless: false,
      );
      final imageData =
          await painter.toImageData(1200, format: ui.ImageByteFormat.png);
      if (imageData == null) throw Exception('QR image could not be rendered');
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/qr_studio_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageData.buffer.asUint8List(), flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: tr('Created with QR Studio by Nexauren',
            'Criado com QR Studio da Nexauren'),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('Could not export the QR image.',
                'Não foi possível exportar a imagem QR.'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : 3,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
      ),
      onChanged: (_) {
        if (_generated != null) setState(() => _generated = null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = ['Text', 'URL', 'Wi-Fi', 'Contact'];
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Generate QR Code', 'Gerar código QR'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Choose content type', 'Escolha o tipo de conteúdo'),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: types.map((type) {
                final selected = _kind == type;
                return ChoiceChip(
                  label: Text(type == 'Wi-Fi' ? 'Wi-Fi' : type),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _kind = type;
                    _generated = null;
                  }),
                  selectedColor: StudioColors.purple,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  side: BorderSide(
                      color: selected
                          ? StudioColors.purple
                          : StudioColors.border),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            StudioCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_kind == 'Text') ...[
                    _field(
                      label: tr('Text or data', 'Texto ou dados'),
                      controller: _text,
                      hint: tr('Enter your message…', 'Escreva a sua mensagem…'),
                    ),
                  ] else if (_kind == 'URL') ...[
                    _field(
                      label: 'URL',
                      controller: _text,
                      hint: 'https://example.com',
                      keyboardType: TextInputType.url,
                    ),
                  ] else if (_kind == 'Wi-Fi') ...[
                    _field(
                      label: tr('Network name (SSID)', 'Nome da rede (SSID)'),
                      controller: _ssid,
                      hint: 'Wi-Fi name',
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _security,
                      decoration: InputDecoration(
                          labelText: tr('Security', 'Segurança')),
                      items: const [
                        DropdownMenuItem(value: 'WPA', child: Text('WPA / WPA2')),
                        DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                        DropdownMenuItem(
                            value: 'nopass', child: Text('No password')),
                      ],
                      onChanged: (value) => setState(() {
                        _security = value ?? 'WPA';
                        _generated = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: tr('Password', 'Palavra-passe'),
                      controller: _password,
                      obscure: true,
                    ),
                  ] else ...[
                    _field(
                      label: tr('Full name', 'Nome completo'),
                      controller: _name,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: tr('Phone number', 'Número de telefone'),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                  const SizedBox(height: 16),
                  GradientButton(
                    label: tr('Generate QR', 'Gerar QR'),
                    icon: Icons.auto_awesome_rounded,
                    onPressed: _generate,
                  ),
                ],
              ),
            ),
            if (_generated != null) ...[
              const SizedBox(height: 22),
              SectionHeading(tr('Your QR code', 'O seu código QR')),
              const SizedBox(height: 10),
              StudioCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: QrImageView(
                        data: _generated!,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        gapless: false,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(tr('Ready to share', 'Pronto para partilhar'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 5),
                    Text(
                      _generated!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: StudioColors.muted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copy,
                            icon: const Icon(Icons.copy_rounded, size: 17),
                            label: Text(tr('Copy', 'Copiar')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            compact: true,
                            label: _busy
                                ? tr('Exporting…', 'A exportar…')
                                : tr('Export PNG', 'Exportar PNG'),
                            icon: Icons.download_rounded,
                            onPressed: _busy ? null : _exportPng,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              tr('Your codes are kept on this device. Export a PNG to save or share the image.',
                  'Os seus códigos ficam neste dispositivo. Exporte um PNG para guardar ou partilhar a imagem.'),
              style: const TextStyle(
                  color: StudioColors.muted, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
