# QR Studio

**QR Studio by Nexauren** is a Flutter app for creating, scanning, styling, saving and sharing QR codes and barcodes. Its visual direction follows the approved Nexauren reference: deep navy surfaces, electric purple-to-blue gradients, cyan accents, rounded cards and animated transitions.

## Features

### QR creation
- QR for plain text and links.
- Wi-Fi network sharing with WPA, WEP and open network payloads.
- vCard contact cards.
- Email with subject and message.
- Phone and pre-filled SMS actions.
- Geographic coordinates.
- Colour presets for foreground and background.
- Square or rounded QR modules with high error correction.
- PNG export and share.

### Scanning
- Live camera scanning for QR codes and supported barcode formats.
- Torch, camera switching and automatic zoom.
- Scan from an image in the gallery.
- Result details, copy and open supported links.
- Haptic feedback on detection.

### Barcodes
- Code 128, Code 39, EAN-13, EAN-8 and UPC-A generation.
- Format validation before generation.
- SVG export for sharp printing at any scale.

### Organisation
- Bulk QR generator for up to 50 lines at a time.
- Local history with search and generated/scanned filters.
- Favorites, individual delete and clear-history actions.
- Portuguese and English interface.
- Dark and light themes.
- Local-first storage; no account or cloud service is required.

## Technology

- Flutter / Dart for all application screens and logic.
- Java Android launcher activity; no Kotlin application source.
- `qr_flutter` for QR rendering and PNG export.
- `mobile_scanner` for camera and image barcode scanning.
- `barcode_widget` for linear barcode generation.
- `shared_preferences` for local history and preferences.

## Run locally

Install Flutter 3.29 or newer, then:

```bash
flutter pub get
bash tool/bootstrap_android.sh
flutter run
```

## Build Android APKs

The GitHub Actions workflow creates separate ARM 32-bit and ARM64 APKs instead of a large universal package. Each APK is checked against a 30 MiB download ceiling before the artifact is uploaded.

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

The generated APKs are located in `build/app/outputs/flutter-apk/`.

## Package

- Android application ID: `com.nexauren.qrstudio`
- Display name: `QR Studio`
- Publisher: `Nexauren`

## Product principles

Build a complete, trustworthy tool first. Reduce download size through ABI-specific packages and build optimisation, not by removing useful features. The 30 MiB ceiling applies to each downloadable APK, not the installed footprint.
