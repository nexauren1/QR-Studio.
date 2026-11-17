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
  final _primary = TextEditingController();
  final _secondary = TextEditingController();
  final _tertiary = TextEditingController();
  final _fourth = TextEditingController();

  static const _foregrounds = <Color>[
    Color(0xFF090A16),
    Color(0xFF30205F),
    Color(0xFF4B20A8),
    Color(0xFF174AA6),
    Color(0xFF087C63),
    Color(0xFF8C2544),
  ];
  static const _backgrounds = <Color>[
    Colors.white,
    Color(0xFFF1EDFF),
    Color(0xFFEAF4FF),
    Color(0xFFFFF4E8),
  ];

  String _kind = 'Text';
  String _security = 'WPA';
  Color _foreground = const Color(0xFF090A16);
  Color _background = Colors.white;
  bool _roundedModules = false;
  String? _generated;
  bool _busy = false;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    _tertiary.dispose();
    _fourth.dispose();
    super.dispose();
  }

  String _escapeWifi(String value) => value
      .replaceAll(r'\\', r'\\\\')
      .replaceAll(';', r'\\;')
      .replaceAll(',', r'\\,');

  String? _buildPayload() {
    final first = _primary.text.trim();
    final second = _secondary.text.trim();
    final third = _tertiary.text.trim();
    switch (_kind) {
      case 'URL':
        if (first.isEmpty) return null;
        final value = first.startsWith('http://') ||
                first.startsWith('https://')
            ? first
            : 'https://$first';
        final uri = Uri.tryParse(value);
        return uri != null && uri.hasAuthority ? value : null;
      case 'Wi-Fi':
        if (first.isEmpty) return null;
        return 'WIFI:T:$_security;S:${_escapeWifi(first)};P:${_escapeWifi(second)};;';
      case 'Contact':
        if (first.isEmpty && second.isEmpty && third.isEmpty) return null;
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$first\nTEL:$second\nEMAIL:$third\nEND:VCARD';
      case 'Email':
        if (first.isEmpty || !first.contains('@')) return null;
        final query = <String, String>{};
        if (second.isNotEmpty) query['subject'] = second;
        if (third.isNotEmpty) query['body'] = third;
        return Uri(scheme: 'mailto', path: first, queryParameters: query.isEmpty ? null : query).toString();
      case 'Phone':
        if (first.isEmpty) return null;
        return 'tel:$first';
      case 'SMS':
        if (first.isEmpty) return null;
        return 'SMSTO:$first:$second';
      case 'Location':
        final latitude = double.tryParse(first);
        final longitude = double.tryParse(second);
        if (latitude == null ||
            longitude == null ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180) {
          return null;
        }
        return 'geo:$latitude,$longitude?q=$latitude,$longitude';
      default:
        return first.isEmpty ? null : first;
    }
  }

  void _generate() {
    final payload = _buildPayload();
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr(
              'Check the required fields and try again.',
              'Verifique os campos obrigatórios e tente novamente.'))));
      return;
    }
    setState(() => _generated = payload);
    widget.onSaved(CodeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      data: payload,
      type: 'QR · $_kind',
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
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        emptyColor: _background,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: _foreground,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: _roundedModules
              ? QrDataModuleShape.circle
              : QrDataModuleShape.square,
          color: _foreground,
        ),
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
    } catch (_) {
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      onChanged: (_) {
        if (_generated != null) setState(() => _generated = null);
      },
    );
  }

  List<Widget> _formFields() {
    switch (_kind) {
      case 'Text':
        return [
          _field(
            label: tr('Text or data', 'Texto ou dados'),
            controller: _primary,
            hint: tr('Enter your message…', 'Escreva a sua mensagem…'),
            maxLines: 4,
          ),
        ];
      case 'URL':
        return [
          _field(
            label: 'URL',
            controller: _primary,
            hint: 'https://example.com',
            keyboardType: TextInputType.url,
          ),
        ];
      case 'Wi-Fi':
        return [
          _field(
            label: tr('Network name (SSID)', 'Nome da rede (SSID)'),
            controller: _primary,
            hint: 'Wi-Fi name',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _security,
            decoration: InputDecoration(labelText: tr('Security', 'Segurança')),
            items: const [
              DropdownMenuItem(value: 'WPA', child: Text('WPA / WPA2')),
              DropdownMenuItem(value: 'WEP', child: Text('WEP')),
              DropdownMenuItem(value: 'nopass', child: Text('No password')),
            ],
            onChanged: (value) => setState(() {
              _security = value ?? 'WPA';
              _generated = null;
            }),
          ),
          const SizedBox(height: 12),
          _field(
            label: tr('Password', 'Palavra-passe'),
            controller: _secondary,
          ),
        ];
      case 'Contact':
        return [
          _field(label: tr('Full name', 'Nome completo'), controller: _primary),
          const SizedBox(height: 12),
          _field(
            label: tr('Phone number', 'Número de telefone'),
            controller: _secondary,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _field(
            label: 'Email',
            controller: _tertiary,
            keyboardType: TextInputType.emailAddress,
          ),
        ];
      case 'Email':
        return [
          _field(
            label: tr('Recipient email', 'Email do destinatário'),
            controller: _primary,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(label: tr('Subject', 'Assunto'), controller: _secondary),
          const SizedBox(height: 12),
          _field(
            label: tr('Message', 'Mensagem'),
            controller: _tertiary,
            maxLines: 3,
          ),
        ];
      case 'Phone':
        return [
          _field(
            label: tr('Phone number', 'Número de telefone'),
            controller: _primary,
            keyboardType: TextInputType.phone,
            hint: '+258…',
          ),
        ];
      case 'SMS':
        return [
          _field(
            label: tr('Phone number', 'Número de telefone'),
            controller: _primary,
            keyboardType: TextInputType.phone,
            hint: '+258…',
          ),
          const SizedBox(height: 12),
          _field(
            label: tr('Pre-filled message', 'Mensagem pré-preenchida'),
            controller: _secondary,
            maxLines: 3,
          ),
        ];
      case 'Location':
        return [
          _field(
            label: tr('Latitude', 'Latitude'),
            controller: _primary,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            hint: '-25.9692',
          ),
          const SizedBox(height: 12),
          _field(
            label: tr('Longitude', 'Longitude'),
            controller: _secondary,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            hint: '32.5732',
          ),
          const SizedBox(height: 6),
          Text(
            tr('Enter coordinates between -90 to 90 and -180 to 180.',
                'Introduza coordenadas entre -90 e 90 e -180 e 180.'),
            style: const TextStyle(color: StudioColors.muted, fontSize: 11),
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _colorPicker({
    required String title,
    required List<Color> colors,
    required Color selected,
    required ValueChanged<Color> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: colors.map((color) {
            final active = selected.toARGB32() == color.toARGB32();
            return InkWell(
              onTap: () {
                onSelected(color);
                setState(() => _generated = _generated);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? StudioColors.cyan : StudioColors.border,
                    width: active ? 3 : 1,
                  ),
                ),
                child: active
                    ? Icon(Icons.check_rounded,
                        size: 16,
                        color: color.computeLuminance() > .5
                            ? Colors.black
                            : Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const types = [
      'Text',
      'URL',
      'Wi-Fi',
      'Contact',
      'Email',
      'Phone',
      'SMS',
      'Location',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Generate QR Code', 'Gerar código QR'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _foreground = _foregrounds.first;
              _background = Colors.white;
              _roundedModules = false;
            }),
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: tr('Reset design', 'Repor design'),
          ),
        ],
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
                  label: Text(type),
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
                  ..._formFields(),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(tr('QR design', 'Design do QR'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 14),
                  _colorPicker(
                    title: tr('Code colour', 'Cor do código'),
                    colors: _foregrounds,
                    selected: _foreground,
                    onSelected: (value) =>
                        setState(() => _foreground = value),
                  ),
                  const SizedBox(height: 14),
                  _colorPicker(
                    title: tr('Background colour', 'Cor de fundo'),
                    colors: _backgrounds,
                    selected: _background,
                    onSelected: (value) =>
                        setState(() => _background = value),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _roundedModules,
                    onChanged: (value) =>
                        setState(() => _roundedModules = value),
                    title: Text(tr('Rounded QR dots', 'Pontos QR arredondados'),
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(tr('Change the code texture',
                        'Alterar a textura do código')),
                  ),
                  const SizedBox(height: 8),
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
                        color: _background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: QrImageView(
                        data: _generated!,
                        version: QrVersions.auto,
                        size: 230,
                        backgroundColor: _background,
                        gapless: false,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: _foreground,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: _roundedModules
                              ? QrDataModuleShape.circle
                              : QrDataModuleShape.square,
                          color: _foreground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
                            label: Text(tr('Copy data', 'Copiar dados')),
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
              tr(
                'QR Studio uses high error correction for reliable scanning. Your codes and settings stay on this device.',
                'O QR Studio utiliza correção de erros elevada para facilitar a leitura. Os seus códigos e definições ficam neste dispositivo.',
              ),
              style: const TextStyle(
                  color: StudioColors.muted, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
