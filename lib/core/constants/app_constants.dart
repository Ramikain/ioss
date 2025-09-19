class AppConstants {
  static const String appName = 'Event Check-in';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://lightslategray-donkey-866736.hostingersite.com';
  static const String apiVersion = 'api';
  
  // Database
  static const String databaseName = 'event_checkin.db';
  static const int databaseVersion = 1;
  
  // Shared Preferences Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keySelectedEventId = 'selected_event_id';
  static const String keyUserRole = 'user_role';
  
  // QR Code
  static const String qrCodePrefix = 'EVENT_';
  
  // Printing
  static const String printerName = 'Default Printer';
  static const double badgeWidth = 4.0; // inches
  static const double badgeHeight = 3.0; // inches
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}