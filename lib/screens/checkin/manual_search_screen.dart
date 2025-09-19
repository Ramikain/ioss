import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/event_provider.dart';
import '../../providers/attendee_provider.dart';
import '../../providers/printer_provider.dart';
import '../../models/attendee.dart';
import '../printer/printer_screen.dart';
import 'widgets/attendee_details_dialog.dart';

class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final eventProvider = context.read<EventProvider>();
    final attendeeProvider = context.read<AttendeeProvider>();
    
    if (eventProvider.hasSelectedEvent) {
      attendeeProvider.searchAttendees(eventProvider.selectedEvent!.id, query);
    }
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
          title: const Text('Manual Search'),
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
                'Please select an event before searching for attendees',
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
        title: const Text('Manual Search'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventProvider.selectedEventName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, email, or company...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: null,
                  ),
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<AttendeeProvider>(
        builder: (context, attendeeProvider, child) {
          if (attendeeProvider.searchQuery.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64.w,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Search for Attendees',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter a name, email, or company to find attendees',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (attendeeProvider.isSearching) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (attendeeProvider.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 64.w,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Results Found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'No attendees match your search criteria',
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
            itemCount: attendeeProvider.searchResults.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final attendee = attendeeProvider.searchResults[index];
              return _AttendeeCard(
                attendee: attendee,
                onTap: () => _onAttendeeSelected(attendee),
              );
            },
          );
        },
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