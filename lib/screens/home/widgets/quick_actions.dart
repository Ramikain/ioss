import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../checkin/qr_scanner_screen.dart';
import '../../checkin/manual_search_screen.dart';
import '../../attendees/attendees_screen.dart';
import '../../reports/reports_screen.dart';
import '../../printer/printer_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.2,
          children: [
            _ActionCard(
              title: 'QR Scanner',
              subtitle: 'Scan QR codes',
              icon: Icons.qr_code_scanner,
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QrScannerScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'Manual Search',
              subtitle: 'Search attendees',
              icon: Icons.search,
              color: AppTheme.secondaryColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManualSearchScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'All Attendees',
              subtitle: 'View attendee list',
              icon: Icons.people,
              color: AppTheme.warningColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AttendeesScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'Reports',
              subtitle: 'View statistics',
              icon: Icons.analytics,
              color: AppTheme.vipColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportsScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              title: 'Printer',
              subtitle: 'Bluetooth printer',
              icon: Icons.print,
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrinterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32.w,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}