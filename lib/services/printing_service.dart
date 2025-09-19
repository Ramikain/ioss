import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


import '../models/attendee.dart';
import '../models/event.dart';
import '../core/constants/app_constants.dart';
import 'bluetooth_printing_service.dart';

enum PrinterType { pdf, bluetooth }

class PrintingService {
  static final PrintingService _instance = PrintingService._internal();
  static PrintingService get instance => _instance;
  PrintingService._internal();

  PrinterType _preferredPrinterType = PrinterType.bluetooth;
  
  PrinterType get preferredPrinterType => _preferredPrinterType;
  
  void setPreferredPrinterType(PrinterType type) {
    _preferredPrinterType = type;
  }

  Future<bool> isAvailable() async {
    if (_preferredPrinterType == PrinterType.bluetooth) {
      final bluetoothService = BluetoothPrintingService();
      return await bluetoothService.isBluetoothEnabled;
    }
    return true; // Simplified for web testing
  }
  
  Future<bool> isBluetoothPrinterConnected() async {
    final bluetoothService = BluetoothPrintingService();
    return bluetoothService.isConnected;
  }
  
  Future<String> getPrinterStatus() async {
    if (_preferredPrinterType == PrinterType.bluetooth) {
      return 'Bluetooth printing available (simplified for web)';
    }
    
    return 'PDF printing available (simplified for web)';
  }

  Future<List<dynamic>> getAvailablePrinters() async {
    return []; // Simplified for web testing
  }

  Future<void> printAttendeeBadge(Attendee attendee, Event event) async {
    if (_preferredPrinterType == PrinterType.bluetooth) {
      // Try Bluetooth printing first
      try {
        final bluetoothService = BluetoothPrintingService();
        if (bluetoothService.isConnected) {
          await bluetoothService.printAttendeeBadge(attendee, event);
          return;
        }
      } catch (e) {
        // Fall back to PDF printing if Bluetooth fails
        print('Bluetooth printing failed, falling back to PDF: $e');
      }
    }
    
    // PDF printing (simplified for web)
    print('Would generate PDF badge for ${attendee.fullName}');
  }

  Future<void> printMultipleBadges(List<Attendee> attendees, Event event) async {
    print('Would generate PDF badges for ${attendees.length} attendees');
  }

  Future<void> printCheckinReport(Event event, List<Attendee> attendees) async {
    print('Would generate check-in report for ${event.name}');
  }

  Future<pw.Document> _generateAttendeeBadge(Attendee attendee, Event event) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          AppConstants.badgeWidth * PdfPageFormat.inch,
          AppConstants.badgeHeight * PdfPageFormat.inch,
        ),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Event name
                pw.Text(
                  event.name,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                
                // Attendee name
                pw.Text(
                  attendee.fullName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                
                // Company and job title
                if (attendee.company != null) ...[
                  pw.Text(
                    attendee.company!,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                if (attendee.jobTitle != null) ...[
                  pw.Text(
                    attendee.jobTitle!,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.Spacer(),
                
                // VIP indicator
                if (attendee.isVip) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'VIP',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                ],
                
                // QR Code
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: attendee.qrCode,
                  width: 60,
                  height: 60,
                ),
                pw.SizedBox(height: 4),
                
                // QR Code text
                pw.Text(
                  attendee.qrCode,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    return pdf;
  }

  Future<pw.Document> _generateMultipleBadges(List<Attendee> attendees, Event event) async {
    final pdf = pw.Document();
    
    // Print 2 badges per page (2x1 layout)
    for (int i = 0; i < attendees.length; i += 2) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // First badge
                pw.Expanded(
                  child: _buildBadgeWidget(attendees[i], event),
                ),
                pw.SizedBox(height: 20),
                
                // Second badge (if exists)
                if (i + 1 < attendees.length)
                  pw.Expanded(
                    child: _buildBadgeWidget(attendees[i + 1], event),
                  )
                else
                  pw.Expanded(child: pw.Container()),
              ],
            );
          },
        ),
      );
    }
    
    return pdf;
  }

  pw.Widget _buildBadgeWidget(Attendee attendee, Event event) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            event.name,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            attendee.fullName,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          if (attendee.company != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              attendee.company!,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
          pw.Spacer(),
          if (attendee.isVip) ...[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.red100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'VIP',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
          ],
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: attendee.qrCode,
            width: 60,
            height: 60,
          ),
        ],
      ),
    );
  }

  Future<pw.Document> _generateCheckinReport(Event event, List<Attendee> attendees) async {
    final pdf = pw.Document();
    
    final checkedInAttendees = attendees.where((a) => a.isCheckedIn).toList();
    final notCheckedInAttendees = attendees.where((a) => !a.isCheckedIn).toList();
    
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Check-in Report: ${event.name}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Attendees: ${attendees.length}'),
                  pw.Text('Checked In: ${checkedInAttendees.length}'),
                  pw.Text('Not Checked In: ${notCheckedInAttendees.length}'),
                  pw.Text('Check-in Rate: ${((checkedInAttendees.length / attendees.length) * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Checked-in attendees
            pw.Text(
              'Checked-in Attendees',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Email', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Company', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Check-in Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                
                // Data rows
                ...checkedInAttendees.map((attendee) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(attendee.fullName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(attendee.email),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(attendee.company ?? ''),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        attendee.checkedInAt?.toString().substring(0, 16) ?? '',
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );
    
    return pdf;
  }
}