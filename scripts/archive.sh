#!/usr/bin/env bash
# Archive Glance and export an App Store .ipa from the command line.
# Requires: full Xcode active, a paid Developer account, and a Distribution
# certificate (Xcode creates one the first time you Archive via the GUI).
#
# Usage:
#   ./scripts/archive.sh                 # archive + export
#   ./scripts/archive.sh --upload        # also upload to App Store Connect
#
# Upload needs an App Store Connect API key. Set these env vars first:
#   ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH (path to the .p8 file)
set -euo pipefail
cd "$(dirname "$0")/.."

SCHEME="Glance"
ARCHIVE="build/Glance.xcarchive"
EXPORT_DIR="build/export"

echo "▶︎ Archiving…"
xcodebuild -project Glance.xcodeproj -scheme "$SCHEME" \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" \
  clean archive

cat > build/ExportOptions.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>            <string>app-store-connect</string>
    <key>destination</key>       <string>export</string>
    <key>signingStyle</key>      <string>automatic</string>
    <key>uploadSymbols</key>     <true/>
</dict>
</plist>
PLIST

echo "▶︎ Exporting .ipa…"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist build/ExportOptions.plist

echo "✅ Exported to $EXPORT_DIR"

if [[ "${1:-}" == "--upload" ]]; then
  echo "▶︎ Uploading to App Store Connect…"
  IPA="$(ls "$EXPORT_DIR"/*.ipa | head -1)"
  xcrun altool --upload-app -f "$IPA" -t ios \
    --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
  echo "✅ Uploaded. It will appear in App Store Connect after processing."
fi
