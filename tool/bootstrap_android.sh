#!/usr/bin/env bash
set -euo pipefail

if [ ! -d android ]; then
  flutter create --no-pub --platforms=android --org com.nexauren --project-name qr_studio .
fi

# Remove only Flutter's generated template test, preserving QR Studio tests.
rm -f test/widget_test.dart

# Keep Android launcher code in Java; application screens and logic are Dart.
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
    content = re.sub(r'android:icon="[^"]+"', 'android:icon="@mipmap/ic_launcher"', content, count=1)
    manifest.write_text(content, encoding="utf-8")
PY

# Install the approved QR Studio launcher icon.
launcher_icon="tool/android-icons/ic_launcher.png"
test -f "$launcher_icon"
res_dir="android/app/src/main/res"
mkdir -p "$res_dir/mipmap-xxhdpi"
find "$res_dir" -type f -name 'ic_launcher*.png' -delete
rm -f "$res_dir/mipmap-anydpi-v26/ic_launcher.xml"
cp "$launcher_icon" "$res_dir/mipmap-xxhdpi/ic_launcher.png"

# Configure permanent QR Studio release signing when key.properties is supplied by CI.
python3 - <<'PY'
from pathlib import Path

kts = Path("android/app/build.gradle.kts")
groovy = Path("android/app/build.gradle")

kts_config = """
// QR_STUDIO_SIGNING_CONFIG
val qrStudioKeyProperties = Properties()
val qrStudioKeyPropertiesFile = rootProject.file("key.properties")
if (qrStudioKeyPropertiesFile.exists()) {
    qrStudioKeyProperties.load(FileInputStream(qrStudioKeyPropertiesFile))
}
extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
    signingConfigs {
        create("release") {
            if (qrStudioKeyPropertiesFile.exists()) {
                keyAlias = qrStudioKeyProperties["keyAlias"] as String
                keyPassword = qrStudioKeyProperties["keyPassword"] as String
                storeFile = file(qrStudioKeyProperties["storeFile"] as String)
                storePassword = qrStudioKeyProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = if (qrStudioKeyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
"""

groovy_config = """
// QR_STUDIO_SIGNING_CONFIG
def qrStudioKeyProperties = new Properties()
def qrStudioKeyPropertiesFile = rootProject.file('key.properties')
if (qrStudioKeyPropertiesFile.exists()) {
    qrStudioKeyProperties.load(new FileInputStream(qrStudioKeyPropertiesFile))
}
android {
    signingConfigs {
        release {
            if (qrStudioKeyPropertiesFile.exists()) {
                keyAlias qrStudioKeyProperties['keyAlias']
                keyPassword qrStudioKeyProperties['keyPassword']
                storeFile file(qrStudioKeyProperties['storeFile'])
                storePassword qrStudioKeyProperties['storePassword']
            }
        }
    }
    buildTypes {
        release {
            signingConfig qrStudioKeyPropertiesFile.exists()
                ? signingConfigs.release
                : signingConfigs.debug
        }
    }
}
"""

if kts.exists():
    content = kts.read_text(encoding="utf-8")
    if "QR_STUDIO_SIGNING_CONFIG" not in content:
        if "import java.util.Properties" not in content:
            content = "import java.util.Properties\nimport java.io.FileInputStream\n\n" + content
        new_android_block = "extensions.configure<com.android.build.api.dsl.ApplicationExtension> {"
        if "android {" in content:
            content = content.replace("android {", new_android_block, 1)
        elif new_android_block not in content:
            raise SystemExit("Could not find the generated Android application DSL block.")
        kts.write_text(content.rstrip() + "\n\n" + kts_config, encoding="utf-8")
elif groovy.exists():
    content = groovy.read_text(encoding="utf-8")
    if "QR_STUDIO_SIGNING_CONFIG" not in content:
        if "import java.util.Properties" not in content:
            content = "import java.util.Properties\nimport java.io.FileInputStream\n\n" + content
        groovy.write_text(content.rstrip() + "\n\n" + groovy_config, encoding="utf-8")
else:
    raise SystemExit("Flutter Android Gradle file was not generated.")
PY
