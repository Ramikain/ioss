import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // iOS-specific configurations for Fresh Check-in App
    // Enable background modes if needed for Bluetooth
    if #available(iOS 13.0, *) {
      // Configure for iOS 13+ if needed
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle app lifecycle for Bluetooth connections
  override func applicationWillResignActive(_ application: UIApplication) {
    // Called when the app is about to move from active to inactive state
    super.applicationWillResignActive(application)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Called when the app becomes active
    super.applicationDidBecomeActive(application)
  }
}
