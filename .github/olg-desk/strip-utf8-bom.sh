#!/usr/bin/env bash
# Remove UTF-8 BOM from text files (PowerShell Set-Content -Encoding UTF8 adds BOM on Windows).
set -euo pipefail

strip_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if [[ "$(head -c 3 "$file" | wc -c)" -eq 3 ]] && [[ "$(head -c 3 "$file" | od -An -tx1 | tr -d ' \n')" == "efbbbf" ]]; then
    tail -c +4 "$file" > "${file}.nobom" && mv "${file}.nobom" "$file"
    echo "Stripped BOM: $file"
  fi
}

FILES=(
  Cargo.toml
  flutter/macos/Runner.xcodeproj/project.pbxproj
  flutter/macos/Runner/Configs/AppInfo.xcconfig
  flutter/macos/Runner/Info.plist
  flutter/lib/common.dart
  flutter/lib/desktop/pages/desktop_home_page.dart
  src/lang/es.rs
  src/lang/en.rs
)

for f in "${FILES[@]}"; do
  strip_file "$f"
done
