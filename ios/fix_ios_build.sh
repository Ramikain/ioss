#!/bin/bash
# iOS Build Fix Script
# Run this script on macOS to fix path issues and prepare for iOS build

echo "🔧 Fixing iOS build configuration..."

# Navigate to project root
cd "$(dirname "$0")/.."

echo "📁 Current directory: $(pwd)"

# Clean Flutter build
echo "🧹 Cleaning Flutter build..."
flutter clean

# Remove generated iOS configuration files
echo "🗑️  Removing generated iOS config files..."
rm -f ios/Flutter/Generated.xcconfig
rm -f ios/Flutter/flutter_export_environment.sh

# Regenerate Flutter configuration
echo "🔄 Regenerating Flutter configuration..."
flutter pub get

# Navigate to iOS directory
cd ios

# Clean CocoaPods cache
echo "🧹 Cleaning CocoaPods cache..."
rm -rf Pods
rm -f Podfile.lock

# Update CocoaPods repo
echo "📦 Updating CocoaPods repository..."
pod repo update

# Install pods
echo "📦 Installing CocoaPods dependencies..."
pod install

# Clean Xcode derived data
echo "🧹 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "✅ iOS build configuration fixed!"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Or run: flutter run"
echo "3. Or build: flutter build ios"
echo ""
echo "If you still encounter issues, check the README_iOS_Setup.md file."