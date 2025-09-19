import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/attendee_provider.dart';
import '../../../providers/checkin_provider.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AttendeeProvider, CheckinProvider>(
      builder: (context, attendeeProvider, checkinProvider, child) {
        return Column(
          children: [
            // First row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Attendees',
                    value: attendeeProvider.totalAttendees.toString(),
                    icon: Icons.people_outline,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StatCard(
                    title: 'Checked In',
                    value: attendeeProvider.checkedInCount.toString(),
                    icon: Icons.check_circle_outline,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Second row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'VIP Attendees',
                    value: attendeeProvider.vipCount.toString(),
                    icon: Icons.star_outline,
                    color: AppTheme.vipColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StatCard(
                    title: 'Check-in Rate',
                    value: '${attendeeProvider.checkinRate.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Third row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Today\'s Check-ins',
                    value: checkinProvider.todayCheckinsCount.toString(),
                    icon: Icons.today_outlined,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StatCard(
                    title: 'Unprinted Badges',
                    value: checkinProvider.unprintedCount.toString(),
                    icon: Icons.print_outlined,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.w,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}