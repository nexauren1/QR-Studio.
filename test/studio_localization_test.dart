import 'package:flutter_test/flutter_test.dart';
import 'package:qr_studio/src/services/studio_localization.dart';

void main() {
  group('StudioLocalization', () {
    test('exposes exactly five supported languages', () {
      expect(
        StudioLocalization.languages.map((language) => language.code).toList(),
        ['pt', 'en', 'es', 'fr', 'de'],
      );
    });

    test('translates core navigation labels offline', () {
      expect(StudioLocalization.translate('Home', 'Início', 'pt'), 'Início');
      expect(StudioLocalization.translate('Home', 'Início', 'en'), 'Home');
      expect(StudioLocalization.translate('Home', 'Início', 'es'), 'Inicio');
      expect(StudioLocalization.translate('Home', 'Início', 'fr'), 'Accueil');
      expect(StudioLocalization.translate('Home', 'Início', 'de'), 'Startseite');
    });

    test('shows language names in the settings selector', () {
      expect(StudioLocalization.languageName('pt'), 'Português');
      expect(StudioLocalization.languageName('en'), 'English');
      expect(StudioLocalization.languageName('es'), 'Español');
      expect(StudioLocalization.languageName('fr'), 'Français');
      expect(StudioLocalization.languageName('de'), 'Deutsch');
    });

    test('falls back to English for uncatalogued phrases', () {
      expect(
        StudioLocalization.translate('Uncatalogued phrase', 'Frase', 'es'),
        'Uncatalogued phrase',
      );
    });
  });
}
