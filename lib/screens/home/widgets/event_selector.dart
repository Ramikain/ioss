import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/event.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/attendee_provider.dart';
import '../../../providers/checkin_provider.dart';

class EventSelector extends StatelessWidget {
  const EventSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (eventProvider.events.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48.w,
                  color: AppTheme.textSecondaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Events Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please contact your administrator to add events',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

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
                children: [
                  Icon(
                    Icons.event,
                    color: AppTheme.primaryColor,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Select Event',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              DropdownButtonFormField<Event>(
                value: eventProvider.selectedEvent,
                decoration: const InputDecoration(
                  hintText: 'Choose an event...',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                items: eventProvider.events.map((event) {
                  return DropdownMenuItem<Event>(
                    value: event,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.venue.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            '${event.venue} • ${DateFormat('MMM dd, yyyy').format(event.startDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Event? event) async {
                  if (event != null) {
                    await eventProvider.selectEvent(event);
                    
                    // Load attendees and check-in records for the selected event
                    if (context.mounted) {
                      final attendeeProvider = context.read<AttendeeProvider>();
                      final checkinProvider = context.read<CheckinProvider>();
                      
                      await attendeeProvider.loadAttendees(event.id);
                      await checkinProvider.loadCheckinRecords(event.id);
                    }
                  }
                },
              ),
              
              if (eventProvider.selectedEvent != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventProvider.selectedEvent!.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (eventProvider.selectedEvent!.venue.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.w,
                              color: AppTheme.textSecondaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                eventProvider.selectedEvent!.venue,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16.w,
                            color: AppTheme.textSecondaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${DateFormat('MMM dd, yyyy').format(eventProvider.selectedEvent!.startDate)} - ${DateFormat('MMM dd, yyyy').format(eventProvider.selectedEvent!.endDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}