import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/attendee_provider.dart';
import '../../providers/checkin_provider.dart';
import '../auth/login_screen.dart';
import 'widgets/event_selector.dart';
import 'widgets/stats_cards.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_checkins.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.initialize();
    
    if (eventProvider.hasSelectedEvent) {
      final attendeeProvider = context.read<AttendeeProvider>();
      final checkinProvider = context.read<CheckinProvider>();
      
      await attendeeProvider.loadAttendees(eventProvider.selectedEvent!.id);
      await checkinProvider.loadCheckinRecords(eventProvider.selectedEvent!.id);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Check-in'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final eventProvider = context.read<EventProvider>();
              await eventProvider.refreshEvents();
              
              if (eventProvider.hasSelectedEvent) {
                final attendeeProvider = context.read<AttendeeProvider>();
                await attendeeProvider.loadAttendees(eventProvider.selectedEvent!.id);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Selector
              const EventSelector(),
              
              SizedBox(height: 24.h),
              
              // Stats Cards
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  if (!eventProvider.hasSelectedEvent) {
                    return Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 48.w,
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
                            'Please select an event to start checking in attendees',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return const StatsCards();
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  if (!eventProvider.hasSelectedEvent) {
                    return const SizedBox.shrink();
                  }
                  
                  return const QuickActions();
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Recent Check-ins
              Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  if (!eventProvider.hasSelectedEvent) {
                    return const SizedBox.shrink();
                  }
                  
                  return const RecentCheckins();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}