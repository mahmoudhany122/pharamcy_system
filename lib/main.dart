import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cache/cahche_helper.dart';
import 'core/dependency_injection/service_locator.dart';
import 'core/network/dio_helper.dart';
import 'core/utiles/app_colors.dart';
import 'features/home_feature/presentation/cubit/home_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()),
        // سنضيف Cubit الثيم واللغة هنا لاحقاً
      ],
      child: MaterialApp(
        title: 'Pharmacy System',
        debugShowCheckedModeBanner: false,
        // Light Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        // Dark Theme
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.darkBackground,
        ),
        themeMode: ThemeMode.system, // يتبع إعدادات الهاتف حالياً
        home: const SplashScreen(),
      ),
    );
  }
}
