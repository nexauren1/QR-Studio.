import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/qr_content_analyzer.dart';
import '../services/studio_localization.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class QrAnalyzerScreen extends StatefulWidget {
  const QrAnalyzerScreen({super.key, required this.portuguese, required this.languageCode});

  final bool portuguese;
  final String languageCode;

  @override
  State<QrAnalyzerScreen> createState() => _QrAnalyzerScreenState();
}

class _QrAnalyzerScreenState extends State<QrAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  QrAnalysisResult? _result;
  bool _opening = false;

  String tr(String en, String pt) => StudioLocalization.translate(en, pt, widget.languageCode);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final value = data?.text?.trim() ?? '';
    if (value.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('The clipboard is empty.', 'A área de transferência está vazia.')),
      ));
      return;
    }
    _controller.text = value;
    _analyze();
  }

  void _analyze() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('Paste or enter QR content first.', 'Cole ou introduza primeiro o conteúdo QR.')),
      ));
      return;
    }
    setState(() => _result = QrContentAnalyzer.analyze(value));
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _controller.text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(tr('Content copied.', 'Conteúdo copiado.')),
    ));
  }

  Future<void> _openAction() async {
    final uri = _result?.actionUri;
    if (uri == null || _opening) return;
    setState(() => _opening = true);
    try {
      final opened = await launchUrl(
        uri,
        mode: <String>{'http', 'https'}.contains(uri.scheme)
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('No app could handle this action.', 'Nenhuma aplicação conseguiu executar esta ação.')),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Could not open this content.', 'Não foi possível abrir este conteúdo.')),
        ));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('QR Analyzer', 'Analisador QR'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudioCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF35156E), Color(0xFF183A78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: Colors.transparent,
              child: Row(
                children: [
                  const Icon(Icons.manage_search_rounded, color: Colors.white, size: 38),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      tr(
                        'Inspect QR content before opening it. Identify links, Wi-Fi details, contacts and more.',
                        'Analise o conteúdo antes de o abrir. Identifique links, Wi-Fi, contactos e muito mais.',
                      ),
                      style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeading(tr('Content to inspect', 'Conteúdo para analisar')),
            const SizedBox(height: 9),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 9,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                hintText: tr('Paste a QR result or enter its raw content…', 'Cole o resultado de um QR ou introduza o conteúdo…'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 76),
                  child: Icon(Icons.qr_code_2_rounded),
                ),
              ),
              onChanged: (_) => setState(() => _result = null),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _paste,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: Text(tr('Paste', 'Colar')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    label: tr('Analyze content', 'Analisar conteúdo'),
                    icon: Icons.analytics_rounded,
                    onPressed: _analyze,
                  ),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 24),
              SectionHeading(tr('Analysis result', 'Resultado da análise')),
              const SizedBox(height: 10),
              StudioCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: StudioColors.cyan.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.verified_rounded, color: StudioColors.cyan),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(result.type,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(result.summary,
                                  style: const TextStyle(color: StudioColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (result.details.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      const Divider(),
                      ...result.details.entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 104,
                                  child: Text(entry.key,
                                      style: const TextStyle(color: StudioColors.muted, fontSize: 11)),
                                ),
                                Expanded(
                                  child: SelectableText(entry.value,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          )),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _copy,
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(tr('Copy content', 'Copiar conteúdo')),
                        ),
                        if (result.actionUri != null)
                          FilledButton.icon(
                            onPressed: _opening ? null : _openAction,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: Text(_opening
                                ? tr('Opening…', 'A abrir…')
                                : tr('Open action', 'Executar ação')),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            StudioCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: StudioColors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr(
                        'Nothing opens automatically. Review the detected content and choose whether to open it.',
                        'Nada é aberto automaticamente. Reveja o conteúdo identificado e escolha se pretende abri-lo.',
                      ),
                      style: const TextStyle(color: StudioColors.muted, fontSize: 11, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
