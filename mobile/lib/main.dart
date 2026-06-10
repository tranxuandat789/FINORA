import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(AnalyticsService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FINORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246BFD)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
