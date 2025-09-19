import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/attendee_provider.dart';
import 'providers/checkin_provider.dart';
import 'providers/printer_provider.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
            ChangeNotifierProvider(create: (_) => AttendeeProvider()),
            ChangeNotifierProvider(create: (_) => CheckinProvider()),
            ChangeNotifierProvider(create: (_) => PrinterProvider()),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}