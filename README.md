# QR Studio

QR Studio by Nexauren is a Flutter app for creating, scanning, styling, organising and sharing QR codes and barcodes. Its visual direction follows the approved Nexauren reference: deep navy surfaces, electric purple-to-blue gradients, cyan accents, rounded cards and polished animated transitions.

## Features

### QR creation
- Plain text and website links.
- Wi-Fi network sharing with WPA, WEP and open network payloads.
- vCard contact cards.
- Email with subject and message.
- Phone and pre-filled SMS actions.
- WhatsApp click-to-chat links with optional message.
- Geographic coordinates.
- Calendar event QR codes with date, time, location and description.
- Colour presets for foreground and background.
- Square or rounded QR modules, with high error correction.
- PNG export and sharing.

### Scanning
- Live camera scanning for QR codes and supported barcode formats.
- Torch, camera switching and automatic zoom.
- Scan from an image in the gallery, with a visible image-analysis state.
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

## Visual and performance decisions
- UI surfaces, logo mark and decoration are drawn with Flutter widgets and gradients; no large background PNGs are bundled.
- Tool cards use animated entrance, refined borders and subtle colour glows.
- Tool screens share a consistent fade / slide / scale transition.
- QR, barcode, bulk and gallery-image actions show a dedicated processing panel.
- QR history stores payload text, type, date and favourite state—not rendered QR images.
- The home screen is the initial route; generator, scanner and barcode screens are created when opened.
- The bundled scanner model is kept so scanning remains available on first use without downloading a model.
- Release builds use Dart obfuscation and split debug symbols.

## Technology
- Flutter / Dart for application screens and logic.
- Java Android launcher activity; no Kotlin app source.
- qr_flutter for QR rendering and PNG export.
- mobile_scanner for camera and image barcode scanning.
- barcode_widget for linear barcode generation.
- shared_preferences for local history and preferences.
- url_launcher for explicitly opening scanned links.

## Run locally

Install Flutter 3.29 or newer, then:

    flutter pub get
    bash tool/bootstrap_android.sh
    flutter run

## Build the universal Android APK

The release workflow produces one universal ARM APK containing both ARMv7 (32-bit) and ARM64 (64-bit). Upload this single file to the app listing; users do not need to choose between two APK variants.

    flutter build apk --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=build/symbols

The APK is located at:

    build/app/outputs/flutter-apk/app-release.apk

The workflow reports the final APK size for visibility and uploads the universal APK as a build artifact. There is no fixed 30 MB rejection threshold: a larger file does not fail the build solely because of its size. Keep the symbol maps from build/symbols/ privately for crash analysis.

## Package

- Android application ID: com.nexauren.qr_studio
- Display name: QR Studio
- Publisher: Nexauren

## Product principles

Build a complete, trustworthy tool first. Reduce download size through code/resource optimisation, not by removing useful features. The release package prioritises a single universal download that supports both ARM32 and ARM64 devices.
