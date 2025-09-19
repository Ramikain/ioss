# iOS Development Guide for Fresh Check-in App

## Overview
This guide helps you build and test the Fresh Check-in App on iOS devices and simulators, addressing common code signing and development team issues.

## Prerequisites
- macOS computer with Xcode installed
- Flutter SDK installed on macOS
- Apple Developer Account (for device testing)

## Development Workflows

### 1. iOS Simulator Development (Recommended)
For development and testing without needing a physical device or Apple Developer Account:

```bash
# List available simulators
flutter devices

# Run on iOS Simulator
flutter run -d "iPhone Simulator"

# Or build for simulator
flutter build ios --simulator
```

**Advantages:**
- No code signing required
- No Apple Developer Account needed
- Fast development cycle
- All app features work except device-specific ones

### 2. Physical Device Testing
For testing on actual iOS devices:

#### Step 1: Set up Apple Developer Account
1. Sign up for Apple Developer Program ($99/year)
2. Or use free Apple ID (limited to 7 days, 3 apps)

#### Step 2: Configure Xcode Project
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** project in navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Sign in with Apple ID if not already signed in
5. Select your **Development Team**
6. Ensure **Automatically manage signing** is checked
7. Verify **Bundle Identifier** is unique (e.g., com.yourcompany.freshCheckinApp)

#### Step 3: Build and Deploy
```bash
# Build for device
flutter build ios --release

# Or run directly on connected device
flutter run -d "Your iPhone Name"
```

### 3. CI/CD and Automated Builds
For continuous integration without interactive Xcode setup:

```bash
# Build without code signing (requires manual signing later)
flutter build ios --debug --no-codesign

# Build for simulator in CI
flutter build ios --simulator
```

## App Store Distribution

### 1. Prepare for Release
```bash
# Update version in pubspec.yaml
version: 1.0.0+1

# Build release version
flutter build ios --release
```

### 2. Archive in Xcode
1. Open `ios/Runner.xcworkspace`
2. Select **Any iOS Device** as target
3. Product → Archive
4. Upload to App Store Connect

### 3. App Store Connect
1. Create app record
2. Upload screenshots
3. Set app information
4. Submit for review

## Troubleshooting Common Issues

### Code Signing Errors
**Error:** "Building a deployable iOS app requires a selected Development Team"

**Solutions:**
1. **Use Simulator:** `flutter run -d "iPhone Simulator"`
2. **Set up Team:** Follow "Physical Device Testing" steps above
3. **Skip Signing:** `flutter build ios --no-codesign` (manual signing required)

### Bundle Identifier Conflicts
**Error:** "Bundle identifier is not available"

**Solution:**
1. Change Bundle ID in Xcode: `com.yourcompany.freshCheckinApp`
2. Update in `ios/Runner/Info.plist` if needed
3. Register new Bundle ID in Apple Developer Portal

### Provisioning Profile Issues
**Error:** "No provisioning profile found"

**Solution:**
1. Enable "Automatically manage signing" in Xcode
2. Or manually create provisioning profile in Apple Developer Portal
3. Download and install profile

### Device Not Recognized
**Error:** "Device not found"

**Solution:**
1. Trust computer on iOS device
2. Enable Developer Mode (iOS 16+): Settings → Privacy & Security → Developer Mode
3. Restart Xcode and reconnect device

## Best Practices

### Development
- Use iOS Simulator for most development work
- Test on physical device before release
- Keep Xcode and Flutter updated
- Use version control for iOS configuration files

### Code Signing
- Use automatic signing for development
- Manual signing for distribution builds
- Keep certificates and profiles organized
- Rotate certificates before expiration

### Testing
- Test on multiple iOS versions
- Verify permissions work correctly
- Test Bluetooth and camera functionality
- Validate QR scanning performance

## Quick Commands Reference

```bash
# Development
flutter run -d "iPhone Simulator"          # Run on simulator
flutter run -d "iPhone"                    # Run on device
flutter build ios --simulator              # Build for simulator
flutter build ios --debug --no-codesign    # Build without signing

# Release
flutter build ios --release               # Build for App Store
flutter clean                             # Clean build cache
flutter pub get                           # Update dependencies

# iOS specific
open ios/Runner.xcworkspace               # Open in Xcode
cd ios && pod install                     # Update CocoaPods
cd ios && pod update                      # Update pod versions
```

## Support

For additional help:
- [Flutter iOS Documentation](https://flutter.dev/docs/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Help](https://help.apple.com/xcode/)

---

**Note:** This app includes Bluetooth thermal printing, QR scanning, and camera features that require proper iOS permissions and may need testing on physical devices for full functionality.