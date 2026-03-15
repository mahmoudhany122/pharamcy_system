import 'package:flutter/material.dart';
import 'package:zamalek_fans_app/features/home_feature/presentation/pages/home_screen.dart';
import 'core/cache/cahche_helper.dart';
import 'core/dependency_injection/service_locator.dart';
import 'core/network/dio_helper.dart';
import 'features/splash_feature/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Cache
  await CacheHelper.init();
  
  // Initialize Dio
  DioHelper.init();
  
  // Setup Dependency Injection
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00A884),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A884)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}
