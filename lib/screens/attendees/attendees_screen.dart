import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/event_provider.dart';
import '../../providers/attendee_provider.dart';
import '../../models/attendee.dart';
import '../checkin/widgets/attendee_details_dialog.dart';

class AttendeesScreen extends StatefulWidget {
  const AttendeesScreen({super.key});

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends State<AttendeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onAttendeeSelected(Attendee attendee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttendeeDetailsDialog(attendee: attendee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    
    if (!eventProvider.hasSelectedEvent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendees'),
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
                'Please select an event to view attendees',
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
        title: const Text('Attendees'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Checked In'),
            Tab(text: 'Not Checked In'),
            Tab(text: 'VIP'),
          ],
        ),
      ),
      body: Consumer<AttendeeProvider>(
        builder: (context, attendeeProvider, child) {
          if (attendeeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _AttendeesList(
                attendees: attendeeProvider.attendees,
                onAttendeeSelected: _onAttendeeSelected,
              ),
              _AttendeesList(
                attendees: attendeeProvider.checkedInAttendees,
                onAttendeeSelected: _onAttendeeSelected,
              ),
              _AttendeesList(
                attendees: attendeeProvider.notCheckedInAttendees,
                onAttendeeSelected: _onAttendeeSelected,
              ),
              _AttendeesList(
                attendees: attendeeProvider.vipAttendees,
                onAttendeeSelected: _onAttendeeSelected,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttendeesList extends StatelessWidget {
  final List<Attendee> attendees;
  final Function(Attendee) onAttendeeSelected;

  const _AttendeesList({
    required this.attendees,
    required this.onAttendeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.w,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Attendees',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No attendees found in this category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: attendees.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        return _AttendeeCard(
          attendee: attendee,
          onTap: () => onAttendeeSelected(attendee),
        );
      },
    );
  }
}

class _AttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final VoidCallback onTap;

  const _AttendeeCard({
    required this.attendee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24.w,
                backgroundColor: attendee.isCheckedIn
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  attendee.isCheckedIn ? Icons.check : Icons.person,
                  color: attendee.isCheckedIn
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  size: 24.w,
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            attendee.fullName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (attendee.isVip) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
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
                        ],
                      ],
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    Text(
                      attendee.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    
                    if (attendee.company != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        attendee.company!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 4.h),
                    
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: attendee.isCheckedIn
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        attendee.isCheckedIn ? 'Checked In' : 'Not Checked In',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: attendee.isCheckedIn
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}