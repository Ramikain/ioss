import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../services/print_service.dart';
import '../models/attendee.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isScanning = false;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  final PrintService _printService = PrintService();

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  void _checkConnectionStatus() async {
    final isConnected = await BluetoothThermalPrinter.connectionStatus;
    setState(() {
      _isConnected = isConnected == "true";
    });
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      // Check if Bluetooth is enabled
      final isEnabled = await _printService.isBluetoothEnabled();
      if (!isEnabled) {
        _showErrorDialog('Please enable Bluetooth first');
        setState(() => _isScanning = false);
        return;
      }

      final devices = await _printService.getPairedDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      _showErrorDialog('Failed to start scanning: $e');
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _stopScan() async {
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothInfo device) async {
    try {
      final result = await _printService.connectToPrinter(device.macAdress);
      setState(() {
        _isConnected = result;
        _selectedDevice = result ? device : null;
        _connectionStatus = result ? 'Connected to ${device.name}' : 'Disconnected';
      });
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.name}')),
        );
      } else {
        _showErrorDialog('Failed to connect to ${device.name}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  void _disconnectDevice() async {
    try {
      await _printService.disconnect();
      setState(() {
        _isConnected = false;
        _selectedDevice = null;
        _connectionStatus = 'Disconnected';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from printer')),
      );
    } catch (e) {
      _showErrorDialog('Disconnect error: $e');
    }
  }

  void _testPrint() async {
    if (!_isConnected) {
      _showErrorDialog('Please connect to a printer first');
      return;
    }

    _showLoadingDialog('Printing test page...');

    try {
      await _printService.printTestPage();
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessDialog('Test print completed successfully');
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Print error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionStatus,
                            style: TextStyle(
                              color: _isConnected ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? _stopScan : _startScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isScanning ? 'Stop Scan' : 'Scan for Printers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isConnected) ..[
                  ElevatedButton.icon(
                    onPressed: _testPrint,
                    icon: const Icon(Icons.print),
                    label: const Text('Test Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _disconnectDevice,
                    icon: const Icon(Icons.bluetooth_disabled),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Device List
            const Text(
              'Available Printers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _devices.isEmpty
                  ? const Center(
                      child: Text(
                        'No printers found.\nTap "Scan for Printers" to search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isConnected = _isConnected && _selectedDevice?.name == device.name;
                        
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.print,
                              color: isConnected ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              device.name ?? 'Unknown Device',
                              style: TextStyle(
                                fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(device.macAdress),
                            trailing: isConnected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : TextButton(
                                    onPressed: () => _connectToDevice(device),
                                    child: const Text('Connect'),
                                  ),
                            onTap: isConnected ? null : () => _connectToDevice(device),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}