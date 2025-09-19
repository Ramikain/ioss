import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/attendee.dart';
import '../../../providers/checkin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/attendee_provider.dart';
import '../../../providers/printer_provider.dart';

class AttendeeDetailsDialog extends StatefulWidget {
  final Attendee attendee;

  const AttendeeDetailsDialog({
    super.key,
    required this.attendee,
  });

  @override
  State<AttendeeDetailsDialog> createState() => _AttendeeDetailsDialogState();
}

class _AttendeeDetailsDialogState extends State<AttendeeDetailsDialog> {
  final _notesController = TextEditingController();
  bool _printBadge = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkInAttendee() async {
    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final checkinProvider = context.read<CheckinProvider>();
    final attendeeProvider = context.read<AttendeeProvider>();

    if (authProvider.userId == null || !eventProvider.hasSelectedEvent) {
      return;
    }

    final success = await checkinProvider.checkInAttendee(
      attendee: widget.attendee,
      staffId: authProvider.userId!,
      eventId: eventProvider.selectedEvent!.id,
      printBadge: _printBadge,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success && mounted) {
      // Update the attendee in the provider
      final updatedAttendee = widget.attendee.copyWith(
        status: AttendeeStatus.checkedIn,
        checkedInAt: DateTime.now(),
        checkedInBy: authProvider.userId,
      );
      await attendeeProvider.updateAttendee(updatedAttendee);

      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully checked in ${widget.attendee.fullName}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400.w,
          maxHeight: 600.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: widget.attendee.isVip
                    ? AppTheme.vipBackgroundColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.w,
                    backgroundColor: widget.attendee.isCheckedIn
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    child: Icon(
                      widget.attendee.isCheckedIn ? Icons.check : Icons.person,
                      color: Colors.white,
                      size: 30.w,
                    ),
                  ),
                  
                  SizedBox(width: 16.w),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.attendee.fullName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.attendee.isVip) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.vipColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'VIP',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: widget.attendee.isCheckedIn
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.attendee.isCheckedIn
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: widget.attendee.isCheckedIn
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            widget.attendee.isCheckedIn
                                ? 'Already Checked In'
                                : 'Ready to Check In',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: widget.attendee.isCheckedIn
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (widget.attendee.isCheckedIn && widget.attendee.checkedInAt != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Checked in on ${DateFormat('MMM dd, yyyy • HH:mm').format(widget.attendee.checkedInAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 20.h),
                    
                    // Details
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: widget.attendee.email,
                    ),
                    
                    if (widget.attendee.phone != null) ...[
                      SizedBox(height: 12.h),
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: widget.attendee.phone!,
                      ),
                    ],
                    
                    if (widget.attendee.company != null) ...[
                      SizedBox(height: 12.h),
                      _DetailRow(
                        icon: Icons.business_outlined,
                        label: 'Company',
                        value: widget.attendee.company!,
                      ),
                    ],
                    
                    if (widget.attendee.jobTitle != null) ...[
                      SizedBox(height: 12.h),
                      _DetailRow(
                        icon: Icons.work_outline,
                        label: 'Job Title',
                        value: widget.attendee.jobTitle!,
                      ),
                    ],
                    
                    SizedBox(height: 12.h),
                    _DetailRow(
                      icon: Icons.qr_code,
                      label: 'QR Code',
                      value: widget.attendee.qrCode,
                    ),
                    
                    if (!widget.attendee.isCheckedIn) ...[
                      SizedBox(height: 20.h),
                      
                      // Notes
                      Text(
                        'Notes (Optional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Add any notes about this check-in...',
                        ),
                        maxLines: 2,
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Print badge option
                      CheckboxListTile(
                        value: _printBadge,
                        onChanged: (value) {
                          setState(() {
                            _printBadge = value ?? true;
                          });
                        },
                        title: const Text('Print badge after check-in'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            if (!widget.attendee.isCheckedIn) ...[
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Consumer<CheckinProvider>(
                  builder: (context, checkinProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkinProvider.isProcessing ? null : _checkInAttendee,
                        child: checkinProvider.isProcessing
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Check In Attendee'),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<PrinterProvider>(
                        builder: (context, printerProvider, child) {
                          return ElevatedButton.icon(
                            onPressed: printerProvider.connectedPrinter == null
                                ? null
                                : () async {
                                    final eventProvider = context.read<EventProvider>();
                                    if (eventProvider.selectedEvent == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('No event selected'),
                                          backgroundColor: AppTheme.errorColor,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    final success = await printerProvider.printAttendeeBadge(
                                      widget.attendee, 
                                      eventProvider.selectedEvent!,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Badge printed successfully!'
                                                : printerProvider.errorMessage ?? 'Failed to print badge',
                                          ),
                                          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                                        ),
                                      );
                                    }
                                  },
                            icon: Icon(Icons.print),
                            label: Text(
                              printerProvider.connectedPrinter == null
                                  ? 'No Printer Connected'
                                  : 'Print Badge',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.w,
          color: AppTheme.textSecondaryColor,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}