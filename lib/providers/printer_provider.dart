import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/attendee.dart';
import '../models/event.dart';
import '../models/bluetooth_printer.dart';
import '../services/print_service.dart';

class PrinterProvider extends ChangeNotifier {
  final PrintService _printService = PrintService();
  
  List<BluetoothPrinter> _availablePrinters = [];
  BluetoothPrinter? _selectedPrinter;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isPrinting = false;
  String? _errorMessage;
  bool _bluetoothEnabled = false;

  // Getters
  List<BluetoothPrinter> get availablePrinters => _availablePrinters;
  BluetoothPrinter? get selectedPrinter => _selectedPrinter;
  BluetoothPrinter? get connectedPrinter => _selectedPrinter?.isConnected == true ? _selectedPrinter : null;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isPrinting => _isPrinting;
  String? get errorMessage => _errorMessage;
  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get isBluetoothEnabled => _bluetoothEnabled;
  bool get isLoading => _isConnecting || _isPrinting;
  bool get hasSelectedPrinter => _selectedPrinter != null;

  // Initialize printer provider
  Future<void> initialize() async {
    try {
      await _checkBluetoothStatus();
      await _loadSavedPrinter();
    } catch (e) {
      _errorMessage = 'Failed to initialize printer: $e';
      notifyListeners();
    }
  }

  // Check Bluetooth status
  Future<void> _checkBluetoothStatus() async {
    try {
      _bluetoothEnabled = await _printService.isBluetoothEnabled();
      notifyListeners();
    } catch (e) {
      _bluetoothEnabled = false;
      _errorMessage = 'Failed to check Bluetooth status: $e';
      notifyListeners();
    }
  }

  // Enable Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      _errorMessage = null;
      final enabled = await _printService.enableBluetooth();
      _bluetoothEnabled = enabled;
      notifyListeners();
      return enabled;
    } catch (e) {
      _errorMessage = 'Failed to enable Bluetooth: $e';
      notifyListeners();
      return false;
    }
  }

  // Start scanning for printers
  Future<void> startScanning() async {
    if (_isScanning) return;
    
    try {
      _isScanning = true;
      _errorMessage = null;
      _availablePrinters.clear();
      notifyListeners();

      if (!_bluetoothEnabled) {
        final enabled = await enableBluetooth();
        if (!enabled) {
          throw Exception('Bluetooth is required for printer scanning');
        }
      }

      await _printService.startScanning((printer) {
        final bluetoothPrinter = BluetoothPrinter(
          name: printer.name ?? 'Unknown Printer',
          address: printer.macAdress ?? '',
          rssi: 0, // BluetoothInfo doesn't have RSSI
        );
        
        if (!_availablePrinters.contains(bluetoothPrinter)) {
          _availablePrinters.add(bluetoothPrinter);
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = 'Failed to scan for printers: $e';
      notifyListeners();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // Stop scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    
    try {
      await _printService.stopScanning();
    } catch (e) {
      _errorMessage = 'Failed to stop scanning: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // Connect to printer
  Future<bool> connectToPrinter(BluetoothPrinter printer) async {
    if (_isConnecting) return false;
    
    try {
      _isConnecting = true;
      _errorMessage = null;
      notifyListeners();

      final connected = await _printService.connectToPrinter(printer.address);
      
      if (connected) {
        _selectedPrinter = BluetoothPrinter(
          name: printer.name,
          address: printer.address,
          isConnected: true,
          rssi: printer.rssi,
        );
        await _savePrinter(printer);
      } else {
        _errorMessage = 'Failed to connect to ${printer.name}';
      }
      
      notifyListeners();
      return connected;
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      notifyListeners();
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  // Disconnect from printer
  Future<void> disconnectPrinter() async {
    try {
      if (_selectedPrinter != null) {
        await _printService.disconnect();
        _selectedPrinter = null;
        await _clearSavedPrinter();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to disconnect: $e';
      notifyListeners();
    }
  }

  // Print attendee badge
  Future<bool> printAttendeeBadge(Attendee attendee, Event event) async {
    if (_selectedPrinter == null || !_selectedPrinter!.isConnected) {
      _errorMessage = 'No printer connected';
      notifyListeners();
      return false;
    }

    try {
      _isPrinting = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _printService.printAttendeeBadge(attendee, event);
      
      if (!success) {
        _errorMessage = 'Failed to print badge for ${attendee.firstName} ${attendee.lastName}';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Print error: $e';
      return false;
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }

  // Test print
  Future<bool> testPrint() async {
    if (_selectedPrinter == null || !_selectedPrinter!.isConnected) {
      _errorMessage = 'No printer connected';
      notifyListeners();
      return false;
    }

    try {
      _isPrinting = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _printService.testPrint();
      
      if (!success) {
        _errorMessage = 'Test print failed';
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Test print error: $e';
      return false;
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }

  // Save printer to preferences
  Future<void> _savePrinter(BluetoothPrinter printer) async {
    try {
      await _printService.savePrinterPreferences(printer.name, printer.address);
    } catch (e) {
      debugPrint('Failed to save printer preferences: $e');
    }
  }

  // Load saved printer
  Future<void> _loadSavedPrinter() async {
    try {
      final savedPrinter = await _printService.loadSavedPrinter();
      if (savedPrinter != null) {
        _selectedPrinter = BluetoothPrinter(
          name: savedPrinter['name'] ?? 'Saved Printer',
          address: savedPrinter['address'] ?? '',
          isConnected: false,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load saved printer: $e');
    }
  }

  // Clear saved printer
  Future<void> _clearSavedPrinter() async {
    try {
      await _printService.clearSavedPrinter();
    } catch (e) {
      debugPrint('Failed to clear saved printer: $e');
    }
  }

  // Public methods for UI
  Future<void> checkBluetoothStatus() async {
    await _checkBluetoothStatus();
  }

  Future<void> loadSavedPrinter() async {
    await _loadSavedPrinter();
  }

  Future<void> clearSavedPrinter() async {
    await _clearSavedPrinter();
    _selectedPrinter = null;
    notifyListeners();
  }



  Future<void> disconnect() async {
    try {
      await _printService.disconnect();
      if (_selectedPrinter != null) {
        _selectedPrinter = BluetoothPrinter(
          name: _selectedPrinter!.name,
          address: _selectedPrinter!.address,
          isConnected: false,
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Disconnect error: $e';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }
}