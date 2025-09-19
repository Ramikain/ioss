#!/bin/bash

# iOS Build Fix Script
# This script fixes common iOS build issues when moving from Windows to macOS

echo "🔧 Starting iOS build fix..."

# Navigate to project root
cd "$(dirname "$0")/.."

echo "📁 Current directory: $(pwd)"

# Step 1: Clean Flutter cache
echo "🧹 Cleaning Flutter cache..."
flutter clean

# Step 2: Remove iOS-specific cache files
echo "🗑️  Removing iOS cache files..."
rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_export_environment.sh
rm -rf ios/.symlinks
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# Step 3: Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Step 4: Navigate to iOS directory
cd ios

# Step 5: Install CocoaPods dependencies
echo "🍫 Installing CocoaPods dependencies..."
pod install

# Step 6: Clean Xcode derived data
echo "🧽 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

# Step 7: Go back to project root
cd ..

echo "✅ iOS build fix completed!"
echo ""
echo "🎯 Choose your next step:"
echo ""
echo "For Development (Recommended):"
echo "  flutter run -d 'iPhone Simulator'"
echo ""
echo "For Simulator Build:"
echo "  flutter build ios --simulator"
echo ""
echo "For Device Testing (Requires Apple Developer Account):"
echo "  1. Open: open ios/Runner.xcworkspace"
echo "  2. Configure Development Team in Xcode"
echo "  3. Run: flutter run -d 'iPhone'"
echo ""
echo "For CI/CD (No Code Signing):"
echo "  flutter build ios --debug --no-codesign"
echo ""
echo "📖 For detailed instructions, see: ios/iOS_Development_Guide.md"