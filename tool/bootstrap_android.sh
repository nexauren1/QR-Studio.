#!/usr/bin/env bash
set -euo pipefail

if [ ! -d android ]; then
  flutter create --no-pub --platforms=android --org com.nexauren --project-name qr_studio .
fi

# Flutter's generated sample test targets the template app, not QR Studio.
rm -rf test

# Keep the app entry point in Java; application screens and logic are Dart.
if [ -d android/app/src/main/kotlin ]; then
  while IFS= read -r kotlin_file; do
    [ -n "$kotlin_file" ] || continue
    relative_path="${kotlin_file#android/app/src/main/kotlin/}"
    package_path="${relative_path%/MainActivity.kt}"
    java_dir="android/app/src/main/java/$package_path"
    package_name="${package_path//\//.}"
    mkdir -p "$java_dir"
    cat > "$java_dir/MainActivity.java" <<JAVA
package $package_name;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
}
JAVA
    rm -f "$kotlin_file"
  done < <(find android/app/src/main/kotlin -name MainActivity.kt -type f 2>/dev/null || true)
  find android/app/src/main/kotlin -type d -empty -delete 2>/dev/null || true
fi

python3 - <<'PY'
from pathlib import Path
import re

manifest = Path("android/app/src/main/AndroidManifest.xml")
if manifest.exists():
    content = manifest.read_text(encoding="utf-8")
    if "android.permission.CAMERA" not in content:
        content = content.replace(
            "<application",
            '    <uses-permission android:name="android.permission.CAMERA" />\n\n    <application',
            1,
        )
    content = re.sub(r'android:label="[^"]+"', 'android:label="QR Studio"', content, count=1)
    manifest.write_text(content, encoding="utf-8")
PY
