#!/bin/bash

# build_release.sh
# Builds Insomnia for Release distribution
#
# Usage: ./Scripts/build_release.sh [version]
# Example: ./Scripts/build_release.sh 1.0.0

set -e

# Configuration
PROJECT_NAME="Insomnia"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
RELEASE_DIR="$BUILD_DIR/Release"
VERSION="${1:-1.0}"

echo "=========================================="
echo "Building $PROJECT_NAME v$VERSION"
echo "=========================================="

# Clean previous build
echo "→ Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

# Build Release configuration
echo "→ Building Release configuration..."
cd "$PROJECT_DIR"
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$PROJECT_NAME" \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR/DerivedData" \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGN_STYLE=Manual \
           DEVELOPMENT_TEAM="" \
           SYMROOT="$BUILD_DIR" \
           build \
           | grep -E "(Build|error:|warning:|\*\*)" || true

# Check if build succeeded
APP_PATH="$RELEASE_DIR/$PROJECT_NAME.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed: $APP_PATH not found"
    exit 1
fi

echo "✓ Build succeeded: $APP_PATH"

# Create DMG
echo "→ Creating DMG..."
DMG_NAME="$PROJECT_NAME-$VERSION.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"

# Create temporary DMG folder with Applications symlink
DMG_TEMP="$BUILD_DIR/dmg_temp"
rm -rf "$DMG_TEMP"
mkdir -p "$DMG_TEMP"
cp -R "$APP_PATH" "$DMG_TEMP/"
ln -s /Applications "$DMG_TEMP/Applications"

# Create DMG
hdiutil create -volname "$PROJECT_NAME" \
               -srcfolder "$DMG_TEMP" \
               -ov -format UDZO \
               "$DMG_PATH"

rm -rf "$DMG_TEMP"

echo "✓ DMG created: $DMG_PATH"

# Create ZIP as alternative
echo "→ Creating ZIP..."
ZIP_NAME="$PROJECT_NAME-$VERSION.zip"
ZIP_PATH="$BUILD_DIR/$ZIP_NAME"
cd "$RELEASE_DIR"
zip -r -q "$ZIP_PATH" "$PROJECT_NAME.app"

echo "✓ ZIP created: $ZIP_PATH"

# Generate checksums
echo "→ Generating checksums..."
cd "$BUILD_DIR"
shasum -a 256 "$DMG_NAME" > "$DMG_NAME.sha256"
shasum -a 256 "$ZIP_NAME" > "$ZIP_NAME.sha256"

DMG_SHA=$(cat "$DMG_NAME.sha256" | awk '{print $1}')
ZIP_SHA=$(cat "$ZIP_NAME.sha256" | awk '{print $1}')

echo "✓ Checksums generated"

# Summary
echo ""
echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "Output files:"
echo "  • $DMG_PATH"
echo "  • $ZIP_PATH"
echo ""
echo "Checksums (SHA256):"
echo "  • $DMG_NAME: $DMG_SHA"
echo "  • $ZIP_NAME: $ZIP_SHA"
echo ""
