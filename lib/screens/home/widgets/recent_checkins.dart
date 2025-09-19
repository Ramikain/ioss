import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/checkin_provider.dart';
import '../../../providers/attendee_provider.dart';

class RecentCheckins extends StatelessWidget {
  const RecentCheckins({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckinProvider, AttendeeProvider>(
      builder: (context, checkinProvider, attendeeProvider, child) {
        final recentCheckins = checkinProvider.checkinRecords.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Check-ins',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (checkinProvider.checkinRecords.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to full check-in history
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (recentCheckins.isEmpty)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48.w,
                      color: AppTheme.textSecondaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Check-ins Yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start scanning QR codes or searching for attendees to check them in',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentCheckins.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1.h,
                    color: AppTheme.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final record = recentCheckins[index];
                    final attendee = attendeeProvider.attendees
                        .where((a) => a.id == record.attendeeId)
                        .firstOrNull;
                    
                    if (attendee == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.successColor.withOpacity(0.1),
                        child: Icon(
                          Icons.check,
                          color: AppTheme.successColor,
                          size: 20.w,
                        ),
                      ),
                      title: Text(
                        attendee.fullName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (attendee.company != null) ...[
                            Text(
                              attendee.company!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(record.checkedInAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (attendee.isVip)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.vipBackgroundColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'VIP',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.vipColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (attendee.isVip) SizedBox(width: 8.w),
                          if (!record.isPrinted)
                            Icon(
                              Icons.print_outlined,
                              color: AppTheme.warningColor,
                              size: 20.w,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}