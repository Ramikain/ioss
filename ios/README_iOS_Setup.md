# iOS Setup Guide for Fresh Check-in App

## Prerequisites
- macOS with Xcode installed
- iOS device or simulator
- Apple Developer account (for device testing)

## iOS Configuration Summary

This Flutter app has been configured for iOS with the following features:

### 1. Permissions Added to Info.plist
The following permissions have been added to `ios/Runner/Info.plist`:
- `NSBluetoothAlwaysUsageDescription`: For Bluetooth printer connectivity
- `NSBluetoothPeripheralUsageDescription`: For Bluetooth peripheral access
- `NSCameraUsageDescription`: For QR code scanning functionality

### 2. iOS Deployment Target
- Minimum iOS version: 12.0
- Compatible with iPhone and iPad

### 3. Dependencies
The app uses the following packages that support iOS:
- `print_bluetooth_thermal`: Bluetooth thermal printer support
- `mobile_scanner`: QR code scanning
- `esc_pos_utils_plus`: ESC/POS printer commands
- All other dependencies are iOS-compatible

### 4. Podfile Configuration
A Podfile has been created with:
- iOS 12.0 minimum deployment target
- Proper Flutter integration
- Bitcode disabled (required for some packages)
- Code signing configuration

## Building for iOS

### Quick Fix (Recommended):

If you're building on macOS after the project was configured on Windows:

```bash
# Make the script executable and run it
chmod +x ios/fix_ios_build.sh
./ios/fix_ios_build.sh
```

This script will automatically:
- Clean Flutter build cache
- Remove Windows-specific configuration files
- Regenerate macOS-compatible configuration
- Install CocoaPods dependencies
- Clean Xcode derived data

### Manual Setup (Alternative):

1. **Install CocoaPods** (if not already installed):
   ```bash
   sudo gem install cocoapods
   ```

2. **Clean and regenerate configuration**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Install iOS dependencies**:
   ```bash
   cd ios
   pod install
   ```

4. **Build the app**:
   ```bash
   flutter build ios
   ```

5. **Run on device/simulator**:
   ```bash
   flutter run
   ```

### For App Store Distribution:

1. **Build for release**:
   ```bash
   flutter build ios --release
   ```

2. **Open in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Configure signing and build in Xcode**

## Features Supported on iOS

✅ **QR Code Scanning**: Full camera access and QR detection
✅ **Bluetooth Printing**: Connect to thermal printers via Bluetooth
✅ **Badge Templates**: Custom 2.4x3.5 inch badge designs
✅ **API Integration**: Event and attendee data synchronization
✅ **Local Storage**: Offline capability with SharedPreferences
✅ **Image Processing**: Badge generation with attendee photos

## Troubleshooting

### Common Issues:

1. **Code Signing Issues (Most Common)**:
   Error: "Building a deployable iOS app requires a selected Development Team with a Provisioning Profile"
   
   **Solutions:**
   
   **Option 1: Use iOS Simulator (Recommended for Development)**
   ```bash
   flutter run -d "iPhone Simulator"
   # or
   flutter build ios --simulator
   ```
   
   **Option 2: Set up Development Team (For Device Testing)**
   1. Open Xcode: `open ios/Runner.xcworkspace`
   2. Select 'Runner' project → 'Runner' target
   3. Go to 'Signing & Capabilities' tab
   4. Sign in with your Apple ID in Xcode
   5. Select your Development Team
   6. Ensure 'Automatically manage signing' is checked
   7. Verify Bundle Identifier is unique
   
   **Option 3: Build Without Code Signing (Advanced)**
   ```bash
   flutter build ios --debug --no-codesign
   # Then manually sign in Xcode before deploying
   ```

2. **Build Failed: Did not find xcodeproj**:
   - This error occurs when the project was configured on Windows but built on macOS
   - **Solution**: Run `flutter clean` and `flutter pub get` on macOS
   - Regenerate iOS configuration: `cd ios && rm Flutter/Generated.xcconfig && cd .. && flutter pub get`
   - The Generated.xcconfig file will be recreated with correct macOS paths

3. **Flutter Path Issues**:
   - If you see Windows paths (C:\flutter\flutter) in Generated.xcconfig on macOS:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   ```

4. **Bluetooth Permission Denied**:
   - Ensure Info.plist permissions are properly set
   - Check iOS Settings > Privacy & Security > Bluetooth

5. **Camera Permission Denied**:
   - Verify NSCameraUsageDescription in Info.plist
   - Check iOS Settings > Privacy & Security > Camera

6. **Pod Install Fails**:
   ```bash
   cd ios
   pod repo update
   pod install --repo-update
   ```

7. **Build Errors**:
   - Clean build folder: `flutter clean`
   - Reinstall pods: `cd ios && pod install`
   - Update Flutter: `flutter upgrade`
   - Remove derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## Testing on iOS

### Simulator Testing:
- QR scanning requires physical device (camera needed)
- Bluetooth printing requires physical device
- UI and navigation can be tested on simulator

### Device Testing:
- Full functionality available
- Requires Apple Developer account for device provisioning
- Test with actual Bluetooth thermal printers

## Notes

- This project was configured on Windows but requires macOS for iOS builds
- All iOS-specific configurations are in place and ready for macOS development
- The app architecture supports both Android and iOS platforms
- Bluetooth printing functionality uses cross-platform packages