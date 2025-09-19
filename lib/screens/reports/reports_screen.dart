import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/event_provider.dart';
import '../../providers/attendee_provider.dart';
import '../../providers/checkin_provider.dart';
import '../../services/printing_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    
    if (!eventProvider.hasSelectedEvent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
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
                'Please select an event to view reports',
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
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventProvider.selectedEvent!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (eventProvider.selectedEvent!.venue.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      eventProvider.selectedEvent!.venue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Statistics
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Consumer2<AttendeeProvider, CheckinProvider>(
              builder: (context, attendeeProvider, checkinProvider, child) {
                return Column(
                  children: [
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Attendees',
                          value: attendeeProvider.totalAttendees.toString(),
                          icon: Icons.people_outline,
                          color: AppTheme.primaryColor,
                        ),
                        _StatCard(
                          title: 'Checked In',
                          value: attendeeProvider.checkedInCount.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppTheme.successColor,
                        ),
                        _StatCard(
                          title: 'VIP Attendees',
                          value: attendeeProvider.vipCount.toString(),
                          icon: Icons.star_outline,
                          color: AppTheme.vipColor,
                        ),
                        _StatCard(
                          title: 'Check-in Rate',
                          value: '${attendeeProvider.checkinRate.toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: AppTheme.warningColor,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Actions
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Print Reports
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.print,
                                  color: AppTheme.primaryColor,
                                  size: 24.w,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Print Reports',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await PrintingService.instance.printCheckinReport(
                                          eventProvider.selectedEvent!,
                                          attendeeProvider.attendees,
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Print failed: ${e.toString()}'),
                                              backgroundColor: AppTheme.errorColor,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.assignment),
                                    label: const Text('Check-in Report'),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      try {
                                        await PrintingService.instance.printMultipleBadges(
                                          attendeeProvider.checkedInAttendees,
                                          eventProvider.selectedEvent!,
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Print failed: ${e.toString()}'),
                                              backgroundColor: AppTheme.errorColor,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.badge),
                                    label: const Text('All Badges'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Export Data
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.download,
                                  color: AppTheme.secondaryColor,
                                  size: 24.w,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Export Data',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              'Export attendee and check-in data for external analysis',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Implement CSV export
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Export functionality coming soon'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.table_chart),
                                label: const Text('Export to CSV'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
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