import 'package:flutter/material.dart';

import '../services/studio_localization.dart';
import '../theme/studio_theme.dart';
import '../widgets/studio_components.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.portuguese,
    required this.languageCode,
    required this.darkMode,
    required this.onGenerate,
    required this.onScan,
    required this.onBarcode,
    required this.onBulk,
    required this.onHistory,
    required this.onAnalyze,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  final bool portuguese;
  final String languageCode;
  final bool darkMode;
  final VoidCallback onGenerate;
  final VoidCallback onScan;
  final VoidCallback onBarcode;
  final VoidCallback onBulk;
  final VoidCallback onHistory;
  final VoidCallback onAnalyze;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onLanguageChanged;

  String tr(String en, String pt) => StudioLocalization.translate(en, pt, languageCode);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Tools & Settings', 'Ferramentas e definições'),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(
              tr('Everything you need in one place.',
                  'Tudo o que precisa num só lugar.'),
              style: const TextStyle(color: StudioColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SectionHeading(tr('QR tools', 'Ferramentas QR')),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.27,
              children: [
                ToolTile(
                  title: tr('QR Generator', 'Gerador QR'),
                  subtitle: tr('Create custom QR codes', 'Criar códigos QR'),
                  icon: Icons.qr_code_2_rounded,
                  color: const Color(0xFF5C7CFF),
                  onTap: onGenerate,
                ),
                ToolTile(
                  title: tr('QR Scanner', 'Leitor QR'),
                  subtitle: tr('Camera and gallery', 'Câmara e galeria'),
                  icon: Icons.qr_code_scanner_rounded,
                  color: StudioColors.green,
                  onTap: onScan,
                ),
                ToolTile(
                  title: tr('Barcode Generator', 'Gerador de barras'),
                  subtitle: tr('Code 128 format', 'Formato Code 128'),
                  icon: Icons.view_week_rounded,
                  color: StudioColors.orange,
                  onTap: onBarcode,
                ),
                ToolTile(
                  title: tr('Bulk QR Generator', 'Gerador QR em lote'),
                  subtitle: tr('Create up to 50 codes', 'Criar até 50 códigos'),
                  icon: Icons.auto_awesome_mosaic_rounded,
                  color: const Color(0xFF8C6CFF),
                  onTap: onBulk,
                ),
                ToolTile(
                  title: tr('History', 'Histórico'),
                  subtitle: tr('Created and scanned codes', 'Códigos criados e lidos'),
                  icon: Icons.history_rounded,
                  color: const Color(0xFFB56CFF),
                  onTap: onHistory,
                ),
                ToolTile(
                  title: tr('QR Analyzer', 'Analisador QR'),
                  subtitle: tr('Inspect QR content and links', 'Analisar conteúdo e ligações'),
                  icon: Icons.manage_search_rounded,
                  color: StudioColors.cyan,
                  onTap: onAnalyze,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeading(tr('Preferences', 'Preferências')),
            const SizedBox(height: 10),
            StudioCard(
              padding: const EdgeInsets.fromLTRB(15, 6, 15, 6),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: darkMode,
                    onChanged: onThemeChanged,
                    secondary: Icon(
                      darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: StudioColors.purple,
                    ),
                    title: Text(tr('Dark appearance', 'Aparência escura'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(tr('Use the dark interface',
                        'Utilizar a interface escura')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language_rounded,
                        color: StudioColors.cyan),
                    title: Text(tr('Language', 'Idioma'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(StudioLocalization.languageName(languageCode)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (sheetContext) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final language in StudioLocalization.languages)
                                ListTile(
                                  leading: Text(language.flag),
                                  title: Text(language.label),
                                  trailing: languageCode == language.code
                                      ? const Icon(Icons.check_circle,
                                          color: StudioColors.purple)
                                      : null,
                                  onTap: () {
                                    onLanguageChanged(language.code);
                                    Navigator.pop(sheetContext);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            StudioCard(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StudioLogo(size: 38),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('QR Studio',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 3),
                            Text('Nexauren  •  Version 1.0.0',
                                style: TextStyle(
                                    color: StudioColors.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      'Your codes and preferences are stored locally on this device. QR Studio does not require an account.',
                      'Os seus códigos e preferências são guardados localmente neste dispositivo. O QR Studio não exige uma conta.',
                    ),
                    style: const TextStyle(
                        color: StudioColors.muted, fontSize: 11, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => showAboutDialog(
                      context: context,
                      applicationName: 'QR Studio',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© Nexauren',
                      children: [
                        Text(tr(
                          'Create, scan and share QR codes and barcodes. Your local history stays on this device.',
                          'Crie, leia e partilhe códigos QR e códigos de barras. O histórico local fica neste dispositivo.',
                        )),
                      ],
                    ),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: Text(tr('About QR Studio', 'Sobre o QR Studio')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Text('NEXAUREN',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
