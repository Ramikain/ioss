import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/printer_provider.dart';
import '../../models/bluetooth_printer.dart';
import '../../theme/app_colors.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({Key? key}) : super(key: key);

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePrinter();
    });
  }

  Future<void> _initializePrinter() async {
    final printerProvider = Provider.of<PrinterProvider>(context, listen: false);
    await printerProvider.checkBluetoothStatus();
    await printerProvider.loadSavedPrinter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Printer Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PrinterProvider>(
        builder: (context, printerProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBluetoothStatus(printerProvider),
                SizedBox(height: 20.h),
                _buildCurrentPrinter(printerProvider),
                SizedBox(height: 20.h),
                _buildScanSection(printerProvider),
                SizedBox(height: 20.h),
                _buildAvailablePrinters(printerProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBluetoothStatus(PrinterProvider printerProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  color: printerProvider.isBluetoothEnabled ? AppColors.success : AppColors.error,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Bluetooth Status',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              printerProvider.isBluetoothEnabled ? 'Enabled' : 'Disabled',
              style: TextStyle(
                fontSize: 14.sp,
                color: printerProvider.isBluetoothEnabled ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!printerProvider.isBluetoothEnabled) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: printerProvider.isLoading ? null : () async {
                    await printerProvider.enableBluetooth();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Enable Bluetooth',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPrinter(PrinterProvider printerProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.print,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Current Printer',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (printerProvider.connectedPrinter != null) ...[
              _buildPrinterTile(
                printerProvider.connectedPrinter!,
                isConnected: true,
                onAction: () async {
                  await printerProvider.disconnect();
                },
                actionLabel: 'Disconnect',
                actionColor: AppColors.error,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: printerProvider.isLoading ? null : () async {
                        await printerProvider.testPrint();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                printerProvider.errorMessage ?? 'Test print sent successfully!',
                              ),
                              backgroundColor: printerProvider.errorMessage != null 
                                  ? AppColors.error 
                                  : AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Test Print',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await printerProvider.clearSavedPrinter();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printer preferences cleared'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No printer connected',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanSection(PrinterProvider printerProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Scan for Printers',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (!printerProvider.isBluetoothEnabled || printerProvider.isLoading) 
                    ? null 
                    : () async {
                        if (printerProvider.isScanning) {
                          await printerProvider.stopScanning();
                        } else {
                          await printerProvider.startScanning();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: printerProvider.isScanning ? AppColors.error : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (printerProvider.isScanning) ...[
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      printerProvider.isScanning ? 'Stop Scanning' : 'Start Scanning',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePrinters(PrinterProvider printerProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Available Printers',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (printerProvider.availablePrinters.isEmpty) ...[
              Text(
                printerProvider.isScanning 
                    ? 'Scanning for printers...' 
                    : 'No printers found. Start scanning to discover printers.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: printerProvider.availablePrinters.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final printer = printerProvider.availablePrinters[index];
                  final isConnected = printerProvider.connectedPrinter?.address == printer.address;
                  
                  return _buildPrinterTile(
                    printer,
                    isConnected: isConnected,
                    onAction: isConnected 
                        ? null 
                        : () async {
                            await printerProvider.connectToPrinter(printer);
                            if (mounted && printerProvider.errorMessage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Connected to ${printer.name}'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                    actionLabel: 'Connect',
                    actionColor: AppColors.primary,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterTile(
    BluetoothPrinter printer, {
    required bool isConnected,
    VoidCallback? onAction,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isConnected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.print,
            color: isConnected ? AppColors.primary : AppColors.textSecondary,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  printer.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  printer.address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isConnected) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: actionColor,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final printerProvider = Provider.of<PrinterProvider>(context, listen: false);
    printerProvider.stopScanning();
    super.dispose();
  }
}