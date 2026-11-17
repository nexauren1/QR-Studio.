# QR Studio

**QR Studio by Nexauren** is a Flutter app for creating, scanning, saving and sharing QR codes and barcodes. The visual direction follows the approved Nexauren reference: deep navy surfaces, electric purple-to-blue gradients, cyan accents and rounded tool cards.

## First implementation

- Home dashboard with quick actions and recent activity.
- QR generator for text, URLs, Wi-Fi and contact cards.
- Live camera scanner and scan-from-gallery support.
- Barcode generator (Code 128).
- Local history and favourites.
- QR PNG export through the Android share sheet.
- English and Portuguese interface toggle.
- Dark and light appearance toggle.

History and preferences are stored locally on the device. No account or cloud service is required.

## Technology

- Flutter / Dart (application code).
- No Kotlin application source is maintained in this repository. The Android bootstrap script converts Flutter's generated launcher activity to Java.
- QR rendering: `qr_flutter`.
- Camera scanning: `mobile_scanner`.
- Barcode rendering: `barcode_widget`.

## Run locally

Install Flutter 3.29 or newer, then:

```bash
flutter pub get
bash tool/bootstrap_android.sh
flutter run
```

The Android platform folder is generated from Flutter's standard template by the bootstrap script. The app's features and screens are written in Dart.

## Build an APK

The GitHub Actions workflow **Android APK** generates the Android runner, runs dependency resolution and static analysis, then builds a release APK. The APK is attached to the workflow run as an artifact.

## Package

- Android application ID: `com.nexauren.qrstudio`
- Display name: `QR Studio`
- Publisher: `Nexauren`

## Roadmap

The initial commit establishes the Flutter app and the core QR / barcode flows. Future iterations can expand custom QR colours, logos, additional barcode formats, bulk creation and export options.
