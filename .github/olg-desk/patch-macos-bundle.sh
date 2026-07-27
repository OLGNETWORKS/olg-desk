#!/usr/bin/env bash
set -euo pipefail

APP_NAME="OLG Desk"
BUNDLE_ID="com.olgsys.olgdesk"
APPINFO="flutter/macos/Runner/Configs/AppInfo.xcconfig"
PBXPROJ="flutter/macos/Runner.xcodeproj/project.pbxproj"
INFOPLIST="flutter/macos/Runner/Info.plist"
WORKFLOW=".github/workflows/flutter-build.yml"
LOGO="flutter/assets/logo.png"
APPICON="flutter/macos/Runner/AppIcon.icns"

if [[ ! -f "$APPINFO" ]]; then
  echo "Skip macOS bundle patch: $APPINFO not found"
  exit 0
fi

# xcconfig values with spaces must be quoted.
if grep -q 'PRODUCT_NAME = "OLG Desk"' "$APPINFO"; then
  echo "macOS bundle defaults already present in $APPINFO"
else
  sed -i 's|PRODUCT_NAME = RustDesk|PRODUCT_NAME = "OLG Desk"|' "$APPINFO"
  sed -i 's|PRODUCT_NAME = OLG Desk|PRODUCT_NAME = "OLG Desk"|' "$APPINFO"
  sed -i "s|PRODUCT_BUNDLE_IDENTIFIER = com.carriez.flutterHbb|PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID}|" "$APPINFO"
  sed -i 's|PRODUCT_COPYRIGHT = Copyright .*|PRODUCT_COPYRIGHT = Copyright © 2026 Olgsys. All rights reserved.|' "$APPINFO"
  echo "Patched $APPINFO"
fi

if [[ -f "$PBXPROJ" ]]; then
  # PBX path values with spaces must be quoted or CocoaPods/Xcode parsers fail.
  sed -i 's|path = RustDesk.app;|path = "OLG Desk.app";|g' "$PBXPROJ"
  sed -i 's|path = OLG Desk.app;|path = "OLG Desk.app";|g' "$PBXPROJ"
  sed -i 's|/\* RustDesk.app \*/|/* OLG Desk.app */|g' "$PBXPROJ"
  sed -i 's|PRODUCT_BUNDLE_IDENTIFIER = com.carriez.rustdesk;|PRODUCT_BUNDLE_IDENTIFIER = com.olgsys.olgdesk;|g' "$PBXPROJ"
fi

if [[ -f "$INFOPLIST" ]]; then
  sed -i 's|<string>com.carriez.rustdesk</string>|<string>com.olgsys.olgdesk</string>|g' "$INFOPLIST"
  sed -i 's|<string>rustdesk</string>|<string>olgdesk</string>|g' "$INFOPLIST"
  if ! grep -q 'CFBundleDisplayName' "$INFOPLIST"; then
    sed -i 's|<key>CFBundleExecutable</key>|<key>CFBundleDisplayName</key>\n\t<string>OLG Desk</string>\n\t<key>CFBundleExecutable</key>|' "$INFOPLIST"
  fi
fi

if [[ -f "$WORKFLOW" ]]; then
  sed -i 's|RustDesk\.app|OLG Desk.app|g' "$WORKFLOW"
  sed -i 's|rustdesk-${{ env.VERSION }}-${{ matrix.job.arch }}.dmg|olg-desk-${{ env.VERSION }}-${{ matrix.job.arch }}.dmg|g' "$WORKFLOW"
fi

if [[ "$(uname -s)" == "Darwin" && -f "$LOGO" && -f "$APPICON" ]]; then
  ICONSET="$(mktemp -d)/OLGDesk.iconset"
  mkdir -p "$ICONSET"
  for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$LOGO" --out "${ICONSET}/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$LOGO" --out "${ICONSET}/icon_${size}x${size}@2x.png" >/dev/null
  done
  iconutil -c icns -o "$APPICON" "$ICONSET"
  echo "Regenerated $APPICON from $LOGO"
fi

echo "OLG Desk macOS bundle patch applied"
