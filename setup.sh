#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! xcode-select -p | grep -q "Xcode.app"; then
  echo "⚠️  Full Xcode is required (Command Line Tools alone can't build iOS apps)."
  echo "    Install Xcode from the Mac App Store, then run:"
  echo "      sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  echo "    and re-run this script."
  exit 1
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Installing XcodeGen..."
  brew install xcodegen
fi

xcodegen generate
echo "✅ Generated Glance.xcodeproj — opening it now."
echo "   In Xcode: select your iPad, set Signing Team (your free Apple ID), then ⌘R."
open Glance.xcodeproj
