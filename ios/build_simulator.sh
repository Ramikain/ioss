#!/bin/bash

# iOS Simulator Build Script
# Use this script to build for iOS Simulator without code signing requirements

echo "📱 Building Fresh Check-in App for iOS Simulator..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

echo "📁 Project directory: $(pwd)"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo ""

# Build for iOS Simulator
echo "🔨 Building for iOS Simulator..."
echo "   This may take a few minutes..."
echo ""

if flutter build ios --simulator; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 To run on iOS Simulator:"
    echo "   1. Open iOS Simulator from Xcode"
    echo "   2. Run: flutter run -d 'iPhone Simulator'"
    echo ""
    echo "📂 Build output location:"
    echo "   build/ios/iphonesimulator/Runner.app"
    echo ""
    echo "🎯 Next steps:"
    echo "   • Test all app features in simulator"
    echo "   • Verify QR scanning works with camera"
    echo "   • Test Bluetooth printer discovery"
    echo "   • Check badge printing functionality"
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "🔧 Try these troubleshooting steps:"
    echo "   1. Run: ./fix_ios_build.sh"
    echo "   2. Check: ios/iOS_Development_Guide.md"
    echo "   3. Verify Xcode is installed and updated"
    echo ""
    exit 1
fi

echo ""
echo "📖 For more help, see: ios/iOS_Development_Guide.md"