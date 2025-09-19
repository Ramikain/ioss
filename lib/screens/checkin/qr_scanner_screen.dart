import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/qr_scanner_overlay.dart';
import '../../providers/event_provider.dart';
import '../../providers/attendee_provider.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/printer_provider.dart';
import '../printer/printer_screen.dart';
import 'widgets/attendee_details_dialog.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (!isProcessing && barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processQrCode(barcodes.first.rawValue!);
    }
  }

  Future<void> _processQrCode(String qrCode) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
    });

    try {
      final attendeeProvider = context.read<AttendeeProvider>();
      final attendee = await attendeeProvider.getAttendeeByQrCode(qrCode);

      if (attendee == null) {
        _showErrorDialog('Attendee not found', 'No attendee found with this QR code.');
        return;
      }

      final eventProvider = context.read<EventProvider>();
      if (attendee.eventId != eventProvider.selectedEvent?.id) {
        _showErrorDialog('Wrong Event', 'This attendee is registered for a different event.');
        return;
      }

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AttendeeDetailsDialog(attendee: attendee),
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process QR code: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    
    if (!eventProvider.hasSelectedEvent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64.w,
                color: AppTheme.textSecondaryColor,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Event Selected',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please select an event before scanning QR codes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.torchState,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(state == TorchState.on ? Icons.flash_on : Icons.flash_off),
                onPressed: _toggleFlash,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            overlay: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: AppTheme.primaryColor,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250.w,
                ),
              ),
            ),
          ),
          
          // Top overlay with event info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    eventProvider.selectedEventName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Position the QR code within the frame to scan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom overlay with instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isProcessing) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Processing QR code...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 24.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Ready to scan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<PrinterProvider>(
        builder: (context, printerProvider, child) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrinterScreen(),
                ),
              );
            },
            backgroundColor: printerProvider.connectedPrinter != null 
                ? AppTheme.successColor 
                : AppTheme.primaryColor,
            child: Icon(
              Icons.print,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}