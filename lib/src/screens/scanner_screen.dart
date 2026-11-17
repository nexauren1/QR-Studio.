import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/code_record.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.portuguese,
    required this.onSaved,
  });

  final bool portuguese;
  final ValueChanged<CodeRecord> onSaved;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: true,
    autoZoom: true,
  );
  bool _handling = false;
  bool _torchOn = false;
  bool _imageBusy = false;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.start());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.stop());
    }
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_handling) return;
    final barcode = capture.barcodes.firstWhere(
      (item) => item.rawValue != null && item.rawValue!.isNotEmpty,
      orElse: () => Barcode(rawValue: null),
    );
    final value = barcode.rawValue;
    if (value == null || value.isEmpty) return;
    await HapticFeedback.selectionClick();
    await _showResult(value, barcode.format.name);
  }

  bool _isActionableLink(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        ['http', 'https', 'mailto', 'tel'].contains(uri.scheme.toLowerCase());
  }

  Future<void> _showResult(String value, String format) async {
    if (_handling || !mounted) return;
    _handling = true;
    await _controller.stop();
    if (!mounted) return;
    final uri = Uri.tryParse(value);
    final canOpen = _isActionableLink(value) && uri != null;
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 5, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: StudioColors.green),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(tr('Code detected', 'Código detetado'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                ),
                Text(format.toUpperCase(),
                    style: const TextStyle(
                        color: StudioColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 14),
            SelectableText(value,
                style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext, 'copied');
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(tr('Copy', 'Copiar')),
                ),
                if (canOpen)
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, 'open'),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(tr('Open', 'Abrir')),
                  ),
                GradientButton(
                  compact: true,
                  label: tr('Save to history', 'Guardar no histórico'),
                  icon: Icons.bookmark_add_rounded,
                  onPressed: () => Navigator.pop(sheetContext, 'save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (action == 'save') {
      widget.onSaved(CodeRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        data: value,
        type: 'Scanned · $format',
        createdAt: DateTime.now(),
      ));
    } else if (action == 'open' && uri != null) {
      try {
        await launchUrl(
          uri,
          mode: uri.scheme == 'http' || uri.scheme == 'https'
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(tr('Could not open this result.',
                  'Não foi possível abrir este resultado.'))));
        }
      }
    } else if (action == 'copied' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Value copied.', 'Valor copiado.'))));
    }

    _handling = false;
    if (mounted) await _controller.start();
  }

  Future<void> _pickImage() async {
    if (_imageBusy || _handling) return;
    try {
      await _controller.stop();
      final image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (image == null) {
        await _controller.start();
        return;
      }
      setState(() => _imageBusy = true);
      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;
      setState(() => _imageBusy = false);
      final barcode = capture?.barcodes.firstWhere(
        (item) => item.rawValue != null && item.rawValue!.isNotEmpty,
        orElse: () => Barcode(rawValue: null),
      );
      final value = barcode?.rawValue;
      if (value == null || value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('No code found in this image.',
                'Não foi encontrado nenhum código nesta imagem.'))));
        await _controller.start();
      } else {
        await _showResult(value, barcode!.format.name);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('Could not read this image.',
                'Não foi possível ler esta imagem.'))));
        await _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(tr('Scan QR & Barcodes', 'Ler QR e códigos de barras'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () async {
              await _controller.toggleTorch();
              if (mounted) setState(() => _torchOn = !_torchOn);
            },
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: tr('Toggle flashlight', 'Ligar/desligar flash'),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
            tooltip: tr('Switch camera', 'Mudar câmara'),
          ),
        ],
      ),
      body: StudioProcessingOverlay(
        active: _imageBusy,
        title: tr('Analysing image', 'A analisar imagem'),
        message: tr(
          'Looking for QR codes and supported barcodes…',
          'A procurar códigos QR e códigos de barras compatíveis…',
        ),
        child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          IgnorePointer(
            child: Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(painter: _ScanFramePainter()),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              children: [
                Text(
                  tr('Align a QR code or barcode inside the frame',
                      'Alinhe um código QR ou de barras dentro da moldura'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.camera_alt_rounded,
                        color: StudioColors.green, size: 17),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        tr('Live camera scanner', 'Leitor de câmara ativo'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(tr('Gallery', 'Galeria')),
                      style: FilledButton.styleFrom(
                          backgroundColor: StudioColors.purple,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 38.0;
    final corners = [
      [Offset.zero, const Offset(length, 0), const Offset(0, length)],
      [Offset(size.width, 0), const Offset(-length, 0), const Offset(0, length)],
      [Offset(0, size.height), const Offset(length, 0), const Offset(0, -length)],
      [
        Offset(size.width, size.height),
        const Offset(-length, 0),
        const Offset(0, -length)
      ],
    ];
    for (final corner in corners) {
      final origin = corner[0];
      canvas.drawLine(origin, origin + corner[1], paint);
      canvas.drawLine(origin, origin + corner[2], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
