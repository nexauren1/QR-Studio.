import 'package:flutter/material.dart';

class StudioLanguage {
  const StudioLanguage({required this.code, required this.label, required this.flag});
  final String code;
  final String label;
  final String flag;
}

class StudioLocalization {
  static const languages = <StudioLanguage>[
    StudioLanguage(code: 'pt', label: 'Português', flag: '🇵🇹'),
    StudioLanguage(code: 'en', label: 'English', flag: '🇬🇧'),
    StudioLanguage(code: 'es', label: 'Español', flag: '🇪🇸'),
    StudioLanguage(code: 'fr', label: 'Français', flag: '🇫🇷'),
    StudioLanguage(code: 'de', label: 'Deutsch', flag: '🇩🇪'),
  ];

  static const supportedLocales = <Locale>[
    Locale('pt'), Locale('en'), Locale('es'), Locale('fr'), Locale('de'),
  ];

  static const Map<String, Map<String, String>> _translations = {
    'es': {
      'Home':'Inicio','Favorites':'Favoritos','More':'Más','Favorite':'Favorito',
      'Done':'Hecho','Open menu':'Abrir menú','Smart QR Tools':'Herramientas QR inteligentes',
      'Generate, scan and share in seconds.':'Genera, escanea y comparte en segundos.',
      'Explore tools':'Explorar herramientas','Quick actions':'Acciones rápidas',
      'Generate QR Code':'Generar código QR','Text, URL, Wi-Fi, contact':'Texto, URL, Wi-Fi, contacto',
      'Scan QR Code':'Escanear código QR','Use camera or gallery':'Usa la cámara o la galería',
      'QR History':'Historial QR','Your recent activity':'Tu actividad reciente',
      'Create Barcode':'Crear código de barras','Generate Code 128':'Generar Code 128',
      'All tools':'Todas las herramientas','Discover QR Studio':'Descubre QR Studio',
      'Bulk QR Generator':'Generador QR por lotes','Create up to 50 codes':'Crea hasta 50 códigos',
      'QR Analyzer':'Analizador QR','Inspect QR content and links':'Revisa el contenido y los enlaces QR',
      'Settings':'Ajustes','Language and appearance':'Idioma y apariencia',
      'Recent activity':'Actividad reciente','See all':'Ver todo',
      'Tools & Settings':'Herramientas y ajustes','Everything you need in one place.':'Todo lo que necesitas en un solo lugar.',
      'QR tools':'Herramientas QR','QR Generator':'Generador QR','Create custom QR codes':'Crea códigos QR personalizados',
      'QR Scanner':'Lector QR','Camera and gallery':'Cámara y galería','Barcode Generator':'Generador de códigos de barras',
      'Code 128 format':'Formato Code 128','History':'Historial','Created and scanned codes':'Códigos creados y escaneados',
      'Preferences':'Preferencias','Dark appearance':'Apariencia oscura','Use the dark interface':'Usar la interfaz oscura',
      'Language':'Idioma','About QR Studio':'Acerca de QR Studio','Copy':'Copiar','Open':'Abrir',
      'Clear history':'Borrar historial','Clear history?':'¿Borrar el historial?','Cancel':'Cancelar',
      'Clear':'Borrar','All':'Todos','Generated':'Generados','Scanned':'Escaneados',
      'Nothing here yet':'Todavía no hay nada','No results match your search.':'No hay resultados que coincidan con tu búsqueda.',
      'Search codes and content…':'Buscar códigos y contenido…','Paste':'Pegar','Analyze content':'Analizar contenido',
      'Analysis result':'Resultado del análisis','Copy content':'Copiar contenido','Gallery':'Galería',
      'Code detected':'Código detectado','Save to history':'Guardar en el historial','Export CSV':'Exportar CSV',
      'Export PNG':'Exportar PNG','Export SVG':'Exportar SVG','Generate QR':'Generar QR',
      'Your QR code':'Tu código QR','Your barcode':'Tu código de barras','Preparing…':'Preparando…',
      'Content copied.':'Contenido copiado.','Value copied.':'Valor copiado.',
      'Export history CSV':'Exportar historial CSV','History exported.':'Historial exportado.',
      'Could not export history.':'No se pudo exportar el historial.'
    },
    'fr': {
      'Home':'Accueil','Favorites':'Favoris','More':'Plus','Favorite':'Favori','Done':'Terminé',
      'Open menu':'Ouvrir le menu','Smart QR Tools':'Outils QR intelligents',
      'Generate, scan and share in seconds.':'Générez, scannez et partagez en quelques secondes.',
      'Explore tools':'Découvrir les outils','Quick actions':'Actions rapides',
      'Generate QR Code':'Générer un code QR','Text, URL, Wi-Fi, contact':'Texte, URL, Wi-Fi, contact',
      'Scan QR Code':'Scanner un code QR','Use camera or gallery':'Utilisez l’appareil photo ou la galerie',
      'QR History':'Historique QR','Your recent activity':'Votre activité récente',
      'Create Barcode':'Créer un code-barres','Generate Code 128':'Générer Code 128',
      'All tools':'Tous les outils','Discover QR Studio':'Découvrir QR Studio',
      'Bulk QR Generator':'Générateur QR par lot','Create up to 50 codes':'Créez jusqu’à 50 codes',
      'QR Analyzer':'Analyseur QR','Inspect QR content and links':'Inspectez le contenu et les liens QR',
      'Settings':'Paramètres','Language and appearance':'Langue et apparence',
      'Recent activity':'Activité récente','See all':'Tout voir',
      'Tools & Settings':'Outils et paramètres','Everything you need in one place.':'Tout ce dont vous avez besoin au même endroit.',
      'QR tools':'Outils QR','QR Generator':'Générateur QR','Create custom QR codes':'Créez des codes QR personnalisés',
      'QR Scanner':'Scanner QR','Camera and gallery':'Appareil photo et galerie',
      'Barcode Generator':'Générateur de codes-barres','Code 128 format':'Format Code 128',
      'History':'Historique','Created and scanned codes':'Codes créés et scannés',
      'Preferences':'Préférences','Dark appearance':'Apparence sombre','Use the dark interface':'Utiliser l’interface sombre',
      'Language':'Langue','About QR Studio':'À propos de QR Studio','Copy':'Copier','Open':'Ouvrir',
      'Clear history':'Effacer l’historique','Clear history?':'Effacer l’historique ?','Cancel':'Annuler',
      'Clear':'Effacer','All':'Tout','Generated':'Générés','Scanned':'Scannés','Nothing here yet':'Rien pour le moment',
      'No results match your search.':'Aucun résultat ne correspond à votre recherche.',
      'Search codes and content…':'Rechercher des codes et du contenu…','Paste':'Coller',
      'Analyze content':'Analyser le contenu','Analysis result':'Résultat de l’analyse',
      'Copy content':'Copier le contenu','Gallery':'Galerie','Code detected':'Code détecté',
      'Save to history':'Enregistrer dans l’historique','Export CSV':'Exporter CSV',
      'Export PNG':'Exporter PNG','Export SVG':'Exporter SVG','Generate QR':'Générer QR',
      'Your QR code':'Votre code QR','Your barcode':'Votre code-barres','Preparing…':'Préparation…',
      'Content copied.':'Contenu copié.','Value copied.':'Valeur copiée.',
      'Export history CSV':'Exporter l’historique CSV','History exported.':'Historique exporté.',
      'Could not export history.':'Impossible d’exporter l’historique.'
    },
    'de': {
      'Home':'Startseite','Favorites':'Favoriten','More':'Mehr','Favorite':'Favorit','Done':'Fertig',
      'Open menu':'Menü öffnen','Smart QR Tools':'Intelligente QR-Tools',
      'Generate, scan and share in seconds.':'In Sekunden erstellen, scannen und teilen.',
      'Explore tools':'Tools entdecken','Quick actions':'Schnellaktionen',
      'Generate QR Code':'QR-Code erstellen','Text, URL, Wi-Fi, contact':'Text, URL, WLAN, Kontakt',
      'Scan QR Code':'QR-Code scannen','Use camera or gallery':'Kamera oder Galerie verwenden',
      'QR History':'QR-Verlauf','Your recent activity':'Deine letzten Aktivitäten',
      'Create Barcode':'Barcode erstellen','Generate Code 128':'Code 128 erzeugen',
      'All tools':'Alle Tools','Discover QR Studio':'QR Studio entdecken',
      'Bulk QR Generator':'QR-Stapelgenerator','Create up to 50 codes':'Bis zu 50 Codes erstellen',
      'QR Analyzer':'QR-Analysator','Inspect QR content and links':'QR-Inhalte und Links prüfen',
      'Settings':'Einstellungen','Language and appearance':'Sprache und Darstellung',
      'Recent activity':'Letzte Aktivitäten','See all':'Alle anzeigen',
      'Tools & Settings':'Tools und Einstellungen','Everything you need in one place.':'Alles, was du brauchst, an einem Ort.',
      'QR tools':'QR-Tools','QR Generator':'QR-Generator','Create custom QR codes':'Eigene QR-Codes erstellen',
      'QR Scanner':'QR-Scanner','Camera and gallery':'Kamera und Galerie',
      'Barcode Generator':'Barcode-Generator','Code 128 format':'Code-128-Format',
      'History':'Verlauf','Created and scanned codes':'Erstellte und gescannte Codes',
      'Preferences':'Einstellungen','Dark appearance':'Dunkles Design','Use the dark interface':'Dunkle Oberfläche verwenden',
      'Language':'Sprache','About QR Studio':'Über QR Studio','Copy':'Kopieren','Open':'Öffnen',
      'Clear history':'Verlauf löschen','Clear history?':'Verlauf löschen?','Cancel':'Abbrechen',
      'Clear':'Löschen','All':'Alle','Generated':'Erstellt','Scanned':'Gescannt','Nothing here yet':'Noch nichts vorhanden',
      'No results match your search.':'Keine Ergebnisse für deine Suche.','Search codes and content…':'Codes und Inhalte suchen…',
      'Paste':'Einfügen','Analyze content':'Inhalt analysieren','Analysis result':'Analyseergebnis',
      'Copy content':'Inhalt kopieren','Gallery':'Galerie','Code detected':'Code erkannt',
      'Save to history':'Im Verlauf speichern','Export CSV':'CSV exportieren','Export PNG':'PNG exportieren',
      'Export SVG':'SVG exportieren','Generate QR':'QR erstellen','Your QR code':'Dein QR-Code',
      'Your barcode':'Dein Barcode','Preparing…':'Wird vorbereitet…','Content copied.':'Inhalt kopiert.',
      'Value copied.':'Wert kopiert.','Export history CSV':'Verlauf als CSV exportieren',
      'History exported.':'Verlauf exportiert.','Could not export history.':'Verlauf konnte nicht exportiert werden.'
    }
  };

  static String languageName(String code) => languages
      .firstWhere((item) => item.code == code, orElse: () => languages.first).label;

  static String translate(String english, String portuguese, String code) {
    if (code == 'pt') return portuguese;
    if (code == 'en') return english;
    final translated = _translations[code]?[english];
    if (translated != null) return translated;
    final count = RegExp(r'^(\\d+) codes created$').firstMatch(english);
    if (count != null) {
      final value = count.group(1);
      if (code == 'es') return '$value códigos creados';
      if (code == 'fr') return '$value codes créés';
      if (code == 'de') return '$value Codes erstellt';
    }
    return english;
  }
}
