#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env.update}"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

REPO_DIR="${REPO_DIR:-$HOME/git/VoiceInk}"
EXPECTED_WHISPER_DIR="${EXPECTED_WHISPER_DIR:-$HOME/VoiceInk-Dependencies/whisper.cpp}"
EXPECTED_WHISPER_XCFRAMEWORK="${EXPECTED_WHISPER_XCFRAMEWORK:-$EXPECTED_WHISPER_DIR/build-apple/whisper.xcframework}"
LOCAL_WHISPER_BUILD_APPLE="${LOCAL_WHISPER_BUILD_APPLE:-$REPO_DIR/build-apple}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/VoiceInkBuild}"

# Ensure the expected whisper.cpp path exists for Xcode project references.
if [ ! -d "$EXPECTED_WHISPER_XCFRAMEWORK" ]; then
  mkdir -p "$EXPECTED_WHISPER_DIR"
  if [ -L "$LOCAL_WHISPER_BUILD_APPLE" ] || [ -d "$LOCAL_WHISPER_BUILD_APPLE" ]; then
    ln -sfn "$(readlink "$LOCAL_WHISPER_BUILD_APPLE" 2>/dev/null || echo "$LOCAL_WHISPER_BUILD_APPLE")" "$EXPECTED_WHISPER_DIR/build-apple"
  fi
fi

rm -rf "$DERIVED_DATA_PATH"

xcodebuild \
  -project "$REPO_DIR/VoiceInk.xcodeproj" \
  -scheme VoiceInk \
  -configuration Release \
  -destination "platform=macOS,arch=arm64" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build
