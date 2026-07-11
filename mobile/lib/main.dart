import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/transaction/providers/transaction_provider.dart';
import 'package:mobile/features/transaction/providers/category_provider.dart';
import 'package:mobile/features/sync/providers/sync_provider.dart';
import 'package:mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/budget/providers/budget_provider.dart';
import 'package:mobile/features/onboarding/screens/splash_screen.dart';
import 'package:mobile/features/analytics/providers/analytics_provider.dart';
import 'package:mobile/features/analytics/services/analytics_service.dart';
import 'package:mobile/features/profile/providers/profile_provider.dart';
import 'package:mobile/features/profile/providers/notification_settings_provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/notification/providers/notification_provider.dart';
import 'package:mobile/features/notification/services/signalr_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/notification/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  GoogleFonts.config.allowRuntimeFetching = true;
  await ApiClient().init();
  await LocalNotificationService().init();
  
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(AnalyticsService())),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FINORA',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246BFD), brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF60A5FA), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          builder: (context, child) {
            final isDark = themeProvider.isDarkMode;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDark
                  ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
                  : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: child,
                ),
              ),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
