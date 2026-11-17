import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: true,
  );
  bool _handling = false;
  bool _torchOn = false;

  String tr(String en, String pt) => widget.portuguese ? pt : en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_handling) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (code == null) return;
    await _showResult(code, 'Scanned QR / Barcode');
  }

  Future<void> _showResult(String value, String type) async {
    if (_handling || !mounted) return;
    _handling = true;
    await _controller.stop();
    if (!mounted) return;
    final save = await showModalBottomSheet<bool>(
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
                Text(tr('Code detected', 'Código detetado'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            SelectableText(value,
                style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      if (sheetContext.mounted) Navigator.pop(sheetContext, false);
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(tr('Copy', 'Copiar')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: tr('Save to history', 'Guardar no histórico'),
                    icon: Icons.bookmark_add_rounded,
                    onPressed: () => Navigator.pop(sheetContext, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (save == true) {
      widget.onSaved(CodeRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        data: value,
        type: type,
        createdAt: DateTime.now(),
      ));
    }
    _handling = false;
    if (mounted) await _controller.start();
  }

  Future<void> _pickImage() async {
    try {
      await _controller.stop();
      final image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (image == null) {
        await _controller.start();
        return;
      }
      final capture = await _controller.analyzeImage(image.path);
      final value = capture?.barcodes
          .map((barcode) => barcode.rawValue)
          .firstWhere((item) => item != null && item.isNotEmpty,
              orElse: () => null);
      if (value == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(tr('No code found in this image.',
                  'Não foi encontrado nenhum código nesta imagem.'))));
          await _controller.start();
        }
      } else {
        await _showResult(value, 'Scanned from image');
      }
    } catch (_) {
      if (mounted) {
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
        title: Text(tr('Scan QR Code', 'Ler código QR'),
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
      body: Stack(
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
            left: 28,
            right: 28,
            bottom: 28,
            child: Column(
              children: [
                Text(
                  tr('Point the camera at a QR code or barcode',
                      'Aponte a câmara para um código QR ou código de barras'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text(tr('Camera', 'Câmara')),
                        style: FilledButton.styleFrom(
                            backgroundColor: StudioColors.purple,
                            foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: Text(tr('Gallery', 'Galeria')),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xE61A1D39),
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
