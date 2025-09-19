import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendee.dart';
import '../models/event.dart';
import '../models/badge_template.dart';
import 'api_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  String? _connectedDeviceAddress;
  bool _isConnected = false;
  final ApiService _apiService = ApiService.instance;

  // Initialize printer service
  Future<void> initializePrinter() async {
    // Check if Bluetooth is enabled
    final isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      throw Exception('Bluetooth is not enabled');
    }
  }

  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }

  // Get paired Bluetooth devices
  Future<List<BluetoothInfo>> getPairedDevices() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  // Connect to printer
  Future<bool> connectToPrinter(String deviceAddress) async {
    try {
      final result = await PrintBluetoothThermal.connect(macPrinterAddress: deviceAddress);
      if (result) {
        _connectedDeviceAddress = deviceAddress;
        _isConnected = true;
        
        // Save connected device for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('connected_printer', deviceAddress);
      }
      return result;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  // Disconnect from printer
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      _connectedDeviceAddress = null;
      _isConnected = false;
      
      // Clear saved device
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('connected_printer');
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  // Check connection status
  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  // Print test page
  Future<bool> printTestPage() async {
    try {
      final connectionStatus = await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) {
        throw Exception('Printer not connected');
      }

      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      bytes += generator.text('TEST PRINT',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Printer is working correctly!');
      bytes += generator.text('Date: ${DateTime.now().toString().substring(0, 19)}');
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);
      bytes += generator.cut();

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      print('Print test error: $e');
      return false;
    }
  }

  // Print attendee badge
  Future<bool> printAttendeeBadge(Attendee attendee, Event event) async {
    try {
      final connectionStatus = await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) {
        throw Exception('Printer not connected');
      }

      // Try to get custom badge template from API
      BadgeTemplate? template = await _getBadgeTemplate(event.id, attendee.type);
      
      if (template != null && template.dimensions.isStandardBadgeSize) {
        return await _printCustomBadge(attendee, event, template);
      } else {
        // Fallback to default badge format
        return await _printDefaultBadge(attendee, event);
      }
    } catch (e) {
      print('Print badge error: $e');
      // Fallback to default badge on error
      return await _printDefaultBadge(attendee, event);
    }
  }

  Future<BadgeTemplate?> _getBadgeTemplate(String eventId, AttendeeType attendeeType) async {
    try {
      // Get templates for this event with 2.4x3.5 inch size
      final templates = await _apiService.getBadgeTemplates(
        eventId: eventId,
        labelSizeId: '2.4x3.5', // Standard badge size
      );
      
      // Find appropriate template based on attendee type
      BadgeTemplate? selectedTemplate;
      
      if (attendeeType == AttendeeType.vip) {
        final vipTemplates = templates.where((t) => t.isVipTemplate);
        selectedTemplate = vipTemplates.isNotEmpty ? vipTemplates.first : (templates.isNotEmpty ? templates.first : null);
      } else {
        final regularTemplates = templates.where((t) => !t.isVipTemplate);
        selectedTemplate = regularTemplates.isNotEmpty ? regularTemplates.first : (templates.isNotEmpty ? templates.first : null);
      }
      
      return selectedTemplate;
    } catch (e) {
      print('Error fetching badge template: $e');
      return null;
    }
  }

  Future<bool> _printCustomBadge(Attendee attendee, Event event, BadgeTemplate template) async {
    try {
      List<int> bytes = [];
      
      // Initialize printer with wider paper size for badge
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile); // Use 80mm for better badge printing
      
      // Set up badge dimensions (2.4x3.5 inches = 60.96x88.9mm)
      // For thermal printer, we'll scale appropriately
      
      // Print background color or image if specified
      if (template.backgroundImage != null) {
        final imageData = await _apiService.downloadImageAsBase64(template.backgroundImage!);
        if (imageData != null) {
          try {
            final imageBytes = base64Decode(imageData);
            final backgroundImage = img.decodeImage(imageBytes);
            if (backgroundImage != null) {
              bytes += generator.imageRaster(backgroundImage);
            }
          } catch (e) {
            print('Error printing background image: $e');
          }
        }
      }
      
      // Print logo if specified
      if (template.logoUrl != null) {
        final logoData = await _apiService.downloadImageAsBase64(template.logoUrl!);
        if (logoData != null) {
          try {
            final logoBytes = base64Decode(logoData);
            final logoImage = img.decodeImage(logoBytes);
            if (logoImage != null) {
              bytes += generator.imageRaster(logoImage, align: PosAlign.center);
            }
            bytes += generator.feed(1);
          } catch (e) {
            print('Error printing logo: $e');
          }
        }
      }
      
      // Process template fields
      for (final field in template.fields) {
        bytes += await _printBadgeField(field, attendee, event, generator);
      }
      
      // Add check-in timestamp
      final now = DateTime.now();
      bytes += generator.feed(1);
      bytes += generator.text(
        'Checked in: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
        ),
      );
      
      bytes += generator.feed(3);
      bytes += generator.cut();
      
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      print('Error printing custom badge: $e');
      return false;
    }
  }

  Future<List<int>> _printBadgeField(BadgeField field, Attendee attendee, Event event, Generator generator) async {
    List<int> bytes = [];
    
    switch (field.type) {
      case 'text':
        String content = _replaceFieldPlaceholders(field.content ?? '', attendee, event);
        
        PosTextSize textSize = PosTextSize.size1;
        if (field.style.fontSize != null) {
          if (field.style.fontSize! > 20) {
            textSize = PosTextSize.size2;
          }
        }
        
        bytes += generator.text(
          content,
          styles: PosStyles(
            align: PosAlign.center,
            height: textSize,
            width: textSize,
            bold: field.style.fontWeight == 'bold',
          ),
        );
        bytes += generator.feed(1);
        break;
        
      case 'qr':
        // Generate QR code with attendee ID or custom data
        String qrData = attendee.id;
        if (field.content?.isNotEmpty == true) {
          qrData = _replaceFieldPlaceholders(field.content!, attendee, event);
        }
        
        bytes += generator.qrcode(
          qrData,
          size: QRSize.size6,
          cor: QRCorrection.M,
          align: PosAlign.center,
        );
        bytes += generator.feed(1);
        break;
        
      case 'image':
        if (field.content?.isNotEmpty == true) {
          final imageData = await _apiService.downloadImageAsBase64(field.content!);
          if (imageData != null) {
            try {
              final imageBytes = base64Decode(imageData);
              final fieldImage = img.decodeImage(imageBytes);
              if (fieldImage != null) {
                bytes += generator.imageRaster(fieldImage, align: PosAlign.center);
              }
              bytes += generator.feed(1);
            } catch (e) {
              print('Error printing field image: $e');
            }
          }
        }
        break;
        
      default:
        // Handle other field types as text
        String content = _replaceFieldPlaceholders(field.content ?? field.type, attendee, event);
        bytes += generator.text(
          content,
          styles: const PosStyles(align: PosAlign.center),
        );
        bytes += generator.feed(1);
    }
    
    return bytes;
  }

  String _replaceFieldPlaceholders(String content, Attendee attendee, Event event) {
    return content
        .replaceAll('{{attendee.name}}', attendee.fullName)
        .replaceAll('{{attendee.firstName}}', attendee.firstName)
        .replaceAll('{{attendee.lastName}}', attendee.lastName)
        .replaceAll('{{attendee.email}}', attendee.email)
        .replaceAll('{{attendee.company}}', attendee.company ?? '')
        .replaceAll('{{attendee.jobTitle}}', attendee.jobTitle ?? '')
        .replaceAll('{{attendee.type}}', attendee.type.toString().split('.').last)
        .replaceAll('{{event.name}}', event.name)
        .replaceAll('{{event.location}}', event.location ?? '')
        .replaceAll('{{event.date}}', event.startDate.toString().split(' ')[0]);
  }

  Future<bool> _printDefaultBadge(Attendee attendee, Event event) async {
    try {
      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      // Header
      bytes += generator.text('EVENT BADGE',
          styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);
      
      // Event name
      bytes += generator.text(event.name,
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.feed(1);
      
      // Attendee info
      bytes += generator.text('NAME:', styles: const PosStyles(bold: true));
      bytes += generator.text('${attendee.firstName} ${attendee.lastName}', 
          styles: const PosStyles(height: PosTextSize.size2));
      bytes += generator.feed(1);
      
      if (attendee.email.isNotEmpty) {
        bytes += generator.text('EMAIL:', styles: const PosStyles(bold: true));
        bytes += generator.text(attendee.email);
        bytes += generator.feed(1);
      }
      
      if (attendee.company != null && attendee.company!.isNotEmpty) {
        bytes += generator.text('COMPANY:', styles: const PosStyles(bold: true));
        bytes += generator.text(attendee.company!);
        bytes += generator.feed(1);
      }
      
      if (attendee.jobTitle != null && attendee.jobTitle!.isNotEmpty) {
        bytes += generator.text('TITLE:', styles: const PosStyles(bold: true));
        bytes += generator.text(attendee.jobTitle!);
        bytes += generator.feed(1);
      }
      
      // Footer
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Check-in Time:');
      bytes += generator.text(DateTime.now().toString().substring(0, 19));
      bytes += generator.feed(2);
      bytes += generator.cut();

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      print('Print default badge error: $e');
      return false;
    }
  }

  // Print event summary
  Future<bool> printEventSummary(List<Attendee> attendees) async {
    try {
      final connectionStatus = await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) {
        throw Exception('Printer not connected');
      }

      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      // Header
      bytes += generator.text('EVENT SUMMARY',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);
      
      // Statistics
      final checkedInCount = attendees.where((a) => a.status == AttendeeStatus.checkedIn).length;
      bytes += generator.text('Total Attendees: ${attendees.length}');
      bytes += generator.text('Checked In: $checkedInCount');
      bytes += generator.text('Not Checked In: ${attendees.length - checkedInCount}');
      bytes += generator.feed(1);
      
      // Recent check-ins (last 10)
      final recentCheckIns = attendees
          .where((a) => a.status == AttendeeStatus.checkedIn && a.checkedInAt != null)
          .toList()
        ..sort((a, b) => b.checkedInAt!.compareTo(a.checkedInAt!));
      
      if (recentCheckIns.isNotEmpty) {
        bytes += generator.text('RECENT CHECK-INS:',
            styles: const PosStyles(bold: true));
        bytes += generator.text('--------------------------------');
        
        for (int i = 0; i < recentCheckIns.length && i < 10; i++) {
          final attendee = recentCheckIns[i];
          bytes += generator.text('${i + 1}. ${attendee.firstName} ${attendee.lastName}');
          if (attendee.checkedInAt != null) {
            bytes += generator.text('   ${attendee.checkedInAt.toString().substring(11, 19)}');
          }
        }
      }
      
      // Footer
      bytes += generator.text('================================',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Generated: ${DateTime.now().toString().substring(0, 19)}',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);
      bytes += generator.cut();

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      print('Print summary error: $e');
      return false;
    }
  }

  // Get last connected device
  Future<String?> getLastConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connected_printer');
  }

  // Auto-reconnect to last device
  Future<bool> autoReconnect() async {
    final lastDevice = await getLastConnectedDevice();
    if (lastDevice != null) {
      return await connectToPrinter(lastDevice);
    }
    return false;
  }

  // Save printer preferences
  Future<void> savePrinterPreferences(String name, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_printer_name', name);
    await prefs.setString('saved_printer_address', address);
  }

  // Load saved printer
  Future<Map<String, String>?> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('saved_printer_name');
    final address = prefs.getString('saved_printer_address');
    
    if (name != null && address != null) {
      return {'name': name, 'address': address};
    }
    return null;
  }

  // Clear saved printer
  Future<void> clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_printer_name');
    await prefs.remove('saved_printer_address');
    await prefs.remove('connected_printer');
  }

  // Start scanning for Bluetooth devices
  Future<void> startScanning(Function(BluetoothInfo) onDeviceFound) async {
    // Note: print_bluetooth_thermal doesn't have active scanning
    // We'll use the paired devices list instead
    final devices = await getPairedDevices();
    for (final device in devices) {
      onDeviceFound(device);
    }
  }

  // Stop scanning (placeholder for compatibility)
  Future<void> stopScanning() async {
    // No-op since we're using paired devices list
  }

  // Test print functionality
  Future<bool> testPrint() async {
    return await printTestPage();
  }

  // Enable Bluetooth
  Future<bool> enableBluetooth() async {
    return await PrintBluetoothThermal.bluetoothEnabled;
  }
}