#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

GEN_DIR="$ROOT/Support/.generated"
mkdir -p "$GEN_DIR"
swift "$ROOT/scripts/GenerateAppIcon.swift" "$GEN_DIR"

swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
EXEC_SRC="${BIN_DIR}/2FA"

APP_NAME="2FA.app"
OUT_DIR="${1:-"$ROOT/dist"}"
APP_PATH="${OUT_DIR}/${APP_NAME}"

rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"
cp "$EXEC_SRC" "$APP_PATH/Contents/MacOS/2FA"
chmod +x "$APP_PATH/Contents/MacOS/2FA"
cp "$ROOT/Support/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$GEN_DIR/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"

echo "已生成: $APP_PATH"
echo "运行: open \"$APP_PATH\""
